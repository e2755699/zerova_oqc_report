import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/spec/hipot_test_spec.dart';

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
    _spec = widget.spec ?? HipotTestSpec(insulationimpedancespec: 0, leakagecurrentspec: 0);

    // 初始化控制器
    _insulationController = TextEditingController(text: _spec.insulationimpedancespec.toString());
    _leakageController = TextEditingController(text: _spec.leakagecurrentspec.toString());

    // 添加監聽器
    _insulationController.addListener(() => _updateSpec('insulation', _insulationController.text));
    _leakageController.addListener(() => _updateSpec('leakage', _leakageController.text));
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
                    _buildInputField('絕緣阻抗規格', 'MΩ', _insulationController),
                    const SizedBox(height: 16),
                    _buildInputField('漏電流規格', 'mA', _leakageController),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String unit, TextEditingController controller) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(label),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixText: unit,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
      ],
    );
  }
} 