import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/home/home_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/repo/firebase_service.dart';
import 'package:zerova_oqc_report/src/report/spec/input_output_characteristics_spec.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class InputModelNameAndSnDialog extends StatefulWidget {
  const InputModelNameAndSnDialog({super.key});

  @override
  State<InputModelNameAndSnDialog> createState() =>
      _InputModelNameAndSnDialogState();
}

class _InputModelNameAndSnDialogState extends State<InputModelNameAndSnDialog>
    with LoadFileHelper {
  final _formKey = GlobalKey<FormState>();
  final _snController = TextEditingController();
  final _modelController = TextEditingController();
  final _modelFocusNode = FocusNode();
  final _snFocusNode = FocusNode();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _modelFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _snController.dispose();
    _modelController.dispose();
    _modelFocusNode.dispose();
    _snFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('input_sn_model')),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              enabled: !isLoading,
              focusNode: _modelFocusNode,
              controller: _modelController,
              decoration: InputDecoration(
                labelText: context.tr('model_name'),
                hintText: context.tr('please_input_model_name'),
                prefixIcon: const Icon(Icons.text_fields),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.tr('please_input_model_name');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              enabled: !isLoading,
              focusNode: _snFocusNode,
              controller: _snController,
              decoration: InputDecoration(
                labelText: context.tr('sn'),
                hintText: context.tr('please_input_sn'),
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.tr('please_input_sn');
                }
                return null;
              },
            ),
            if (isLoading)
              Container(
                margin: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(context.tr('processing')),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () {
            Navigator.of(context).pop();
          },
          child: Text(context.tr('cancel')),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : () async {
            if (_formKey.currentState!.validate()) {
              setState(() {
                isLoading = true;
              });
              
              try {
                final sn = _snController.text;
                final model = _modelController.text;

                // 建立日誌檔案
                var logFilePath = '';
                if (Platform.isMacOS) {
                  logFilePath = path.join(
                      Platform.environment['HOME'] ?? '', 'Test Result', 'Zerova', 'logs');
                } else if (Platform.isWindows) {
                  logFilePath = path.join(
                      Platform.environment['USERPROFILE'] ?? '', 'Test Result', 'Zerova', 'logs');
                } else {
                  logFilePath = path.join(
                      Platform.environment['HOME'] ?? '', 'Test Result', 'Zerova', 'logs');
                }

                // 確保日誌目錄存在
                final logDirectory = Directory(logFilePath);
                if (!await logDirectory.exists()) {
                  await logDirectory.create(recursive: true);
                }

                final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
                final logFile = File(path.join(logFilePath, 'spec_log_${sn}_${model}_$timestamp.txt'));
                await logFile.writeAsString('開始獲取 $model 型號的規格數據...\n', mode: FileMode.append);

                try {
                  await logFile.writeAsString('嘗試獲取 InputOutputCharacteristicsSpecs...\n', mode: FileMode.append);
                  await fetchAndPrintInputOutputCharacteristicsSpecs(model);
                  await logFile.writeAsString('成功獲取 InputOutputCharacteristicsSpecs\n', mode: FileMode.append);
                } catch (e, st) {
                  await logFile.writeAsString('獲取 InputOutputCharacteristicsSpecs 失敗: $e\n', mode: FileMode.append);
                  await logFile.writeAsString('堆疊追蹤: $st\n', mode: FileMode.append);
                }

                try {
                  await logFile.writeAsString('嘗試獲取 BasicFunctionTestSpecs...\n', mode: FileMode.append);
                  await fetchAndPrintBasicFunctionTestSpecs(model);
                  await logFile.writeAsString('成功獲取 BasicFunctionTestSpecs\n', mode: FileMode.append);
                } catch (e, st) {
                  await logFile.writeAsString('獲取 BasicFunctionTestSpecs 失敗: $e\n', mode: FileMode.append);
                  await logFile.writeAsString('堆疊追蹤: $st\n', mode: FileMode.append);
                }

                try {
                  await logFile.writeAsString('嘗試獲取 HipotTestSpecs...\n', mode: FileMode.append);
                  await fetchAndPrintHipotTestSpecs(model);
                  await logFile.writeAsString('成功獲取 HipotTestSpecs\n', mode: FileMode.append);
                } catch (e, st) {
                  await logFile.writeAsString('獲取 HipotTestSpecs 失敗: $e\n', mode: FileMode.append);
                  await logFile.writeAsString('堆疊追蹤: $st\n', mode: FileMode.append);
                }

                try {
                  await logFile.writeAsString('嘗試獲取 FailCountsForDevice...\n', mode: FileMode.append);
                  await fetchFailCountsForDevice(model, sn);
                  await logFile.writeAsString('成功獲取 FailCountsForDevice\n', mode: FileMode.append);
                } catch (e, st) {
                  await logFile.writeAsString('獲取 FailCountsForDevice 失敗: $e\n', mode: FileMode.append);
                  await logFile.writeAsString('堆疊追蹤: $st\n', mode: FileMode.append);
                }

                try {
                  await logFile.writeAsString('開始載入主要數據...\n', mode: FileMode.append);
                  await loadFileModule(sn, model, context).then((_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(context.tr('submit_success', args: [sn, model])),
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  }).onError((e, st) async {
                    await logFile.writeAsString('載入主要數據失敗: $e\n堆疊追蹤: $st\n', mode: FileMode.append);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(context.tr('submit_fail', args: [sn, model])),
                        ),
                      );
                    }
                  });
                } catch (e, st) {
                  await logFile.writeAsString('載入主要數據時發生意外錯誤: $e\n', mode: FileMode.append);
                  await logFile.writeAsString('堆疊追蹤: $st\n', mode: FileMode.append);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('submit_fail', args: [sn, model])),
                      ),
                    );
                  }
                }
              } finally {
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
              }
            }
          },
          child: Text(context.tr('submit')),
        ),
      ],
    );
  }
}
