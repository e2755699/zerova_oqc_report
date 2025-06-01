import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/spec/hipot_test_spec.dart';
import 'package:zerova_oqc_report/src/widget/common/spec_input_field.dart';

class HipotTestTab extends StatefulWidget {
  final HipotTestSpec? spec;
  final Function(HipotTestSpec) onChanged;

  const HipotTestTab({
    super.key,
    required this.spec,
    required this.onChanged,
  });

  @override
  State<HipotTestTab> createState() => _HipotTestTabState();
}

class _HipotTestTabState extends State<HipotTestTab> {
  late HipotTestSpec _spec;

  late TextEditingController _insulationController;
  late TextEditingController _leakageController;

  @override
  void initState() {
    super.initState();
    _initializeSpec();
  }

  @override
  void didUpdateWidget(HipotTestTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spec != oldWidget.spec) {
      _initializeSpec();
    }
  }

  void _initializeSpec() {
    _spec = widget.spec ??
        HipotTestSpec(insulationimpedancespec: 0, leakagecurrentspec: 0);

    // 初始化控制器
    _insulationController =
        TextEditingController(text: _spec.insulationimpedancespec.toString());
    _leakageController =
        TextEditingController(text: _spec.leakagecurrentspec.toString());

    // 添加監聽器
    _insulationController.addListener(
        () => _updateSpec('insulation', _insulationController.text));
    _leakageController
        .addListener(() => _updateSpec('leakage', _leakageController.text));
  }

  void _updateSpec(String field, String value) {
    final doubleValue = double.tryParse(value) ?? 0.0;

    HipotTestSpec newSpec;

    switch (field) {
      case 'insulation':
        newSpec = _spec.copyWith(insulationimpedancespec: doubleValue);
        break;
      case 'leakage':
        newSpec = _spec.copyWith(leakagecurrentspec: doubleValue);
        break;
      default:
        return;
    }

    _spec = newSpec;
    widget.onChanged(newSpec);
  }

  @override
  void dispose() {
    _insulationController.dispose();
    _leakageController.dispose();
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
              '耐壓測試規格',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    LabeledSpecInputField(
                      label: '絕緣阻抗規格',
                      unit: 'MΩ',
                      controller: _insulationController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    LabeledSpecInputField(
                      label: '漏電流規格',
                      unit: 'mA',
                      controller: _leakageController,
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
