import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart' as pathlib;

import 'device_app_info.dart';
import 'extensions.dart';
import 'logger.dart';
import 'utils.dart';

const String _owner = 'chaldea-center';
const String _appRepo = 'chaldea';
const String _datasetRepo = 'chaldea-dataset';

/// [GitSource.gitee] deprecated
enum GitSource { github, gitee }
enum GitSource2 { github, gitee }

extension GitSourceExtension on GitSource {
  String toShortString() => EnumUtil.shortString(this);

  String toTitleString() => EnumUtil.titled(this);
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
  GitSource source;

  GitTool([this.source = GitSource.github]);

  GitTool.fromIndex(int? index)
      : source =
            (index == null || index < 0 || index >= GitSource.values.length)
                ? GitSource.values.first
                : GitSource.values[index];

  static String getReleasePageUrl(int? sourceIndex, bool appOrDataset) {
    if (sourceIndex == null ||
        sourceIndex < 0 ||
        sourceIndex >= GitSource.values.length) sourceIndex = 0;
    final source = GitSource.values[sourceIndex];
    String repo = appOrDataset ? _appRepo : _datasetRepo;
    switch (source) {
      case GitSource.github:
        return 'https://github.com/$_owner/$repo/releases';
      case GitSource.gitee:
        return 'https://gitee.com/$_owner/$repo/releases';
    }
  }

  String get owner => _owner;

  String get appRep => _appRepo;

  String get datasetRepo => _datasetRepo;

  /// For Github, release list is from new to old
  /// For Gitee, release list is mostly from old to new
  /// sort list at last
  Future<List<GitRelease>> resolveReleases(String repo) async {
    List<GitRelease> releases = [];
    try {
      if (source == GitSource.github) {
        final response = await Dio().get(
          'https://api.github.com/repos/$owner/$repo/releases',
          options: Options(
              contentType: 'application/json;charset=UTF-8',
              responseType: ResponseType.json),
        );
        // don't use map().toList(), List<dynamic> is not subtype ...
        releases = List.generate(
          response.data?.length ?? 0,
          (index) => GitRelease.fromGithub(data: response.data[index])
            ..htmlUrl ??= 'https://github.com/$owner/$repo/releases',
        );
      } else if (source == GitSource.gitee) {
        // response: List<Release>
        final response = await Dio().get(
          'https://gitee.com/api/v5/repos/$owner/$repo/releases',
          queryParameters: {'page': 0, 'per_page': 50},
          options: Options(
              contentType: 'application/json;charset=UTF-8',
              responseType: ResponseType.json),
        );
        // don't use map().toList(), List<dynamic> is not subtype ...
        releases = List.generate(
          response.data?.length ?? 0,
          (index) => GitRelease.fromGitee(data: response.data[index])
            ..htmlUrl ??= 'https://gitee.com/$owner/$repo/releases',
        );
      }
    } finally {
      releases.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      print('resolve ${releases.length} releases from $source');
      print(releases.map((e) => e.name).toList());
    }
    return releases;
  }

  GitRelease? _latestReleaseWhereAsset(
      Iterable<GitRelease> releases, bool test(GitAsset asset)) {
    // since releases have been sorted, don't need to traverse all releases.
    for (var release in releases) {
      for (var asset in release.assets) {
        if (test(asset)) {
          release.targetAsset = asset;
          logger.i('latest release: $release');
          return release;
        }
      }
    }
  }

  Future<GitRelease?> latestAppRelease([String? keyword]) async {
    if (Platform.isAndroid || Platform.isWindows || kDebugMode) {
      final releases = await resolveReleases(appRep);
      keyword ??= Platform.operatingSystem;
      return _latestReleaseWhereAsset(releases, (asset) {
        return asset.name.toLowerCase().contains(keyword!);
      });
    }
  }

  String releasesPage(String repo) {
    return 'https://${source.toShortString()}.com/$owner/$repo/releases';
  }

  Future<GitRelease?> latestDatasetRelease([bool fullSize = true]) async {
    final releases = await resolveReleases(datasetRepo);
    return _latestReleaseWhereAsset(releases, (asset) {
      return asset.name.toLowerCase() ==
          (fullSize ? 'dataset.zip' : 'dataset-text.zip');
    });
  }

  Future<String?> getReleaseNote([bool test(GitRelease release)?]) async {
    final releases = await resolveReleases(_appRepo);
    if (test == null) {
      test = (release) =>
          Version.tryParse(release.name)?.build == AppInfo.buildNumber;
    }
    return releases.firstWhereOrNull((release) => test!(release))?.body;
  }
}

/// TODO: move to other place, more customizable
class DownloadDialog extends StatefulWidget {
  final String? url;
  final String savePath;
  final String? notes;
  final VoidCallback? onComplete;

  const DownloadDialog(
      {Key? key,
      required this.url,
      required this.savePath,
      this.notes,
      this.onComplete})
      : super(key: key);

  @override
  _DownloadDialogState createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  final CancelToken _cancelToken = CancelToken();
  String progress = '-';
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
    status = 0;
    print('download from ${widget.url}');
    final t0 = DateTime.now();
    if (widget.url?.isNotEmpty != true) {
      print('url cannot be null or empty');
      return;
    }
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
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      if (mounted) setState(() {});
    });
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
        if (status < 0 && widget.url?.isNotEmpty == true)
          TextButton(
              onPressed: startDownload, child: Text(S.of(context).download)),
        if (status > 0)
          TextButton(
            onPressed: () {
              if (widget.onComplete != null) {
                widget.onComplete!();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(S.of(context).ok),
          )
      ],
    );
  }
}

class StaticS extends S {}
