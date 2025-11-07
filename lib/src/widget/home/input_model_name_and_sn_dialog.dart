import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/mixin/load_file_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/repo/firebase_service.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/report/spec/new_package_list_spec.dart.dart';
import 'package:zerova_oqc_report/src/report/spec/package_list_spec.dart';

enum InputMode {
  dropdown,
  manual,
}

InputMode? _selectedMode = InputMode.dropdown;

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

  @override
  void initState() {
    super.initState();

    _loadModelToSnMap();
  }

  Future<void> _loadModelToSnMap() async {
    final map = await fetchModelToSnMapFromFirestore();
    if (mounted) {
      setState(() {
        modelToSnMap.clear();
        modelToSnMap.addAll(map);
      });
    }
  }

  Future<void> _confirmDeleteSn() async {
    if (selectedModel == null || selectedSn == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('delete_sn_confirm_title')),
        content: Text(context.tr('delete_sn_confirm_message',
            args: [selectedSn!, selectedModel!])),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteSn();
    }
  }

  Future<void> _deleteSn() async {
    if (selectedModel == null || selectedSn == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final success =
          await deleteSnFromTodo(model: selectedModel!, sn: selectedSn!);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(context.tr('delete_sn_success', args: [selectedSn!])),
              backgroundColor: Colors.green,
            ),
          );
          // Reset SN selection and reload data
          setState(() {
            selectedSn = null;
            _snController.clear();
          });
          await _loadModelToSnMap();

          // If the model has no more SNs, also clear model selection
          if (!modelToSnMap.containsKey(selectedModel!) ||
              modelToSnMap[selectedModel!]!.isEmpty) {
            setState(() {
              selectedModel = null;
              _modelController.clear();
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('delete_sn_fail', args: [selectedSn!])),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(context.tr('delete_sn_fail', args: [selectedSn ?? ''])),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
          await logFile.writeAsString('嘗試獲取 PsuSerialNumSpec...\n',
              mode: FileMode.append);
          await fetchAndPsuSerialNumSpecs(model);
          await logFile.writeAsString('成功獲取 PsuSerialNumSpec\n',
              mode: FileMode.append);
        } catch (e, st) {
          await logFile.writeAsString('獲取 PsuSerialNumSpec 失敗: $e\n',
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
            final packageListResult =
                packageListResultFromSpecDataWithUpdate(spec);
            PackageListSpecGlobal.set(packageListResult);
            final measurements2 = PackageListSpecGlobal.get().measurements;

            for (int i = 0; i < measurements2.length; i++) {
              final m = measurements2[i];
              print(
                  'itemName: ${m.itemName}, quantity: ${m.quantity}, isChecked: ${m.isCheck.value}');

              data.updateOrAddMeasurement(
                index: i,
                name: m.itemName,
                quantity: m.quantity,
                isChecked: m.isCheck.value,
              );
            }

            final measurements = packageListResult.measurements;
            for (var m in measurements) {
              print(
                  'itemName: ${m.itemName}, quantity: ${m.quantity}, isChecked: ${m.isCheck.value}');
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
            // 🔘 切換模式按鈕
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedMode = InputMode.dropdown;
                    });
                  },
                  child: Text(context.tr('search_list')),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedMode = InputMode.manual;
                    });
                  },
                  child: Text(context.tr('manual_input_model_sn')),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 🔽 下拉選單模式
            if (_selectedMode == InputMode.dropdown) ...[
              DropdownButtonFormField<String>(
                value: selectedModel,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: context.tr('model_name'),
                  hintText: context.tr('select_model'),
                  prefixIcon: const Icon(Icons.list),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
                items: modelToSnMap.keys.map((model) {
                  return DropdownMenuItem(value: model, child: Text(model));
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
              DropdownButtonFormField<String>(
                value: selectedSn,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: context.tr('sn'),
                  hintText: context.tr('select_sn'),
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
                items: selectedModel == null
                    ? []
                    : modelToSnMap[selectedModel!]!
                        .map((sn) =>
                            DropdownMenuItem(value: sn, child: Text(sn)))
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSn = value;
                    _snController.text = value ?? '';
                  });
                },
              ),
            ],

            // 📝 手動輸入模式
            if (_selectedMode == InputMode.manual) ...[
              TextFormField(
                enabled: !isLoading,
                focusNode: _modelFocusNode,
                controller: _modelController,
                decoration: InputDecoration(
                  labelText: context.tr('model_name'),
                  hintText: context.tr('please_input_model_name'),
                  prefixIcon: const Icon(Icons.text_fields),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? context.tr('please_input_model_name')
                    : null,
                onFieldSubmitted: (_) => _snFocusNode.requestFocus(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                enabled: !isLoading,
                focusNode: _snFocusNode,
                controller: _snController,
                decoration: InputDecoration(
                  labelText: context.tr('sn'),
                  hintText: context.tr('please_input_sn'),
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? context.tr('please_input_sn')
                    : null,
                onFieldSubmitted: (_) async {
                  if (!isLoading && _formKey.currentState!.validate()) {
                    await _submitForm();
                  }
                },
              ),
            ],

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
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(context.tr('cancel')),
        ),
        if (selectedModel != null &&
            selectedSn != null &&
            _selectedMode == InputMode.dropdown)
          ElevatedButton(
            onPressed: isLoading ? null : () => _confirmDeleteSn(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.tr('delete')),
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
