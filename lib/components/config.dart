import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:chaldea/components/components.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as pathlib;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import 'constants.dart';
import 'datatypes/datatypes.dart';
import 'device_app_info.dart';
import 'git_tool.dart';
import 'logger.dart';
import 'shared_prefs.dart';
import 'utils.dart';

/// app config:
///  - app database
///  - user database
class Database {
  /// setState for root [MaterialApp]
  VoidCallback notifyAppUpdate = () {};
  UserData userData = UserData();
  GameData gameData = GameData();

  SharedPrefs prefs = SharedPrefs();

  User get curUser => userData.curUser;

  final ItemStatistics itemStat = ItemStatistics();
  final RuntimeData runtimeData = RuntimeData();

  /// broadcast when user data updated
  /// It is used across the whole app lifecycle, so should not close it.
  StreamController<Database> broadcast = StreamController.broadcast();

  void notifyDbUpdate([bool recalculateItemStat = false]) {
    if (recalculateItemStat) {
      this.itemStat
        ..clear()
        ..update();
    }
    this.broadcast.sink.add(this);
  }

  /// widgets depending on database which may change
  Widget streamBuilder(WidgetBuilder builder) {
    return StreamBuilder<Database>(
      initialData: db,
      stream: db.broadcast.stream,
      builder: (context, snapshot) => builder(context),
    );
  }

  void dispose() {
    this.broadcast.close();
  }

  static PathManager _paths = PathManager();

  PathManager get paths => _paths;

  ConnectivityResult? _connectivity;

  ConnectivityResult get connectivity => _connectivity!;

  /// You should always check for connectivity status when your app is resumed
  Future<ConnectivityResult> checkConnectivity() async {
    _connectivity = await Connectivity().checkConnectivity();
    return _connectivity!;
  }

