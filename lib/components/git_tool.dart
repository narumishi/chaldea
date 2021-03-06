import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart' as pathlib;

import 'device_app_info.dart';
import 'extensions.dart';
import 'logger.dart';
import 'utils.dart';

enum GitSource { github, gitee }

extension GitSourceExtension on GitSource {
  String toShortString() => EnumUtil.shortString(this);

  String toTitleString() => EnumUtil.titled(this);

  int toIndex() => GitSource.values.indexOf(this);

  static GitSource fromIndex(int index) =>
      GitSource.values.getOrNull(index) ?? GitSource.values.first;
}

/// When comparison, [build] will be ignored:
///   - on iOS, cannot fetch [build] from server api
///   - on Android, split-abi will change [build] from 25 to 1025/2025/4025
class Version extends Comparable<Version> {
  /// valid format:
  ///   - v1.2.3+4,'v' and +4 is optional
  ///   - 1.2.3.4, windows format
  static final RegExp _fullVersionRegex =
      RegExp(r'^v?(\d+)\.(\d+)\.(\d+)(?:[+.](\d+))?$', caseSensitive: false);
  final int major;
  final int minor;
  final int patch;
  final int? build;

  Version(this.major, this.minor, this.patch, [this.build]);

  String get version => '$major.$minor.$patch';

  String get fullVersion => version + (build == null ? '' : '+$build');

  /// compare [build] here
  bool equalTo(String other) {
    Version? _other = Version.tryParse(other);
    if (_other == null) return false;
    if (major == _other.major &&
        minor == _other.minor &&
        patch == _other.patch) {
      return build == null || _other.build == null || build == _other.build;
    } else {
      return false;
    }
  }

  @override
  String toString() {
    return '$runtimeType($major, $minor, $patch${build == null ? "" : ", $build"})';
  }

  static Version? tryParse(String versionString, [int? build]) {
    versionString = versionString.trim();
    if (!_fullVersionRegex.hasMatch(versionString)) {
      logger.e(ArgumentError.value(
          versionString, 'versionString', 'Invalid version format'));
      return null;
    }
    Match match = _fullVersionRegex.firstMatch(versionString)!;
    int major = int.parse(match.group(1)!);
    int minor = int.parse(match.group(2)!);
    int patch = int.parse(match.group(3)!);
    int? _build = int.tryParse(match.group(4) ?? '');
    return Version(major, minor, patch, build ?? _build);
  }

  @override
  int compareTo(Version other) {
    // build(nullable) then major/minor/patch
    // if (build != null && other.build != null && build != other.build) {
    //   return build!.compareTo(other.build!);
    // }
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);
    return 0;
  }

  @override
  bool operator ==(Object other) {
    return other is Version && compareTo(other) == 0;
  }

  bool operator <(Version other) => compareTo(other) < 0;

  bool operator <=(Version other) => compareTo(other) <= 0;

  bool operator >(Version other) => compareTo(other) > 0;

  bool operator >=(Version other) => compareTo(other) >= 0;

  @override
  int get hashCode => toString().hashCode;
}

class GitRelease {
  int id;
  String name;
  String tagName;
  String? body;
  DateTime createdAt;
  String? htmlUrl;
  List<GitAsset> assets;
  GitAsset? targetAsset;
  GitSource? source;

  GitRelease({
    required this.id,
    required this.name,
    required this.tagName,
    required this.body,
    required this.createdAt,
    required this.htmlUrl,
    required this.assets,
    this.targetAsset,
    this.source,
  });

  GitRelease.fromGithub({required Map<String, dynamic> data})
      : id = data['id'] ?? 0,
        tagName = data['tag_name'] ?? '',
        name = data['name'] ?? '',
        body = data['body'] ?? '',
        createdAt = DateTime.parse(data['created_at'] ?? '20200101'),
        htmlUrl = data['html_url'],
        assets = List.generate(
          data['assets']?.length ?? 0,
          (index) => GitAsset(
            name: data['assets'][index]['name'] ?? '',
            browserDownloadUrl:
                data['assets'][index]['browser_download_url'] ?? '',
          ),
        ),
        source = GitSource.gitee;

