import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/mixin/load_file_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/repo/firebase_service.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/report/spec/new_package_list_spec.dart.dart';
import 'package:zerova_oqc_report/src/report/spec/package_list_spec.dart';

class InputModelNameAndSnDialog extends StatefulWidget {
  const InputModelNameAndSnDialog({super.key});

  @override
  State<InputModelNameAndSnDialog> createState() =>
      _InputModelNameAndSnDialogState();
}

class _InputModelNameAndSnDialogState extends State<InputModelNameAndSnDialog>
    with LoadFileHelper<InputModelNameAndSnDialog> {
  final _formKey = GlobalKey<FormState>();
  final _snController = TextEditingController();
  final _modelController = TextEditingController();
  final _modelFocusNode = FocusNode();
  final _snFocusNode = FocusNode();
  bool isLoading = false;

  final Map<String, List<String>> modelToSnMap = {
    //'EV500': ['T2449A003A1', 'T2449A003A2'],
    //'EV600': ['T2449A003A3'],
  };

  String? selectedModel;
  String? selectedSn;

  void initState() {
    super.initState();

    fetchModelToSnMapFromFirestore().then((map) {
      setState(() {
        modelToSnMap.clear();
        modelToSnMap.addAll(map);
      });
    });
  }

  @override
  void dispose() {
    _snController.dispose();
    _modelController.dispose();
    _modelFocusNode.dispose();
    _snFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    globalPackageListSpecInitialized = false;

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
          logFilePath = path.join(Platform.environment['HOME'] ?? '',
              'Test Result', 'Zerova', 'logs');
        } else if (Platform.isWindows) {
          logFilePath = path.join(Platform.environment['USERPROFILE'] ?? '',
              'Test Result', 'Zerova', 'logs');
        } else {
          logFilePath = path.join(Platform.environment['HOME'] ?? '',
              'Test Result', 'Zerova', 'logs');
        }

        // 確保日誌目錄存在
        final logDirectory = Directory(logFilePath);
        if (!await logDirectory.exists()) {
          await logDirectory.create(recursive: true);
        }

        final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final logFile = File(
            path.join(logFilePath, 'spec_log_${sn}_${model}_$timestamp.txt'));
        await logFile.writeAsString('開始獲取 $model 型號的規格數據...\n',
            mode: FileMode.append);

        try {
          await logFile.writeAsString(
              '嘗試獲取 PsuSerialNumSpec...\n',
              mode: FileMode.append);
          await fetchAndPsuSerialNumSpecs(model);
          await logFile.writeAsString('成功獲取 PsuSerialNumSpec\n',
              mode: FileMode.append);
        } catch (e, st) {
          await logFile.writeAsString(
              '獲取 PsuSerialNumSpec 失敗: $e\n',
              mode: FileMode.append);
          await logFile.writeAsString('堆疊追蹤: $st\n', mode: FileMode.append);
        }

        try {
          await logFile.writeAsString(
              '嘗試獲取 InputOutputCharacteristicsSpecs...\n',
              mode: FileMode.append);
          await fetchAndPrintInputOutputCharacteristicsSpecs(model);
          await logFile.writeAsString('成功獲取 InputOutputCharacteristicsSpecs\n',
              mode: FileMode.append);
        } catch (e, st) {
          await logFile.writeAsString(
              '獲取 InputOutputCharacteristicsSpecs 失敗: $e\n',
              mode: FileMode.append);
          await logFile.writeAsString('堆疊追蹤: $st\n', mode: FileMode.append);
        }

        try {
          await logFile.writeAsString('嘗試獲取 BasicFunctionTestSpecs...\n',
              mode: FileMode.append);
          await fetchAndPrintBasicFunctionTestSpecs(model);
          await logFile.writeAsString('成功獲取 BasicFunctionTestSpecs\n',
              mode: FileMode.append);
        } catch (e, st) {
          await logFile.writeAsString('獲取 BasicFunctionTestSpecs 失敗: $e\n',
              mode: FileMode.append);
          await logFile.writeAsString('堆疊追蹤: $st\n', mode: FileMode.append);
        }

        try {
          await logFile.writeAsString('嘗試獲取 HipotTestSpecs...\n',
              mode: FileMode.append);
          await fetchAndPrintHipotTestSpecs(model);
          await logFile.writeAsString('成功獲取 HipotTestSpecs\n',
              mode: FileMode.append);
        } catch (e, st) {
          await logFile.writeAsString('獲取 HipotTestSpecs 失敗: $e\n',
              mode: FileMode.append);
          await logFile.writeAsString('堆疊追蹤: $st\n', mode: FileMode.append);
        }

        try {
          await logFile.writeAsString('嘗試獲取 PackageListSpec...\n',
              mode: FileMode.append);
          final spec = await fetchPackageListSpec(model);
          if (spec != null) {
            print('PackageListSpec spec (raw Map): $spec');
            final data = PackageListResult();
            final packageListResult = packageListResultFromSpecDataWithUpdate(spec);
            PackageListSpecGlobal.set(packageListResult);
            final measurements2 = PackageListSpecGlobal.get().measurements;

            for (int i = 0; i < measurements2.length; i++) {
              final m = measurements2[i];
              print('itemName: ${m.itemName}, quantity: ${m.quantity}, isChecked: ${m.isCheck.value}');

              data.updateOrAddMeasurement(
                index: i,
                name: m.itemName,
                quantity: m.quantity,
                isChecked: m.isCheck.value,
              );
            }

            final measurements = packageListResult.measurements;
            for (var m in measurements) {
              print('itemName: ${m.itemName}, quantity: ${m.quantity}, isChecked: ${m.isCheck.value}');
            }
          } else {
            PackageListSpecGlobal.set(PackageListResult()); // 重設為空的 result
            print('No PackageListSpec spec found for model $model');
          }
          await logFile.writeAsString('成功獲取 PackageListSpec\n',
              mode: FileMode.append);
        } catch (e, st) {
          await logFile.writeAsString('獲取 PackageListSpec 失敗: $e\n',
              mode: FileMode.append);
          await logFile.writeAsString('堆疊追蹤: $st\n', mode: FileMode.append);
        }



        try {
          await logFile.writeAsString('嘗試獲取 FailCountsForDevice...\n',
              mode: FileMode.append);
          await fetchFailCountsForDevice(model, sn);
          await logFile.writeAsString('成功獲取 FailCountsForDevice\n',
              mode: FileMode.append);
        } catch (e, st) {
          await logFile.writeAsString('獲取 FailCountsForDevice 失敗: $e\n',
              mode: FileMode.append);
          await logFile.writeAsString('堆疊追蹤: $st\n', mode: FileMode.append);
        }

        try {
          await logFile.writeAsString('開始載入主要數據...\n', mode: FileMode.append);
          await loadFileHelper(sn, model).then((_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(context.tr('submit_success', args: [sn, model])),
                ),
              );
            }
          }).onError((e, st) async {
            await logFile.writeAsString('載入主要數據失敗: $e\n堆疊追蹤: $st\n',
                mode: FileMode.append);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('submit_fail', args: [sn, model])),
                ),
              );
            }
          });
        } catch (e, st) {
          await logFile.writeAsString('載入主要數據時發生意外錯誤: $e\n',
              mode: FileMode.append);
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
        Navigator.of(context).pop();
      }
    }
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
            // 🔽 Model Dropdown
            DropdownButtonFormField<String>(
              value: selectedModel,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: '選擇 Model (可選或手動輸入)',
                prefixIcon: const Icon(Icons.list),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              items: modelToSnMap.keys.map((model) {
                return DropdownMenuItem(
                  value: model,
                  child: Text(model),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedModel = value;
                  selectedSn = null;
                  _modelController.text = value ?? '';
                });
              },
            ),
            const SizedBox(height: 12),

            // 🔽 SN Dropdown
            DropdownButtonFormField<String>(
              value: selectedSn,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: '選擇 SN (可選或手動輸入)',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              items: selectedModel == null
                  ? []
                  : modelToSnMap[selectedModel!]!.map((sn) {
                return DropdownMenuItem(value: sn, child: Text(sn));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSn = value;
                  _snController.text = value ?? '';
                });
              },
            ),
            const SizedBox(height: 16),

            // 📝 原本的手動輸入區塊 - Model
            TextFormField(
              enabled: !isLoading,
              focusNode: _modelFocusNode,
              controller: _modelController,
              decoration: InputDecoration(
                labelText: context.tr('model_name'),
                hintText: context.tr('please_input_model_name'),
                prefixIcon: const Icon(Icons.text_fields),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.tr('please_input_model_name');
                }
                return null;
              },
              onFieldSubmitted: (value) {
                _snFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 16),

            // 📝 原本的手動輸入區塊 - SN
            TextFormField(
              enabled: !isLoading,
              focusNode: _snFocusNode,
              controller: _snController,
              decoration: InputDecoration(
                labelText: context.tr('sn'),
                hintText: context.tr('please_input_sn'),
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.tr('please_input_sn');
                }
                return null;
              },
              onFieldSubmitted: (value) async {
                if (!isLoading && _formKey.currentState!.validate()) {
                  await _submitForm();
                }
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
          onPressed: isLoading
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text(context.tr('cancel')),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    await _submitForm();
                  }
                },
          child: Text(context.tr('submit')),
        ),
      ],
    );
  }
}
