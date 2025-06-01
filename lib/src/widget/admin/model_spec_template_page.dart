import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/report/spec/input_output_characteristics_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/basic_function_test_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/hipot_test_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/psu_serial_numbers_spec.dart';
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/repo/firebase_service.dart';
import 'package:zerova_oqc_report/src/widget/common/main_layout.dart';
import 'package:zerova_oqc_report/src/widget/admin/tabs/input_output_characteristics_tab.dart';
import 'package:zerova_oqc_report/src/widget/admin/tabs/basic_function_test_tab.dart';
import 'package:zerova_oqc_report/src/widget/admin/tabs/hipot_test_tab.dart';
import 'package:zerova_oqc_report/src/widget/admin/tabs/psu_serial_num_tab.dart';
import 'package:zerova_oqc_report/src/widget/admin/tabs/package_list_tab.dart';

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
    _tabController = TabController(length: 5, vsync: this);
    _tabController!.addListener(_onTabChanged);
    _loadModelList();
  }

  @override
  void dispose() {
    _modelController.dispose();
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
            '確定要刪除 $_selectedModel 的所有規格嗎？此操作無法恢復。\n\n將刪除以下內容：\n• 輸入輸出特性規格\n• 基本功能測試規格\n• 耐壓測試規格\n• PSU序號規格\n• 配件包規格\n• 相關的失敗計數記錄'),
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

  // 切換到新增模型模式
  void _toggleNewModelMode() {
    _isNewModel = !_isNewModel;
    if (_isNewModel) {
      setState(() {
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
      });
    }
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
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '選擇模型',
                      ),
                      value: _selectedModel,
                      items: _modelList.map((model) {
                        return DropdownMenuItem<String>(
                          value: model,
                          child: Text(model),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedModel = value;
                        });
                        if (value != null) {
                          _loadModelSpecs(value);
                        }
                      },
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: TextField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '輸入新模型名稱',
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _toggleNewModelMode,
                  icon: Icon(_isNewModel ? Icons.list : Icons.add),
                  label: Text(_isNewModel ? '選擇現有模型' : '新增模型'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