  GitRelease.fromGitee({required Map<String, dynamic> data})
      : id = data['id'] ?? 0,
        tagName = data['tag_name'] ?? '',
        name = data['name'] ?? '',
        body = data['body'] ?? '',
        createdAt = DateTime.parse(data['created_at'] ?? '20200101'),
        assets = List.generate(
          data['assets']?.length ?? 0,
          (index) => GitAsset(
            name: data['assets'][index]['name'] ?? '',
            browserDownloadUrl:
                data['assets'][index]['browser_download_url'] ?? '',
          ),
        ),
        source = GitSource.gitee;

  @override
  String toString() {
    final src = source?.toString().split('.').last;
    return '$runtimeType($name, tagName=$tagName,'
        ' targetAsset=${targetAsset?.name}, source=$src)';
  }
}

class GitAsset {
  String name;
  String? browserDownloadUrl;

  GitAsset({required this.name, required this.browserDownloadUrl});
}

class GitTool {
  final GitSource source;
  late String owner;
  late String appRepo;
  late String datasetRepo;

  GitTool([this.source = GitSource.github]) {
    switch (source) {
      case GitSource.github:
        owner = 'chaldea-center';
        appRepo = 'chaldea';
        datasetRepo = 'chaldea-dataset';
        break;
      case GitSource.gitee:
        owner = 'chaldea-center';
        appRepo = 'chaldea';
        datasetRepo = 'chaldea-dataset';
        break;
    }
  }

  static GitTool fromDb() {
    return GitTool(GitSource.values.getOrNull(db.userData.updateSource) ??
        GitSource.values.first);
  }

  String get appReleaseUrl {
    return 'https://${source.toShortString()}.com/$owner/$appRepo/releases';
  }

  String get datasetReleaseUrl {
    return 'https://${source.toShortString()}.com/$owner/$datasetRepo/releases';
  }

  Future<List<GitRelease>> get appReleases => _resolveReleases(appRepo);

  Future<List<GitRelease>> get datasetReleases => _resolveReleases(datasetRepo);

  /// For Github, release list is from new to old
  /// For Gitee, release list is from old to new
  /// sort list at last
  Future<List<GitRelease>> _resolveReleases(String _repo) async {
    List<GitRelease> releases = [];
    try {
      if (source == GitSource.github) {
        final response = await Dio().get(
          'https://api.github.com/repos/$owner/$_repo/releases',
          options: Options(
              contentType: 'application/json;charset=UTF-8',
              responseType: ResponseType.json),
        );
        // don't use map().toList(), List<dynamic> is not subtype ...
        releases = List.generate(
          response.data?.length ?? 0,
          (index) => GitRelease.fromGithub(data: response.data[index])
            ..htmlUrl ??= 'https://github.com/$owner/$_repo/releases',
        );
      } else if (source == GitSource.gitee) {
        // response: List<Release>
        final response = await Dio().get(
          'https://gitee.com/api/v5/repos/$owner/$_repo/releases',
          queryParameters: {'page': 0, 'per_page': 50},
          options: Options(
              contentType: 'application/json;charset=UTF-8',
              responseType: ResponseType.json),
        );
        // don't use map().toList(), List<dynamic> is not subtype ...
        releases = List.generate(
          response.data?.length ?? 0,
          (index) => GitRelease.fromGitee(data: response.data[index])
            ..htmlUrl ??= 'https://gitee.com/$owner/$_repo/releases',
        );
      }
    } finally {
      releases.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      print('resolve ${releases.length} releases from $source');
      print(releases.map((e) => e.name).toList());
    }
    return releases;
  }

  GitRelease? _latestReleaseWhereAsset(Iterable<GitRelease> releases,
      {bool testRelease(GitRelease release)?,
      bool testAsset(GitAsset asset)?}) {
    // since releases have been sorted, don't need to traverse all releases.
    if (testRelease != null) {
      releases = releases.where((release) => testRelease(release));
    }
    if (testAsset != null) {
      releases = releases.where((release) {
        for (var asset in release.assets) {
          if (testAsset(asset)) {
            release.targetAsset = asset;
            return true;
          }
        }
        return false;
      });
    }
    if (releases.isNotEmpty) {
      return releases.first;
    }
    return null;
  }

