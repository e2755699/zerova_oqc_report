import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/spec/basic_function_test_spec.dart';
import 'package:zerova_oqc_report/src/widget/common/spec_input_field.dart';

class BasicFunctionTestTab extends StatefulWidget {
  final BasicFunctionTestSpec? spec;
  final Function(BasicFunctionTestSpec) onChanged;

  const BasicFunctionTestTab({
    super.key,
    required this.spec,
    required this.onChanged,
  });

  @override
  State<BasicFunctionTestTab> createState() => _BasicFunctionTestTabState();
}

class _BasicFunctionTestTabState extends State<BasicFunctionTestTab> {
  late BasicFunctionTestSpec _spec;

  late TextEditingController _effController;
  late TextEditingController _pfController;
  late TextEditingController _thdController;
  late TextEditingController _spController;

  @override
  void initState() {
    super.initState();
    _initializeSpec();
  }

  @override
  void didUpdateWidget(BasicFunctionTestTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spec != oldWidget.spec) {
      _initializeSpec();
    }
  }

  void _initializeSpec() {
    _spec = widget.spec ?? BasicFunctionTestSpec(eff: 0, pf: 0, thd: 0, sp: 0);

    // 初始化控制器
    _effController = TextEditingController(text: _spec.eff.toString());
    _pfController = TextEditingController(text: _spec.pf.toString());
    _thdController = TextEditingController(text: _spec.thd.toString());
    _spController = TextEditingController(text: _spec.sp.toString());

    // 添加監聽器
    _effController.addListener(() => _updateSpec('eff', _effController.text));
    _pfController.addListener(() => _updateSpec('pf', _pfController.text));
    _thdController.addListener(() => _updateSpec('thd', _thdController.text));
    _spController.addListener(() => _updateSpec('sp', _spController.text));
  }

  void _updateSpec(String field, String value) {
    final doubleValue = double.tryParse(value) ?? 0.0;

    BasicFunctionTestSpec newSpec;

    switch (field) {
      case 'eff':
        newSpec = _spec.copyWith(eff: doubleValue);
        break;
      case 'pf':
        newSpec = _spec.copyWith(pf: doubleValue);
        break;
      case 'thd':
        newSpec = _spec.copyWith(thd: doubleValue);
        break;
      case 'sp':
        newSpec = _spec.copyWith(sp: doubleValue);
        break;
      default:
        return;
    }

    _spec = newSpec;
    widget.onChanged(newSpec);
  }

  @override
  void dispose() {
    _effController.dispose();
    _pfController.dispose();
    _thdController.dispose();
    _spController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本功能測試規格',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    LabeledSpecInputField(
                      label: '效率 (EFF)',
                      unit: '%',
                      controller: _effController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    LabeledSpecInputField(
                      label: '功率因素 (PF)',
                      unit: '',
                      controller: _pfController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    LabeledSpecInputField(
                      label: '總諧波失真 (THD)',
                      unit: '%',
                      controller: _thdController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    LabeledSpecInputField(
                      label: '待機功率 (SP)',
                      unit: 'W',
                      controller: _spController,
                      isRequired: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
