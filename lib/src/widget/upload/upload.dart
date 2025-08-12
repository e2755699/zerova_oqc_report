import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/repo/sharepoint_uploader.dart';
import 'package:easy_localization/easy_localization.dart';

class UploadProgressDialog extends StatefulWidget {
  final int uploadOrDownload;
  final String sn;
  final String model;
  final SharePointUploader uploader;

  const UploadProgressDialog({
    super.key,
    required this.uploadOrDownload,
    required this.sn,
    required this.model,
    required this.uploader,
  });

  factory UploadProgressDialog.create({
    required int uploadOrDownload,
    required String sn,
    required String model,
  }) {
    return UploadProgressDialog(
      uploadOrDownload: uploadOrDownload,
      sn: sn,
      model: model,
      uploader: SharePointUploader(uploadOrDownload: uploadOrDownload, sn: sn, model: model),
    );
  }

  @override
  State<UploadProgressDialog> createState() => _UploadProgressDialogState();
}

class _UploadProgressDialogState extends State<UploadProgressDialog> {
  double progress = 0.0;
  String currentCategory = "";
  String statusText =  "Initializing...";
  bool isUploading = true;

  // 明確宣告 categoryTranslations，並在 didChangeDependencies 中初始化
  Map<String, String> categoryTranslations = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 在 didChangeDependencies 中安全地初始化翻譯字串
    setState(() {
      statusText = context.tr('initializing');
      categoryTranslations = {
        "packageing_photo": context.tr('packageing_photo'),
        "appearance_photo": context.tr('appearance_photo'),
        "oqc_report": context.tr('oqc_report'),
      };
    });

    // 在初始化翻譯字串後再開始上傳處理，避免 context 未就緒的錯誤
    startUploadProcess();
  }

  void startUploadProcess() async {
    await widget.uploader.startAuthorization(
      onProgressUpdate: (String category, int current, int total) {
        setState(() {
          currentCategory = category;
          progress = total > 0 ? current / total : 0.0;
          statusText =
              "$category" + context.tr('upload_progress') + "$current / $total (${(progress * 100).toStringAsFixed(2)}%)";
        });
      },
      categoryTranslations: categoryTranslations,
    );

    // 當所有上傳完成後，顯示完成訊息並自動關閉
    setState(() {
      isUploading = false;
      currentCategory = "";
      progress = 1.0;
      if (widget.uploadOrDownload == 0) {
        //0:Upload  1:Download
        statusText = "🎉" + context.tr('upload_complete');  //上傳完成！
      } else if (widget.uploadOrDownload == 1) {
        //0:Upload  1:Download
        statusText = "🎉" + context.tr('download_complete');//下載完成！
      }
    });

    /*await Future.delayed(const Duration(seconds: 2)); // 顯示 2 秒後自動關閉
    if (mounted) {
      Navigator.pop(context); // 關閉對話框
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        // **讓標題置中**
        child: Text(
          widget.uploadOrDownload == 0
              ? context.tr('uploading_file') //檔案上傳中
              : widget.uploadOrDownload == 1
                  ? context.tr('downloading_file') //檔案下載中
                  : context.tr('processing'), //處理中...
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentCategory.isNotEmpty) ...[
            Text(
              currentCategory,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center, // **讓文字置中**
            ),
            const SizedBox(height: 8),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10), // 讓進度條有間距
            child: LinearProgressIndicator(value: progress),
          ),
          const SizedBox(height: 16),
          Text(
            statusText,
            textAlign: TextAlign.center, // **讓狀態訊息置中**
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center, // **讓按鈕置中**
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context), // 手動關閉視窗
          child: Text(context.tr('ok')),
        ),
      ],
    );
  }
}