  Future<GitRelease?> latestAppRelease([bool test(GitAsset asset)?]) async {
    if (test == null)
      test = (asset) =>
          asset.name.toLowerCase().contains(Platform.operatingSystem);
    if (Platform.isAndroid || Platform.isWindows || kDebugMode) {
      final releases = await appReleases;
      return _latestReleaseWhereAsset(releases, testAsset: test);
    }
  }

  Future<GitRelease?> latestDatasetRelease([bool fullSize = true]) async {
    final releases = await datasetReleases;
    return _latestReleaseWhereAsset(releases, testAsset: (asset) {
      return asset.name.toLowerCase() ==
          (fullSize ? 'dataset.zip' : 'dataset-text.zip');
    });
  }

  Future<String?> appReleaseNote([bool test(GitRelease release)?]) async {
    if (test == null)
      test =
          (release) => Version.tryParse(release.name) == AppInfo.versionClass;
    return (await appReleases).firstWhereOrNull(test)?.body;
  }

  Future<String?> datasetReleaseNote([bool test(GitRelease release)?]) async {
    if (test == null) test = (release) => release.name == db.gameData.version;
    return (await datasetReleases).firstWhereOrNull(test)?.body;
  }
}

/// TODO: move to other place, more customizable
class DownloadDialog extends StatefulWidget {
  final String? url;
  final String savePath;
  final String? notes;
  final VoidCallback? onComplete;
  final String? confirmText;

  const DownloadDialog({
    Key? key,
    required this.url,
    required this.savePath,
    this.notes,
    this.onComplete,
    this.confirmText,
  }) : super(key: key);

  @override
  _DownloadDialogState createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  final CancelToken _cancelToken = CancelToken();
  String progress = '-';

  /// -1:not start, 0:started, 1:completed
  int status = -1;
  Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
  }

  String _sizeInMB(int bytes) {
    return (bytes / 1000000).toStringAsFixed(2) + 'MB';
  }

  Future<void> startDownload() async {
    print('download from ${widget.url}');
    final t0 = DateTime.now();
    if (widget.url?.isNotEmpty != true) {
      EasyLoading.showToast('url cannot be null or empty');
      return;
    }
    status = 0;
    setState(() {});
    try {
      final response = await _dio.download(
        widget.url!,
        widget.savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      onDownloadComplete(response);
    } on DioError catch (e) {
      if (e.type != DioErrorType.cancel) {
        EasyLoading.showError(e.toString());
        rethrow;
      }
    }
    logger.i('Download time usage:'
        ' ${DateTime.now().difference(t0).inMilliseconds}');
  }

  void onReceiveProgress(int count, int total) {
    if (total < 0) {
      progress = _sizeInMB(count);
    } else {
      String percent = formatNumber(count / total, percent: true);
      String size = _sizeInMB(total);
      String downSize = _sizeInMB(count);
      progress = '$downSize/$size ($percent)';
    }
    setState(() {});
  }

  void onDownloadComplete(Response response) {
    status = 1;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final fn = pathlib.basename(widget.savePath);
    final headerStyle = TextStyle(fontWeight: FontWeight.bold);
    return AlertDialog(
      title: Text(S.of(context).download),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${S.current.filename}:', style: headerStyle),
          Text(fn),
          if (widget.notes != null) Text('更新内容:', style: headerStyle),
          if (widget.notes != null) Text(widget.notes!),
          Text('下载进度:', style: headerStyle),
          widget.url?.isNotEmpty == true
              ? Text(progress)
              : Text(S.of(context).query_failed)
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _cancelToken.cancel('user canceled');
            Navigator.of(context).pop();
          },
          child: Text(S.of(context).cancel),
        ),
        if (status < 1)
          TextButton(
            onPressed: status < 0 && widget.url?.isNotEmpty == true
                ? startDownload
                : null,
            child: Text(S.of(context).download),
          ),
        if (status > 0)
          TextButton(
            onPressed: () {
              if (widget.onComplete != null) {
                widget.onComplete!();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(widget.confirmText ?? S.of(context).confirm),
          )
      ],
    );
  }
}

class StaticS extends S {}
