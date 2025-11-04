import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/report/spec/input_output_characteristics_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/basic_function_test_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/hipot_test_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/psu_serial_numbers_spec.dart';
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/repo/firebase_service.dart';
import 'package:zerova_oqc_report/src/repo/sharepoint_uploader.dart';
import 'package:zerova_oqc_report/src/widget/common/main_layout.dart';
import 'package:zerova_oqc_report/src/widget/admin/tabs/input_output_characteristics_tab.dart';
import 'package:zerova_oqc_report/src/widget/admin/tabs/basic_function_test_tab.dart';
import 'package:zerova_oqc_report/src/widget/admin/tabs/hipot_test_tab.dart';
import 'package:zerova_oqc_report/src/widget/admin/tabs/psu_serial_num_tab.dart';
import 'package:zerova_oqc_report/src/widget/admin/tabs/package_list_tab.dart';
import 'package:zerova_oqc_report/src/widget/admin/tabs/package_photo_manager_tab.dart';
import 'package:zerova_oqc_report/src/widget/admin/tabs/photo_manager_tab.dart';

class ModelSpecTemplatePage extends StatefulWidget {
  const ModelSpecTemplatePage({super.key});

  @override
  State<ModelSpecTemplatePage> createState() => _ModelSpecTemplatePageState();
}

