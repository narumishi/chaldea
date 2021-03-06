import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart' as pathlib;
import 'package:uuid/uuid.dart';

import 'config.dart' show db;
import 'constants.dart';
import 'git_tool.dart';
import 'logger.dart';

class AppInfo {
  AppInfo._();

  static PackageInfo? _packageInfo;
  static String? _uniqueId;

  static final Map<String, dynamic> deviceParams = {};
  static final Map<String, dynamic> appParams = {};

  static Future<void> _loadDeviceInfo() async {
    if (Platform.isAndroid) {
      _loadAndroidParameters(await DeviceInfoPlugin().androidInfo);
    } else if (Platform.isIOS) {
      _loadIosParameters(await DeviceInfoPlugin().iosInfo);
    } else {
      deviceParams['operatingSystem'] = Platform.operatingSystem;
      deviceParams['operatingSystemVersion'] = Platform.operatingSystemVersion;
      // To be implemented
    }
  }

  static void _loadAndroidParameters(AndroidDeviceInfo androidDeviceInfo) {
    deviceParams["id"] = androidDeviceInfo.id;
    deviceParams["androidId"] = androidDeviceInfo.androidId;
    deviceParams["board"] = androidDeviceInfo.board;
    deviceParams["bootloader"] = androidDeviceInfo.bootloader;
    deviceParams["brand"] = androidDeviceInfo.brand;
    deviceParams["device"] = androidDeviceInfo.device;
    deviceParams["display"] = androidDeviceInfo.display;
    deviceParams["fingerprint"] = androidDeviceInfo.fingerprint;
    deviceParams["hardware"] = androidDeviceInfo.hardware;
    deviceParams["host"] = androidDeviceInfo.host;
    deviceParams["isPhysicalDevice"] = androidDeviceInfo.isPhysicalDevice;
    deviceParams["manufacturer"] = androidDeviceInfo.manufacturer;
    deviceParams["model"] = androidDeviceInfo.model;
    deviceParams["product"] = androidDeviceInfo.product;
    deviceParams["tags"] = androidDeviceInfo.tags;
    deviceParams["type"] = androidDeviceInfo.type;
    deviceParams["versionBaseOs"] = androidDeviceInfo.version.baseOS;
    deviceParams["versionCodename"] = androidDeviceInfo.version.codename;
    deviceParams["versionIncremental"] = androidDeviceInfo.version.incremental;
    deviceParams["versionPreviewSdk"] = androidDeviceInfo.version.previewSdkInt;
    deviceParams["versionRelease"] = androidDeviceInfo.version.release;
    deviceParams["versionSdk"] = androidDeviceInfo.version.sdkInt;
    deviceParams["versionSecurityPatch"] =
        androidDeviceInfo.version.securityPatch;
  }

  static void _loadIosParameters(IosDeviceInfo iosInfo) {
    deviceParams["model"] = iosInfo.model;
    deviceParams["isPhysicalDevice"] = iosInfo.isPhysicalDevice;
    deviceParams["name"] = iosInfo.name;
    deviceParams["identifierForVendor"] = iosInfo.identifierForVendor;
    deviceParams["localizedModel"] = iosInfo.localizedModel;
    deviceParams["systemName"] = iosInfo.systemName;
    deviceParams["utsnameVersion"] = iosInfo.utsname.version;
    deviceParams["utsnameRelease"] = iosInfo.utsname.release;
    deviceParams["utsnameMachine"] = iosInfo.utsname.machine;
    deviceParams["utsnameNodename"] = iosInfo.utsname.nodename;
    deviceParams["utsnameSysname"] = iosInfo.utsname.sysname;
  }

