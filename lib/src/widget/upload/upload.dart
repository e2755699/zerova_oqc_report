import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:zerova_oqc_report/route/app_router.dart';
import 'package:zerova_oqc_report/src/repo/sharepoint_uploader.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/package_list_table.dart';

class UploadProgressDialog extends StatefulWidget {
  final int uploadOrDownload;
  final String sn;
  final SharePointUploader uploader;

  const UploadProgressDialog({
    super.key,
    required this.uploadOrDownload,
    required this.sn,
    required this.uploader,
  });

  factory UploadProgressDialog.create({
    required int uploadOrDownload,
    required String sn,
  }) {
    return UploadProgressDialog(
      uploadOrDownload: uploadOrDownload,
      sn: sn,
      uploader: SharePointUploader(uploadOrDownload: uploadOrDownload, sn: sn),
    );
  }

  @override
  State<UploadProgressDialog> createState() => _UploadProgressDialogState();
}

class _UploadProgressDialogState extends State<UploadProgressDialog> {
  double progress = 0.0;
  String currentCategory = "";
  String statusText = "初始化中...";
  bool isUploading = true;

  @override
  void initState() {
    super.initState();
    startUploadProcess();
  }

  void startUploadProcess() async {
    await widget.uploader.startAuthorization(
      onProgressUpdate: (String category, int current, int total) {
        setState(() {
          currentCategory = category;
          progress = total > 0 ? current / total : 0.0;
          statusText =
              "$category 上傳進度: $current / $total (${(progress * 100).toStringAsFixed(2)}%)";
        });
      },
    );

    // 當所有上傳完成後，顯示完成訊息並自動關閉
    setState(() {
      isUploading = false;
      currentCategory = "";
      progress = 1.0;
      if (widget.uploadOrDownload == 0) {
        //0:Upload  1:Download
        statusText = "🎉 上傳完成！";
      } else if (widget.uploadOrDownload == 1) {
        //0:Upload  1:Download
        statusText = "🎉 下載完成！";
      }
    });

    await Future.delayed(Duration(seconds: 2)); // 顯示 2 秒後自動關閉
    if (mounted) {
      Navigator.pop(context); // 關閉對話框
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        // **讓標題置中**
        child: Text(
          widget.uploadOrDownload == 0
              ? "檔案上傳中"
              : widget.uploadOrDownload == 1
                  ? "檔案下載中"
                  : "處理中...",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentCategory.isNotEmpty) ...[
            Text(
              currentCategory,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center, // **讓文字置中**
            ),
            SizedBox(height: 8),
          ],
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10), // 讓進度條有間距
            child: LinearProgressIndicator(value: progress),
          ),
          SizedBox(height: 16),
          Text(
            statusText,
            textAlign: TextAlign.center, // **讓狀態訊息置中**
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center, // **讓按鈕置中**
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context), // 手動關閉視窗
          child: Text("關閉"),
        ),
      ],
    );
  }
}