class _ModelSpecTemplatePageState extends State<ModelSpecTemplatePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _modelController = TextEditingController();
  final List<String> _modelList = [];
  String? _selectedModel;
  bool _isLoading = false;
  bool _isNewModel = false;
  TabController? _tabController;
  //List<String> deletedFilesFromChild = [];
  int _currentTabIndex = 0;

  // 各類型的規格
  InputOutputCharacteristicsSpec? _inputOutputSpec;
  BasicFunctionTestSpec? _basicFunctionSpec;
  HipotTestSpec? _hipotTestSpec;
  PsuSerialNumSpec? _psuSerialNumSpec;
  PackageListResult? _packageListSpec;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController!.addListener(_onTabChanged);
    _loadModelList();
  }

  @override
  void dispose() {
    _modelController.dispose();
    _copyTargetModelController.dispose();
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController!.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController!.index;
      });
    }
  }

  // 載入模型列表
  Future<void> _loadModelList() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 從Firebase獲取模型列表
      final firebaseService = FirebaseService();
      final models = await firebaseService.getModelList();

      setState(() {
        _modelList.addAll(models);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入模型列表失敗: $e')),
        );
      }
    }
  }

  // 載入特定模型的規格
  Future<void> _loadModelSpecs(String model) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final firebaseService = FirebaseService();
      final tableNames = [
        'InputOutputCharacteristics',
        'BasicFunctionTest',
        'HipotTestSpec',
        'PsuSerialNumSpec'
      ];

      final specs = await firebaseService.getAllSpecs(
        model: model,
        tableNames: tableNames,
      );

      // 載入 PackageListSpec
      final packageListResult = await fetchPackageListSpec(model);

      setState(() {
        final ioSpecMap = specs['InputOutputCharacteristics'];
        final bfSpecMap = specs['BasicFunctionTest'];
        final htSpecMap = specs['HipotTestSpec'];
        final psuSpecMap = specs['PsuSerialNumSpec'];

        if (ioSpecMap != null && ioSpecMap.isNotEmpty) {
          _inputOutputSpec = InputOutputCharacteristicsSpec.fromJson(ioSpecMap);
        } else {
          // 根據電壓電流功率.txt的預設值
          _inputOutputSpec = InputOutputCharacteristicsSpec(
            // Left Side
            leftVinLowerbound: 187,
            leftVinUpperbound: 253,
            leftIinLowerbound: 0,
            leftIinUpperbound: 230,
            leftPinLowerbound: 0,
            leftPinUpperbound: 130,
            leftVoutLowerbound: 931,
            leftVoutUpperbound: 969,
            leftIoutLowerbound: 123,
            leftIoutUpperbound: 129,
            leftPoutLowerbound: 118,
            leftPoutUpperbound: 122,

            // Right Side
            rightVinLowerbound: 187,
            rightVinUpperbound: 253,
            rightIinLowerbound: 0,
            rightIinUpperbound: 230,
            rightPinLowerbound: 0,
            rightPinUpperbound: 130,
            rightVoutLowerbound: 931,
            rightVoutUpperbound: 969,
            rightIoutLowerbound: 123,
            rightIoutUpperbound: 129,
            rightPoutLowerbound: 118,
            rightPoutUpperbound: 122,
          );
        }

        if (bfSpecMap != null && bfSpecMap.isNotEmpty) {
          _basicFunctionSpec = BasicFunctionTestSpec.fromJson(bfSpecMap);
        } else {
          // 根據基本功能測試.txt的預設值
          _basicFunctionSpec = BasicFunctionTestSpec(
              eff: 94, // 效率 94%
              pf: 0.99, // 功率因子 0.99
              thd: 5, // 總諧波失真 5%
              sp: 100 // 軟啟動時間 100ms
              );
        }

        if (htSpecMap != null && htSpecMap.isNotEmpty) {
          _hipotTestSpec = HipotTestSpec.fromJson(htSpecMap);
        } else {
          // 根據hipot.txt的預設值
          _hipotTestSpec = HipotTestSpec(
              insulationimpedancespec: 10, // 絕緣阻抗規格 10 MΩ
              leakagecurrentspec: 10 // 漏電流規格 10 mA
              );
        }

        if (psuSpecMap != null && psuSpecMap.isNotEmpty) {
          _psuSerialNumSpec = PsuSerialNumSpec.fromJson(psuSpecMap);
        } else {
          // 根據PSU SN.txt的預設值
          _psuSerialNumSpec = PsuSerialNumSpec(qty: 12 // PSU數量預設為12
              );
        }

        if (packageListResult != null) {
          _packageListSpec = packageListResult;
        } else {
          // 建立預設的 PackageListResult
          _packageListSpec = PackageListResult();
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入模型規格失敗: $e')),
        );
      }
    }
  }

  // 保存模型規格
  Future<void> _saveModelSpecs() async {
    if (_selectedModel == null && !_isNewModel) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先選擇或新增一個模型')),
      );
      return;
    }

    final model = _isNewModel ? _modelController.text : _selectedModel!;

    if (model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('模型名稱不能為空')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final firebaseService = FirebaseService();

      // 保存 InputOutputCharacteristics 規格
      if (_inputOutputSpec != null) {
        await firebaseService.addOrUpdateSpec(
          model: model,
          tableName: 'InputOutputCharacteristics',
          spec: _inputOutputSpec!.toJson(),
        );
      }

      // 保存 BasicFunctionTest 規格
      if (_basicFunctionSpec != null) {
        await firebaseService.addOrUpdateSpec(
          model: model,
          tableName: 'BasicFunctionTest',
          spec: _basicFunctionSpec!.toJson(),
        );
      }

      // 保存 HipotTestSpec 規格
      if (_hipotTestSpec != null) {
        await firebaseService.addOrUpdateSpec(
          model: model,
          tableName: 'HipotTestSpec',
          spec: _hipotTestSpec!.toJson(),
        );
      }

      // 保存 PsuSerialNumSpec 規格
      if (_psuSerialNumSpec != null) {
        await firebaseService.addOrUpdateSpec(
          model: model,
          tableName: 'PsuSerialNumSpec',
          spec: _psuSerialNumSpec!.toJson(),
        );
      }

      // 保存 PackageListSpec 規格
      if (_packageListSpec != null) {
        await uploadPackageListSpec(
          model: model,
          tableName: 'PackageListSpec',
          packageListResult: _packageListSpec!,
        );
      }

      //bill4
      // 上傳比對照片
      if (model != null) {
        await SharePointUploader(uploadOrDownload: 5, sn: '', model: model).startAuthorization(
          categoryTranslations: {
            "compare_photo": "Compare Photo ",
          },
        );
      }
      if (model != null) {
        await SharePointUploader(uploadOrDownload: 8, sn: '', model: model).startAuthorization(
          categoryTranslations: {
            "compare_photo": "Compare Photo ",
          },
        );
      }

      // 如果是新模型，添加到列表中
      if (_isNewModel && !_modelList.contains(model)) {
        setState(() {
          _modelList.add(model);
          _selectedModel = model;
          _isNewModel = false;
        });
      }

      setState(() {
        _isLoading = false;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('模型規格 $model 已成功保存')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存模型規格失敗: $e')),
        );
      }
    }
  }

  // 刪除模型規格
  Future<void> _deleteModelSpecs() async {
    if (_selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先選擇一個模型')),
      );
      return;
    }

    // 確認刪除
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text(
            '確定要刪除 $_selectedModel 的所有規格嗎？此操作無法恢復。\n\n將刪除以下內容：\n• PSU序號規格\n• 輸入輸出特性規格\n• 基本功能測試規格\n• 耐壓測試規格\n• 配件包規格\n• 比對照片\n• 相關的失敗計數記錄'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('刪除'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final firebaseService = FirebaseService();

      // 刪除模型的所有規格文件
      final deleteSpecsSuccess = await firebaseService.deleteAllModelSpecs(
        model: _selectedModel!,
      );

      //bill5
      // 刪除比對照片
      SharePointUploader(uploadOrDownload: 6, sn: '', model: _selectedModel!).startAuthorization(
        categoryTranslations: {
          "compare_photo": "Compare Photo ",
        },
      );

      // 檢查刪除結果
      if (deleteSpecsSuccess) {
        // 從本地列表中移除模型
        setState(() {
          _modelList.remove(_selectedModel);
          final deletedModel = _selectedModel;
          _selectedModel = null;
          _inputOutputSpec = null;
          _basicFunctionSpec = null;
          _hipotTestSpec = null;
          _psuSerialNumSpec = null;
          _packageListSpec = null;
          _isLoading = false;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('模型 $_selectedModel 的所有規格已成功刪除')),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });

        // 顯示部分成功的訊息
        String message = '刪除完成，但有些項目可能失敗：';
        if (!deleteSpecsSuccess) {
          message += '\n• 規格文件刪除失敗';
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('刪除模型規格失敗: $e')),
        );
      }
    }
  }

  // 刪除上傳照片清單
  /*void onDeletedFilesUpdated(List<String> deletedFiles) {
    setState(() {
      deletedFilesFromChild = deletedFiles;
    });
    print("父元件收到刪除檔案列表： $deletedFilesFromChild");
  }*/

  // 切換到新增模型模式
  void _toggleNewModelMode() {
    setState(() {
    _isNewModel = !_isNewModel;
    if (_isNewModel) {
        _selectedModel = null;
        _modelController.clear();
        _inputOutputSpec = InputOutputCharacteristicsSpec(
          // Left Side
          leftVinLowerbound: 187,
          leftVinUpperbound: 253,
          leftIinLowerbound: 0,
          leftIinUpperbound: 230,
          leftPinLowerbound: 0,
          leftPinUpperbound: 130,
          leftVoutLowerbound: 931,
          leftVoutUpperbound: 969,
          leftIoutLowerbound: 123,
          leftIoutUpperbound: 129,
          leftPoutLowerbound: 118,
          leftPoutUpperbound: 122,

          // Right Side
          rightVinLowerbound: 187,
          rightVinUpperbound: 253,
          rightIinLowerbound: 0,
          rightIinUpperbound: 230,
          rightPinLowerbound: 0,
          rightPinUpperbound: 130,
          rightVoutLowerbound: 931,
          rightVoutUpperbound: 969,
          rightIoutLowerbound: 123,
          rightIoutUpperbound: 129,
          rightPoutLowerbound: 118,
          rightPoutUpperbound: 122,
        );

        _basicFunctionSpec = BasicFunctionTestSpec(
            eff: 94, // 效率 94%
            pf: 0.99, // 功率因子 0.99
            thd: 5, // 總諧波失真 5%
            sp: 100 // 軟啟動時間 100ms
            );

        _hipotTestSpec = HipotTestSpec(
            insulationimpedancespec: 10, // 絕緣阻抗規格 10 MΩ
            leakagecurrentspec: 10 // 漏電流規格 10 mA
            );
        _psuSerialNumSpec = PsuSerialNumSpec(qty: 12 // PSU數量預設為12
            );

        _packageListSpec = PackageListResult(); // 建立新的 PackageListResult

        _isLoading = false;
    }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: context.tr('model_spec_template'),
      showBackButton: true,
      floatingActionButton: _buildFABs(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildModelSelector(),
                  const SizedBox(height: 20),
                  if (_selectedModel != null || _isNewModel) _buildTabContent(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  bool _isDuplicateModel = false; // 新增一個變數放在 State 裡
  final TextEditingController _copyTargetModelController = TextEditingController(); // 複製對話框的目標模型控制器

  // 顯示複製規格對話框
  void _showCopySpecDialog() {
    String? sourceModel = _selectedModel;

    if (sourceModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先選擇一個來源模型')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        String? selectedSourceModel = sourceModel;
        bool isDuplicate = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.copy, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('從現有模型複製規格'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '來源模型：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedSourceModel,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '選擇來源模型',
                      ),
                      items: _modelList.map((model) {
                        return DropdownMenuItem<String>(
                          value: model,
                          child: Text(model),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedSourceModel = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '目標模型名稱：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _copyTargetModelController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: '輸入新模型名稱',
                        hintText: '例如：EV600',
                        errorText: isDuplicate ? '⚠️ 此模型已存在' : null,
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          isDuplicate = _modelList.contains(value.trim());
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Colors.blue),
                              SizedBox(width: 4),
                              Text(
                                '將複製以下規格：',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            '• PSU序號規格\n• 輸入輸出特性規格\n• 基本功能測試規格\n• 耐壓測試規格\n• 配件包規格',
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '⚠️ 注意：照片不會被複製，需要重新上傳',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _copyTargetModelController.clear();
                    Navigator.of(context).pop();
                  },
                  child: Text(context.tr('cancel')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isDuplicate ||
                          _copyTargetModelController.text.trim().isEmpty ||
                          selectedSourceModel == null
                      ? null
                      : () {
                          final targetModel = _copyTargetModelController.text.trim();
                          Navigator.of(context).pop();
                          _copyModelSpecs(
                            sourceModel: selectedSourceModel!,
                            targetModel: targetModel,
                          );
                        },
                  child: const Text('確認複製'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 複製模型規格
  Future<void> _copyModelSpecs({
    required String sourceModel,
    required String targetModel,
  }) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 載入來源模型的規格
      final firebaseService = FirebaseService();
      final tableNames = [
        'InputOutputCharacteristics',
        'BasicFunctionTest',
        'HipotTestSpec',
        'PsuSerialNumSpec'
      ];

      final specs = await firebaseService.getAllSpecs(
        model: sourceModel,
        tableNames: tableNames,
      );

      // 載入來源模型的 PackageListSpec
      final sourcePackageListResult = await fetchPackageListSpec(sourceModel);

      // 複製規格到目標模型
      // 1. 複製 InputOutputCharacteristics
      final ioSpecMap = specs['InputOutputCharacteristics'];
      if (ioSpecMap != null && ioSpecMap.isNotEmpty) {
        await firebaseService.addOrUpdateSpec(
          model: targetModel,
          tableName: 'InputOutputCharacteristics',
          spec: ioSpecMap,
        );
      }

      // 2. 複製 BasicFunctionTest
      final bfSpecMap = specs['BasicFunctionTest'];
      if (bfSpecMap != null && bfSpecMap.isNotEmpty) {
        await firebaseService.addOrUpdateSpec(
          model: targetModel,
          tableName: 'BasicFunctionTest',
          spec: bfSpecMap,
        );
      }

      // 3. 複製 HipotTestSpec
      final htSpecMap = specs['HipotTestSpec'];
      if (htSpecMap != null && htSpecMap.isNotEmpty) {
        await firebaseService.addOrUpdateSpec(
          model: targetModel,
          tableName: 'HipotTestSpec',
          spec: htSpecMap,
        );
      }

      // 4. 複製 PsuSerialNumSpec
      final psuSpecMap = specs['PsuSerialNumSpec'];
      if (psuSpecMap != null && psuSpecMap.isNotEmpty) {
        await firebaseService.addOrUpdateSpec(
          model: targetModel,
          tableName: 'PsuSerialNumSpec',
          spec: psuSpecMap,
        );
      }

      // 5. 複製 PackageListSpec（需要深度複製）
      if (sourcePackageListResult != null) {
        // 建立新的 PackageListResult 並複製所有 measurements
        final targetPackageListResult = PackageListResult();
        for (int i = 0; i < sourcePackageListResult.measurements.length; i++) {
          final sourceMeasurement = sourcePackageListResult.measurements[i];
          targetPackageListResult.updateOrAddMeasurement(
            index: i,
            name: sourceMeasurement.itemName,
            quantity: sourceMeasurement.quantity,
            isChecked: sourceMeasurement.isCheck.value,
          );
        }
        await uploadPackageListSpec(
          model: targetModel,
          tableName: 'PackageListSpec',
          packageListResult: targetPackageListResult,
        );
      }

      // 更新本地狀態：將目標模型添加到列表並載入規格
      setState(() {
        if (!_modelList.contains(targetModel)) {
          _modelList.add(targetModel);
        }
        _selectedModel = targetModel;
        _isNewModel = false;
        _isLoading = false;
      });

      // 載入複製後的規格到 UI
      await _loadModelSpecs(targetModel);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ 已成功從 $sourceModel 複製規格到 $targetModel'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('複製規格失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _copyTargetModelController.clear();
    }
  }

  Widget _buildModelSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '模型選擇',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (!_isNewModel) ...[
                  Expanded(
                    child: Autocomplete<String>(
                      displayStringForOption: (option) => option,
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return _modelList;
                        }
                        // Filter models based on search text
                        return _modelList.where((model) {
                          return model
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (value) {
                        setState(() {
                          _selectedModel = value;
                        });
                        _loadModelSpecs(value);
                      },
                      fieldViewBuilder: (
                        context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,
                      ) {
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: '選擇模型',
                            hintText: '輸入模型名稱搜尋...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: textEditingController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    tooltip: '清除',
                                    onPressed: () {
                                      textEditingController.clear();
                                      setState(() {
                                        _selectedModel = null;
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {}); // Trigger rebuild to update clear button visibility
                          },
                          onSubmitted: (value) {
                            onFieldSubmitted();
                            // If user types exact model name and presses Enter, select it
                            if (_modelList.contains(value) && _selectedModel != value) {
                              setState(() {
                                _selectedModel = value;
                              });
                              _loadModelSpecs(value);
                            }
                          },
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(8),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 200,
                                maxWidth: 400,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  final isSelected = option == _selectedModel;
                                  return InkWell(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.blue.shade50
                                            : null,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade200,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              option,
                                              style: TextStyle(
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isSelected
                                                    ? Colors.blue
                                                    : Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                              Icons.check,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _modelController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: '輸入新模型名稱',
                            errorText: _isDuplicateModel ? '⚠️ 此模型已存在' : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _isDuplicateModel = _modelList.contains(value.trim());
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_isNewModel) {
                      final newModel = _modelController.text.trim();
                      final isDuplicate = _modelList.contains(newModel);

                      if (isDuplicate) {
                        setState(() {
                          _isDuplicateModel = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ 此模型名稱已存在，請輸入其他名稱'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // 可以新增模型的邏輯放這邊
                      setState(() {
                        _modelList.add(newModel);
                        _selectedModel = newModel;
                        _isNewModel = false;
                        _isDuplicateModel = false;
                        _modelController.clear();
                      });
                    } else {
                      _toggleNewModelMode();
                    }
                  },
                  icon: Icon(_isNewModel ? Icons.list : Icons.add),
                  label: Text(_isNewModel ? '選擇現有模型' : '新增模型'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(width: 8),
                // 複製規格按鈕
                Tooltip(
                  message: '從現有模型複製規格',
                  child: ElevatedButton.icon(
                    onPressed: _selectedModel != null && !_isNewModel
                        ? _showCopySpecDialog
                        : null,
                    icon: const Icon(Icons.copy),
                    label: const Text('複製規格'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTabContent() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'PSU序號'),
            Tab(text: '輸入輸出特性'),
            Tab(text: '基本功能測試'),
            Tab(text: '耐壓測試'),
            Tab(text: '配件包'),
            Tab(text: '上傳配件包比對照片'),
            Tab(text: '上傳外觀檢查比對照片'),
          ],
        ),
        SizedBox(
          height: 600, // 設置一個固定高度
          child: TabBarView(
            controller: _tabController,
            children: [
              PsuSerialNumTab(
                spec: _psuSerialNumSpec,
                onChanged: (newSpec) {
                  _psuSerialNumSpec = newSpec;
                },
              ),
              InputOutputCharacteristicsTab(
                spec: _inputOutputSpec,
                onChanged: (newSpec) {
                  _inputOutputSpec = newSpec;
                },
              ),
              BasicFunctionTestTab(
                spec: _basicFunctionSpec,
                onChanged: (newSpec) {
                  _basicFunctionSpec = newSpec;
                },
              ),
              HipotTestTab(
                spec: _hipotTestSpec,
                onChanged: (newSpec) {
                  _hipotTestSpec = newSpec;
                },
              ),
              PackageListTab(
                spec: _packageListSpec,
                onChanged: (newSpec) {
                  _packageListSpec = newSpec;
                },
              ),
              PackagePhotoManagerTab(
                selectedModel: _isNewModel ? _modelController.text : (_selectedModel ?? ''),
                //onDeletedFilesChanged: onDeletedFilesUpdated,
              ),
              PhotoManagerTab(
                selectedModel: _isNewModel ? _modelController.text : (_selectedModel ?? ''),
                //onDeletedFilesChanged: onDeletedFilesUpdated,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFABs() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'save',
            backgroundColor: Colors.green,
            onPressed: _saveModelSpecs,
            tooltip: '保存',
            child: const Icon(Icons.save),
          ),
          const SizedBox(height: 16),
          if (_selectedModel != null)
            FloatingActionButton(
              heroTag: 'delete',
              backgroundColor: Colors.red,
              onPressed: _deleteModelSpecs,
              tooltip: '刪除',
              child: const Icon(Icons.delete),
            ),
        ],
      ),
    );
  }
}