  // initialization before startup
  Future<void> initial() async {
    await paths.initRootPath();
    await AppInfo.resolve();
    await prefs.initiate();
    await checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      _connectivity = result;
    });
  }

  // data files operation
  bool loadUserData() {
    try {
      final newData = UserData.fromJson(
          getJsonFromFile(paths.userDataPath, k: () => <String, dynamic>{}));
      userData = newData;
      gameData.updateUserDuplicatedServants();
      userData.validate();
      logger.d('userdata loaded.');
      return true;
    } catch (e, s) {
      logger.e('Load userdata failed', e, s);
      EasyLoading.showToast('Load userdata failed\n$e');
      return false;
    }
  }

  bool loadGameData() {
    final t = TimeCounter('loadGameData');
    try {
      gameData = GameData.fromJson(getJsonFromFile(paths.gameDataPath));
      // userdata is loaded before gamedata, safe to use curUser
      gameData.updateUserDuplicatedServants();
      userData.validate();
      logger.d('game data loaded, version ${gameData.version}.');
      t.elapsed();
      itemStat.clear();
      itemStat.update();
      db.notifyAppUpdate();
      return true;
    } catch (e, s) {
      logger.e('Load game data failed', e, s);
      EasyLoading.showToast('Load game data failed\n$e');
      return false;
    }
  }

  Future<void> downloadGameData([String? url]) async {
    url ??= db.userData.serverRoot ?? kServerRoot + kDatasetServerPath;
    Dio _dio = Dio();
    try {
      Response response = await _dio.get(url,
          options: Options(responseType: ResponseType.bytes));
      print(response.headers);
      if (response.statusCode == 200) {
        File file = File(pathlib.join(db.paths.tempDir, 'dataset.zip'));
        var raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(response.data);
        raf.closeSync();
        await extractZip(bytes: response.data, savePath: db.paths.gameDir);
        if (db.loadGameData()) {
          logger.i('Data downloaded! Version: ${db.gameData.version}');
          EasyLoading.showToast(
              'Data downloaded! Version: ${db.gameData.version}');
        } else {
          logger.i('Invalid data content! Version: ${db.gameData.version}');
          EasyLoading.showToast(
              'Invalid data content! Version: ${db.gameData.version}');
        }
      }
    } catch (e) {
      logger.w('Downloading error:\n$e');
      EasyLoading.showToast('Downloading error: $e');
      rethrow;
    }
  }

  Future<void> loadZipAssets(String assetKey, {String? extractDir}) async {
    extractDir ??= paths.gameDir;
    final bytes =
        (await rootBundle.load(assetKey)).buffer.asUint8List().cast<int>();
    await extractZip(bytes: bytes, savePath: extractDir);
  }

  void saveUserData() {
    _saveJsonToFile(userData, paths.userDataPath);
  }

  String backupUserdata() {
    String timeStamp = DateFormat('yyyyMMddTHHmmss').format(DateTime.now());
    String filepath = pathlib.join(paths.userDir, 'userdata-$timeStamp.json');
    _saveJsonToFile(userData, filepath);
    return filepath;
  }

  Future<void> clearData({bool user = false, bool game = false}) async {
    if (user) {
      _deleteFileOrDirectory(paths.userDataPath);
      loadUserData();
      db.itemStat
        ..clear()
        ..update();
    }
    if (game) {
      // to clear all history version or not?
      _deleteFileOrDirectory(paths.gameDir);
      await loadZipAssets(kDatasetAssetKey);
      loadGameData();
    }
  }

  String? getIconFullKey(String? iconKey, {bool? preferPng}) {
    if (iconKey == null) return null;
    final suffixes = preferPng == null
        ? ['', '.jpg', '.png']
        : preferPng == true
            ? ['.png', '', '.jpg']
            : ['.jpg', '', '.png'];
    for (var suffix in suffixes) {
      String key = iconKey + suffix;
      if (gameData.icons.containsKey(key)) {
        return key;
      }
    }
    // logger.d('Icon $iconKey not found');
    return iconKey;
  }

  final AssetImage errorImage = AssetImage('res/img/gudako.png');

  /// Only call this when [iconKey] SHOULD be saved to icon dir.
  /// If just want to use network image, use [CachedImage] instead.
  ///
  /// size of [Image] widget is zero before file is loaded to memory.
  /// wrap Container to ensure the placeholder size
  Widget getIconImage(
    String? iconKey, {
    double? width,
    double? height,
    BoxFit? fit,
    bool? preferPng,
  }) {
    if (iconKey == null) {
      return Image(
        image: errorImage,
        width: width,
        height: height,
        fit: fit,
      );
    }
    String iconName = getIconFullKey(iconKey, preferPng: preferPng)!;
    File iconFile = File(pathlib.join(paths.gameIconDir, iconName));
    if (iconFile.existsSync()) {
      return Image(
        image: FileImage(iconFile),
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) => Container(
          width: width,
          height: height,
          child: child,
        ),
      );
    } else {
      return CachedImage(
        imageUrl: iconName,
        saveDir: db.paths.gameIconDir,
        width: width,
        height: height,
        fit: fit,
        isMCFile: !(iconName.contains('http') || iconName.contains('fgo.wiki')),
        placeholder: (_, __) => Container(width: width, height: height),
      );
    }
  }

  // assist methods
  dynamic getJsonFromFile(String filepath, {dynamic k()?}) {
    // dynamic: json object can be Map or List.
    // However, json_serializable always use Map->Class
    dynamic result;
    final file = File(filepath);
    try {
      if (file.existsSync()) {
        String contents = file.readAsStringSync();
        result = jsonDecode(contents);
        print('loaded json "$filepath".');
      }
    } catch (e, s) {
      print('error loading "$filepath", use default value. Error:\n$e\n$s');
      if (k == null) rethrow;
    } finally {
      if (result == null && k != null) {
        print('Loading "$filepath", use default value.');
        result = k();
      }
    }
    return result;
  }

  void _saveJsonToFile(dynamic jsonData, String filepath) {
    try {
      Directory(pathlib.dirname(filepath)).createSync(recursive: true);
      final contents = json.encode(jsonData);
      File(filepath).writeAsStringSync(contents);
      // print('Saved "$relativePath"\n');
    } catch (e, s) {
      print('Error saving "$filepath"!\n$e\n$s');
      EasyLoading.showToast('Error saving "$filepath"!\n$e');
    }
  }

  void _deleteFileOrDirectory(String path) {
    final type = FileSystemEntity.typeSync(path, followLinks: false);
    if (type == FileSystemEntityType.directory) {
      Directory directory = Directory(path);
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    } else if (type == FileSystemEntityType.file) {
      File file = File(path);
      if (file.existsSync()) {
        File(path).deleteSync();
      }
    }
  }

  T? parseJson<T>({required T parser(), T k()?}) {
    T? result;
    try {
      result = parser();
    } catch (e, s) {
      result = k == null ? null : k();
      print('Error parsing json object to instance "$T"\n$e\n$s');
    }
    return result;
  }

  /// You must provide one and only one parameter of [bytes] or [assetKey] or [fp]
  Future<void> extractZip({
    List<int>? bytes,
    String? fp,
    required String savePath,
    Function(dynamic error, dynamic stackTrace)? onError,
    void Function(int, int)? onProgress,
  }) async {
    final t = TimeCounter('extractZip');
    final message = {'bytes': bytes, 'fp': fp, 'savePath': savePath};
    if (onError == null) {
      await compute(_extractZipIsolate, message);
    } else {
      await compute(_extractZipIsolate, message).catchError(onError);
    }
    t.elapsed();
  }

  static Future<void> _extractZipIsolate(Map<String, dynamic> message) async {
    String savePath = message['savePath']!;
    List<int>? bytes = message['bytes'];
    String? fp = message['fp'];

    late List<int> resolvedBytes;
    if ([bytes, fp].where((e) => e != null).length != 1) {
      throw ArgumentError('You can/must only pass one parameter of bytes,fp');
    }
    if (bytes != null) {
      resolvedBytes = bytes;
    }
    if (fp != null) {
      resolvedBytes = File(fp).readAsBytesSync().cast<int>();
    }
    Archive archive = ZipDecoder().decodeBytes(resolvedBytes);
    print('──────────────── Extract zip file ────────────────────────────────');
    print('extract zip file, directory tree "$savePath":');
    if (archive.findFile(kGameDataFilename) == null) {
      throw FormatException('Archive file doesn\'t contain $kGameDataFilename');
    }
    int iconCount = 0;
    for (ArchiveFile file in archive) {
      String fullFilepath = pathlib.join(savePath, file.name);
      if (file.isFile) {
        List<int> data = file.content;
        File(fullFilepath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
        if (file.name.startsWith('icons/'))
          iconCount += 1;
        else
          print('file: ${file.name}');
      } else {
        Directory(fullFilepath)..create(recursive: true);
        print('dir : ${file.name}');
      }
    }
    print('icon files: total $iconCount files in "icons/"');
    print('──────────────── End zip file ────────────────────────────────────');
  }

  // singleton
  static final _db = new Database._internal();

  factory Database() => _db;

  Database._internal();
}