  /// PackageInfo: appName+version+buildNumber
  ///  - Android: support
  ///  - for iOS/macOS:
  ///   - if CF** keys not defined in info.plist, return null
  ///   - if buildNumber not defined, return version instead
  ///  - Windows: Not Support
  static Future<void> _loadApplicationInfo() async {
    ///Only android, iOS and macOS are implemented
    _packageInfo = await PackageInfo.fromPlatform().catchError((e) async {
      final versionString = await rootBundle.loadString('res/VERSION');
      final nameAndCode = versionString.split('+');
      PackageInfo packageInfo = PackageInfo(
        appName: kAppName,
        packageName: kPackageName,
        version: nameAndCode[0],
        buildNumber: nameAndCode[1],
      );
      logger.i('Fail to read package info, asset instead: $nameAndCode');
      return packageInfo;
    });
    appParams["version"] = _packageInfo?.version;
    appParams["appName"] = _packageInfo?.appName;
    appParams["buildNumber"] = _packageInfo?.buildNumber;
    appParams["packageName"] = _packageInfo?.packageName;
  }

  static Future<void> _loadUniqueId() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      _uniqueId = (await deviceInfoPlugin.androidInfo).androidId;
    } else if (Platform.isIOS) {
      _uniqueId = (await deviceInfoPlugin.iosInfo).identifierForVendor;
    } else if (Platform.isWindows) {
      // reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "ProductId"
      // Output:
      // HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion
      //     ProductId    REG_SZ    XXXXX-XXXXX-XXXXX-XXXXX
      final result = await Process.run(
        'reg',
        [
          'query',
          r'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion',
          '/v',
          'ProductId'
        ],
        runInShell: true,
      );
      String resultString = result.stdout.toString().trim();
      // print('Windows Product Id query:\n$resultString');
      if (resultString.contains('ProductId') &&
          resultString.contains('REG_SZ')) {
        _uniqueId = resultString.split(RegExp(r'\s+')).last;
      }
    } else if (Platform.isMacOS) {
      // https://stackoverflow.com/a/944103
      // ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/ { split($0, line, "\""); printf("%s\n", line[4]); }'
      // the filter is shell feature so it's not used
      // Output containing:
      //  "IOPlatformUUID" = "8-4-4-4-12 standard uuid"
      // need to parse output
      final result = await Process.run(
        'ioreg',
        [
          '-rd1',
          '-c',
          'IOPlatformExpertDevice',
        ],
        runInShell: true,
      );
      for (String line in result.stdout.toString().split('\n')) {
        if (line.contains('IOPlatformUUID')) {
          final _uuid =
              RegExp(r'[0-9a-zA-Z\-]{35,36}').firstMatch(line)?.group(0);
          if (_uuid != null && _uuid.isNotEmpty) {
            _uniqueId = _uuid;
            break;
          }
        }
      }
    } else {
      throw UnimplementedError(Platform.operatingSystem);
    }
    if (_uniqueId?.isNotEmpty != true) {
      var uuidFile = File(pathlib.join(db.paths.appPath, '.uuid'));
      if (uuidFile.existsSync()) {
        _uniqueId = uuidFile.readAsStringSync();
      }
      if (_uniqueId?.isNotEmpty != true) {
        _uniqueId = Uuid().v1();
        uuidFile.writeAsStringSync(_uniqueId!);
      }
    }
    // logger.i('Unique ID: $_uniqueId');
  }

  /// resolve when init app, so no need to check null or resolve every time
  /// TODO: wait official support for windows
  static Future<void> resolve() async {
    await _loadDeviceInfo();
    await _loadApplicationInfo();
    await _loadUniqueId();
  }

  static PackageInfo? get info => _packageInfo;

  static String get appName {
    if (_packageInfo?.appName.isNotEmpty == true)
      return _packageInfo!.appName;
    else
      return kAppName;
  }

  static Version get versionClass => Version.tryParse(fullVersion)!;

  static String get version => _packageInfo?.version ?? '';

  static int get buildNumber =>
      int.tryParse(_packageInfo?.buildNumber ?? '0') ?? 0;

  static String get packageName => info?.packageName ?? kPackageName;

  /// e.g. 1.2.3+4
  static String get fullVersion {
    String s = '';
    s += version;
    if (buildNumber > 0) s += '+$buildNumber';
    return s;
  }

  /// e.g. 1.2.3 (4)
  static String get fullVersion2 {
    String s = '';
    s += version;
    if (buildNumber > 0) s += ' ($buildNumber)';
    return s;
  }

  static String get uniqueId => _uniqueId!;

  /// currently supported mobile or desktop
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  static bool get isDesktop => Platform.isMacOS || Platform.isWindows;
}
