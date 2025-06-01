import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/spec/psu_serial_numbers_spec.dart';
import 'package:zerova_oqc_report/src/widget/common/spec_input_field.dart';

class PsuSerialNumTab extends StatefulWidget {
  final PsuSerialNumSpec? spec;
  final Function(PsuSerialNumSpec) onChanged;

  const PsuSerialNumTab({
    super.key,
    required this.spec,
    required this.onChanged,
  });

  @override
  State<PsuSerialNumTab> createState() => _PsuSerialNumTabState();
}

class _PsuSerialNumTabState extends State<PsuSerialNumTab> {
  late PsuSerialNumSpec _spec;
  late TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _initializeSpec();
  }

  @override
  void didUpdateWidget(PsuSerialNumTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spec != oldWidget.spec) {
      _initializeSpec();
    }
  }

  void _initializeSpec() {
    _spec = widget.spec ?? PsuSerialNumSpec(qty: 12);

    // 初始化控制器
    _qtyController = TextEditingController(text: _spec.qty?.toString() ?? '12');

    // 添加監聽器
    _qtyController.addListener(() => _updateSpec('qty', _qtyController.text));
  }

  void _updateSpec(String field, String value) {
    final intValue = int.tryParse(value);

    PsuSerialNumSpec newSpec;

    switch (field) {
      case 'qty':
        newSpec = _spec.copyWith(qty: intValue);
        break;
      default:
        return;
    }

    _spec = newSpec;
    widget.onChanged(newSpec);
  }

  @override
  void dispose() {
    _qtyController.dispose();
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
              'PSU序號規格',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    LabeledSpecInputField(
                      label: 'PSU數量 (Qty)',
                      unit: '個',
                      controller: _qtyController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue.shade600),
                              const SizedBox(width: 8),
                              Text(
                                '說明',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• PSU數量: 設定此模型需要的PSU數量\n'
                            '• 預設值: 12個\n'
                            '• 此設定將影響PSU序號表格的顯示行數',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
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