class PathManager {
  /// [_appPath] root path where app can access
  static String? _appPath;

  Future<void> initRootPath() async {
    if (_appPath != null) return;
    // final Map<String, Directory> _fps = {
    //   'ApplicationDocuments': await getApplicationDocumentsDirectory(),
    //   'Temporary': await getTemporaryDirectory(),
    //   'ApplicationSupport': await getApplicationSupportDirectory(),
    //   'Library': await getLibraryDirectory(),
    // };
    // for (var e in _fps.entries) {
    //   print('${e.key}\n\t\t${e.value.path}');
    // }

    if (Platform.isAndroid) {
      // don't use getApplicationDocumentsDirectory, it is hidden to user.
      // android: [emulated, external SD]
      _appPath = (await getExternalStorageDirectories())?.elementAt(0).path;
      // _tempPath = (await getTemporaryDirectory())?.path;
    } else if (Platform.isIOS) {
      _appPath = (await getApplicationDocumentsDirectory()).path;
      // _tempPath = (await getTemporaryDirectory())?.path;
    } else if (Platform.isWindows) {
      _appPath = (await getApplicationSupportDirectory()).path;
      // _tempPath = (await getTemporaryDirectory())?.path;
    } else if (Platform.isMacOS) {
      // /Users/<user>/Library/Containers/cc.narumi.chaldea/Data/Documents
      _appPath = (await getApplicationDocumentsDirectory()).path;
      // /Users/<user>/Library/Containers/cc.narumi.chaldea/Data/Library/Caches
      // _tempPath = (await getTemporaryDirectory())?.path;
    } else {
      throw UnimplementedError('Not supported for ${Platform.operatingSystem}');
    }
    if (_appPath == null) {
      throw OSError('Cannot resolve document folder');
    }

    for (String dir in [userDir, gameDir, tempDir, gameIconDir]) {
      Directory(dir).createSync(recursive: true);
    }
  }

  String get appPath => _appPath!;

  String get gameDir => pathlib.join(_appPath!, 'data');

  String get userDir => pathlib.join(_appPath!, 'user');

  String get tempDir => pathlib.join(_appPath!, 'temp');

  String get userDataPath => pathlib.join(userDir, kUserDataFilename);

  String get gameDataPath => pathlib.join(gameDir, kGameDataFilename);

  String get gameIconDir => pathlib.join(gameDir, 'icons');

  String get crashLog => pathlib.join(_appPath!, 'crash.log');

  String get datasetVersionFile => pathlib.join(gameDir, 'VERSION');

  static PathManager _instance = PathManager._internal();

  PathManager._internal();

  factory PathManager() => _instance;
}

class RuntimeData {
  Version? upgradableVersion;
  double? criticalWidth;
  List<File> itemRecognizeImageFiles = [];

  /// Controller of [Screenshot] widget which set root [MaterialApp] as child
  ScreenshotController? screenshotController;
}

Database db = new Database();
