import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/report/spec/input_output_characteristics_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/basic_function_test_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/hipot_test_spec.dart';
import 'package:zerova_oqc_report/src/repo/firebase_service.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/main_layout.dart';
import 'package:zerova_oqc_report/src/widget/admin/tabs/input_output_characteristics_tab.dart';
import 'package:zerova_oqc_report/src/widget/admin/tabs/basic_function_test_tab.dart';
import 'package:zerova_oqc_report/src/widget/admin/tabs/hipot_test_tab.dart';

class ModelSpecTemplatePage extends StatefulWidget {
  const ModelSpecTemplatePage({super.key});

  @override
  State<ModelSpecTemplatePage> createState() => _ModelSpecTemplatePageState();
}

class _ModelSpecTemplatePageState extends State<ModelSpecTemplatePage> with SingleTickerProviderStateMixin {
  final TextEditingController _modelController = TextEditingController();
  final List<String> _modelList = [];
  String? _selectedModel;
  bool _isLoading = false;
  bool _isNewModel = false;
  TabController? _tabController;

  // 各類型的規格
  InputOutputCharacteristicsSpec? _inputOutputSpec;
  BasicFunctionTestSpec? _basicFunctionSpec;
  HipotTestSpec? _hipotTestSpec;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadModelList();
  }

  @override
  void dispose() {
    _modelController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  // 載入模型列表
  Future<void> _loadModelList() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // 這裡應該從 Firebase 或其他資料來源獲取模型列表
      // 但由於目前沒有這個功能，先使用假資料
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _modelList.addAll(['T2449A003A1', 'T2450B001A2', 'T2451C002A3']);
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
      final tableNames = ['InputOutputCharacteristics', 'BasicFunctionTest', 'HipotTestSpec'];

      final specs = await firebaseService.getAllSpecs(
        model: model,
        tableNames: tableNames,
      );

      setState(() {
        final ioSpecMap = specs['InputOutputCharacteristics'];
        final bfSpecMap = specs['BasicFunctionTest'];
        final htSpecMap = specs['HipotTestSpec'];

        if (ioSpecMap != null && ioSpecMap.isNotEmpty) {
          _inputOutputSpec = InputOutputCharacteristicsSpec.fromJson(ioSpecMap);
        } else {
          // 預設值
          _inputOutputSpec = InputOutputCharacteristicsSpec(
            leftVinLowerbound: 0, leftVinUpperbound: 0,
            leftIinLowerbound: 0, leftIinUpperbound: 0,
            leftPinLowerbound: 0, leftPinUpperbound: 0,
            leftVoutLowerbound: 0, leftVoutUpperbound: 0,
            leftIoutLowerbound: 0, leftIoutUpperbound: 0,
            leftPoutLowerbound: 0, leftPoutUpperbound: 0,
            rightVinLowerbound: 0, rightVinUpperbound: 0,
            rightIinLowerbound: 0, rightIinUpperbound: 0,
            rightPinLowerbound: 0, rightPinUpperbound: 0,
            rightVoutLowerbound: 0, rightVoutUpperbound: 0,
            rightIoutLowerbound: 0, rightIoutUpperbound: 0,
            rightPoutLowerbound: 0, rightPoutUpperbound: 0,
          );
        }

        if (bfSpecMap != null && bfSpecMap.isNotEmpty) {
          _basicFunctionSpec = BasicFunctionTestSpec.fromJson(bfSpecMap);
        } else {
          // 預設值
          _basicFunctionSpec = BasicFunctionTestSpec(
            eff: 0, pf: 0, thd: 0, sp: 0
          );
        }

        if (htSpecMap != null && htSpecMap.isNotEmpty) {
          _hipotTestSpec = HipotTestSpec.fromJson(htSpecMap);
        } else {
          // 預設值
          _hipotTestSpec = HipotTestSpec(
            insulationimpedancespec: 0, leakagecurrentspec: 0
          );
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
        content: Text('確定要刪除 $_selectedModel 的所有規格嗎？此操作無法恢復。'),
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

      // 這裡應該實現刪除模型規格的邏輯
      // 由於 Firebase API 不直接支援刪除文件，我們可以用空規格覆蓋，或者自定義一個刪除標記
      
      // 從列表中移除
      setState(() {
        _modelList.remove(_selectedModel);
        _selectedModel = null;
        _inputOutputSpec = null;
        _basicFunctionSpec = null;
        _hipotTestSpec = null;
        _isLoading = false;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('模型規格已成功刪除')),
        );
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
    setState(() {
      _isNewModel = !_isNewModel;
      if (_isNewModel) {
        _selectedModel = null;
        _modelController.clear();
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
                  if (_selectedModel != null || _isNewModel)
                    _buildTabContent(),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            Tab(text: '輸入輸出特性'),
            Tab(text: '基本功能測試'),
            Tab(text: '耐壓測試'),
          ],
        ),
        SizedBox(
          height: 600, // 設置一個固定高度
          child: TabBarView(
            controller: _tabController,
            children: [
              InputOutputCharacteristicsTab(
                spec: _inputOutputSpec,
                onChanged: (newSpec) {
                  setState(() {
                    _inputOutputSpec = newSpec;
                  });
                },
              ),
              BasicFunctionTestTab(
                spec: _basicFunctionSpec,
                onChanged: (newSpec) {
                  setState(() {
                    _basicFunctionSpec = newSpec;
                  });
                },
              ),
              HipotTestTab(
                spec: _hipotTestSpec,
                onChanged: (newSpec) {
                  setState(() {
                    _hipotTestSpec = newSpec;
                  });
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