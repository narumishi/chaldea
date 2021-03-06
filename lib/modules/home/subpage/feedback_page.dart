import 'dart:convert';
import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path/path.dart' as pathlib;
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool attachLog = true;
  late TextEditingController contactController;
  late TextEditingController bodyController;

  @override
  void initState() {
    super.initState();
    contactController = TextEditingController();
    bodyController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    contactController.dispose();
    bodyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).about_feedback),
        leading: BackButton(),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 8),
        children: [
          Padding(padding: EdgeInsets.only(top: 8)),
          TileGroup(
            header: 'Github',
            children: [
              ListTile(
                title: Text(S.of(context).project_homepage),
                subtitle: Text(kProjectHomepage),
                onTap: () => jumpToExternalLinkAlert(
                  url: '$kProjectHomepage/issues',
                  name: 'Github',
                ),
              ),
            ],
          ),
          TileGroup(
            header: 'NGA',
            children: [
              ListTile(
                title: Text(S.of(context).nga),
                subtitle: Text('https://bbs.nga.cn/read.php?tid=24926789'),
                onTap: () => jumpToExternalLinkAlert(
                  url: 'https://bbs.nga.cn/read.php?tid=24926789',
                  name: S.of(context).nga_fgo,
                ),
              ),
            ],
          ),
          TileGroup(
            header: 'Email',
            children: [
              ListTile(
                title: Text('Email'),
                subtitle: Text(kSupportTeamEmailAddress),
                onTap: () async {
                  String subject = '$kAppName v${AppInfo.fullVersion} Feedback';
                  String body = "OS: ${Platform.operatingSystem}"
                      " ${Platform.operatingSystemVersion}\n\n"
                      "Please attach crash log(${db.paths.crashLog})";
                  final uri = Uri(
                      scheme: 'mailto',
                      path: kSupportTeamEmailAddress,
                      query: 'subject=$subject&body=$body');
                  print(uri);
                  if (await canLaunch(uri.toString())) {
                    launch(uri.toString());
                  } else {
                    SimpleCancelOkDialog(
                      title: Text('Send email to'),
                      content: Text(kSupportTeamEmailAddress),
                    ).show(context);
                  }
                },
              ),
            ],
          ),
          TileGroup(
            header: S.of(context).about_feedback,
            // divider: Container(),
            innerDivider: false,
            children: [
              Padding(padding: EdgeInsets.only(top: 8)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: contactController,
                  decoration: InputDecoration(
                    labelText: S.of(context).feedback_contact,
                    border: OutlineInputBorder(),
                    // prefix: Icon(Icons.mail_outline),
                  ),
                  maxLines: 1,
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 20)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                height: 200,
                child: TextField(
                  controller: bodyController,
                  decoration: InputDecoration(
                    labelText: S.of(context).feedback_content_hint,
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  expands: true,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
              CheckboxListTile(
                title: Text(S.of(context).feedback_add_crash_log),
                value: attachLog,
                onChanged: (v) {
                  setState(() {
                    attachLog = v ?? attachLog;
                  });
                },
              ),
              Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
              ListTile(
                title: Text(S.of(context).feedback_add_attachments),
                onTap: _addAttachments,
              ),
              for (String fp in attachFiles)
                ListTile(
                  leading: Icon(Icons.attach_file),
                  title: Text(pathlib.basename(fp)),
                  trailing: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        attachFiles.remove(fp);
                      });
                    },
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: sendEmail,
                    child: Text(S.of(context).feedback_send),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Set<String> attachFiles = Set();

  void _addAttachments() {
    FilePickerCross.importMultipleFromStorage(type: FileTypeCross.image)
        .then((filePickers) {
      attachFiles.addAll(filePickers.map((e) => e.path));
      if (mounted) {
        setState(() {});
      }
    }).catchError((error, stackTrace) {
      if (!(error is FileSelectionCanceledError)) {
        print(error.toString());
        print(stackTrace.toString());
        EasyLoading.showError(error.toString());
      }
    });
  }

  void sendEmail() async {
    if (bodyController.text.trim().isEmpty &&
        attachFiles.isEmpty &&
        !attachLog) {
      EasyLoading.showToast('请填写反馈内容或添加附件');
      return;
    }
    var canceler = showMyProgress(status: 'Sending');
    try {
      final message = Message()
        ..from = Address('chaldea-client@narumi.cc', 'Chaldea Feedback')
        ..recipients.add(kSupportTeamEmailAddress)
        ..subject = 'Chaldea v${AppInfo.fullVersion2} Feedback';

      message.html = _emailBody();
      [db.paths.crashLog, ...attachFiles].forEach((fp) {
        var file = File(fp);
        if (file.existsSync()) message.attachments.add(FileAttachment(file));
      });
      if (!kDebugMode) {
        final result = await send(
            message,
            SmtpServer('smtp.qiye.aliyun.com',
                port: 465,
                ssl: true,
                username: 'chaldea-client@narumi.cc',
                password: b64('Q2hhbGRlYUBjbGllbnQ=')));
        logger.i(result.toString());
      } else {
        await Future.delayed(Duration(seconds: 3));
      }
      canceler();
      EasyLoading.showSuccess('Sent');
    } catch (error, stacktrace) {
      print(error.toString());
      print(stacktrace.toString());
      canceler();
      EasyLoading.showError(error.toString());
    }
  }

  String _emailBody() {
    final escape = HtmlEscape().convert;
    StringBuffer buffer = StringBuffer("");
    buffer.write('<style>h3{margin:0.2em 0;}</style>');

    if (contactController.text.isNotEmpty == true) {
      buffer.write("<h3>Contact:</h3>");
      buffer.write("${escape(contactController.text)}<br>");
    }
    buffer.write("<h3>Summary:</h3>");
    final dataVerFile = File(db.paths.datasetVersionFile);
    Map<String, dynamic> summary = {
      'appVersion': '${AppInfo.appName} v${AppInfo.fullVersion}',
      'datasetVersion': dataVerFile.existsSync()
          ? dataVerFile.readAsStringSync()
          : "Not detected",
      'os': '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
    };
    for (var entry in summary.entries) {
      buffer.write("<b>${entry.key}</b>: ${escape(entry.value)}<br>");
    }
    buffer.write('<hr>');

    buffer.write("<h3>Device parameters:</h3>");
    for (var entry in AppInfo.deviceParams.entries) {
      buffer.write("<b>${entry.key}</b>: ${escape(entry.value)}<br>");
    }
    buffer.write("<hr>");

    buffer.write("<h3>Application parameters:</h3>");
    for (var entry in AppInfo.appParams.entries) {
      buffer.write("<b>${entry.key}</b>: ${escape(entry.value)}<br>");
    }
    buffer.write("<hr>");

    return buffer.toString();
  }
}
