import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/spec/input_output_characteristics_spec.dart';
import 'package:zerova_oqc_report/src/widget/common/spec_input_field.dart';

class InputOutputCharacteristicsTab extends StatefulWidget {
  final InputOutputCharacteristicsSpec? spec;
  final Function(InputOutputCharacteristicsSpec) onChanged;

  const InputOutputCharacteristicsTab({
    super.key,
    required this.spec,
    required this.onChanged,
  });

  @override
  State<InputOutputCharacteristicsTab> createState() =>
      _InputOutputCharacteristicsTabState();
}

class _InputOutputCharacteristicsTabState
    extends State<InputOutputCharacteristicsTab> {
  late InputOutputCharacteristicsSpec _spec;

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeSpec();
  }

  @override
  void didUpdateWidget(InputOutputCharacteristicsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spec != oldWidget.spec) {
      _initializeSpec();
    }
  }

  void _initializeSpec() {
    _spec = widget.spec ??
        InputOutputCharacteristicsSpec(
          leftVinLowerbound: 0,
          leftVinUpperbound: 0,
          leftIinLowerbound: 0,
          leftIinUpperbound: 0,
          leftPinLowerbound: 0,
          leftPinUpperbound: 0,
          leftVoutLowerbound: 0,
          leftVoutUpperbound: 0,
          leftIoutLowerbound: 0,
          leftIoutUpperbound: 0,
          leftPoutLowerbound: 0,
          leftPoutUpperbound: 0,
          rightVinLowerbound: 0,
          rightVinUpperbound: 0,
          rightIinLowerbound: 0,
          rightIinUpperbound: 0,
          rightPinLowerbound: 0,
          rightPinUpperbound: 0,
          rightVoutLowerbound: 0,
          rightVoutUpperbound: 0,
          rightIoutLowerbound: 0,
          rightIoutUpperbound: 0,
          rightPoutLowerbound: 0,
          rightPoutUpperbound: 0,
          // 使用預設單位
          leftPinUnit: 'kVA',
          leftPoutUnit: 'kW',
          rightPinUnit: 'kVA',
          rightPoutUnit: 'kW',
        );

    // 初始化控制器
    _controllers.clear();

    // 左側輸入特性
    _initController('leftVinLowerbound', _spec.leftVinLowerbound);
    _initController('leftVinUpperbound', _spec.leftVinUpperbound);
    _initController('leftIinLowerbound', _spec.leftIinLowerbound);
    _initController('leftIinUpperbound', _spec.leftIinUpperbound);
    _initController('leftPinLowerbound', _spec.leftPinLowerbound);
    _initController('leftPinUpperbound', _spec.leftPinUpperbound);

    // 左側輸出特性
    _initController('leftVoutLowerbound', _spec.leftVoutLowerbound);
    _initController('leftVoutUpperbound', _spec.leftVoutUpperbound);
    _initController('leftIoutLowerbound', _spec.leftIoutLowerbound);
    _initController('leftIoutUpperbound', _spec.leftIoutUpperbound);
    _initController('leftPoutLowerbound', _spec.leftPoutLowerbound);
    _initController('leftPoutUpperbound', _spec.leftPoutUpperbound);

    // 右側輸入特性
    _initController('rightVinLowerbound', _spec.rightVinLowerbound);
    _initController('rightVinUpperbound', _spec.rightVinUpperbound);
    _initController('rightIinLowerbound', _spec.rightIinLowerbound);
    _initController('rightIinUpperbound', _spec.rightIinUpperbound);
    _initController('rightPinLowerbound', _spec.rightPinLowerbound);
    _initController('rightPinUpperbound', _spec.rightPinUpperbound);

    // 右側輸出特性
    _initController('rightVoutLowerbound', _spec.rightVoutLowerbound);
    _initController('rightVoutUpperbound', _spec.rightVoutUpperbound);
    _initController('rightIoutLowerbound', _spec.rightIoutLowerbound);
    _initController('rightIoutUpperbound', _spec.rightIoutUpperbound);
    _initController('rightPoutLowerbound', _spec.rightPoutLowerbound);
    _initController('rightPoutUpperbound', _spec.rightPoutUpperbound);
  }

  void _initController(String field, double value) {
    _controllers[field] = TextEditingController(text: value.toString());
    _controllers[field]!.addListener(() {
      _updateSpec(field, _controllers[field]!.text);
    });
  }

  void _updateSpec(String field, String value) {
    final doubleValue = double.tryParse(value) ?? 0.0;

    InputOutputCharacteristicsSpec newSpec;

    switch (field) {
      // 左側輸入特性
      case 'leftVinLowerbound':
        newSpec = _spec.copyWith(leftVinLowerbound: doubleValue);
        break;
      case 'leftVinUpperbound':
        newSpec = _spec.copyWith(leftVinUpperbound: doubleValue);
        break;
      case 'leftIinLowerbound':
        newSpec = _spec.copyWith(leftIinLowerbound: doubleValue);
        break;
      case 'leftIinUpperbound':
        newSpec = _spec.copyWith(leftIinUpperbound: doubleValue);
        break;
      case 'leftPinLowerbound':
        newSpec = _spec.copyWith(leftPinLowerbound: doubleValue);
        break;
      case 'leftPinUpperbound':
        newSpec = _spec.copyWith(leftPinUpperbound: doubleValue);
        break;

      // 左側輸出特性
      case 'leftVoutLowerbound':
        newSpec = _spec.copyWith(leftVoutLowerbound: doubleValue);
        break;
      case 'leftVoutUpperbound':
        newSpec = _spec.copyWith(leftVoutUpperbound: doubleValue);
        break;
      case 'leftIoutLowerbound':
        newSpec = _spec.copyWith(leftIoutLowerbound: doubleValue);
        break;
      case 'leftIoutUpperbound':
        newSpec = _spec.copyWith(leftIoutUpperbound: doubleValue);
        break;
      case 'leftPoutLowerbound':
        newSpec = _spec.copyWith(leftPoutLowerbound: doubleValue);
        break;
      case 'leftPoutUpperbound':
        newSpec = _spec.copyWith(leftPoutUpperbound: doubleValue);
        break;

      // 右側輸入特性
      case 'rightVinLowerbound':
        newSpec = _spec.copyWith(rightVinLowerbound: doubleValue);
        break;
      case 'rightVinUpperbound':
        newSpec = _spec.copyWith(rightVinUpperbound: doubleValue);
        break;
      case 'rightIinLowerbound':
        newSpec = _spec.copyWith(rightIinLowerbound: doubleValue);
        break;
      case 'rightIinUpperbound':
        newSpec = _spec.copyWith(rightIinUpperbound: doubleValue);
        break;
      case 'rightPinLowerbound':
        newSpec = _spec.copyWith(rightPinLowerbound: doubleValue);
        break;
      case 'rightPinUpperbound':
        newSpec = _spec.copyWith(rightPinUpperbound: doubleValue);
        break;

      // 右側輸出特性
      case 'rightVoutLowerbound':
        newSpec = _spec.copyWith(rightVoutLowerbound: doubleValue);
        break;
      case 'rightVoutUpperbound':
        newSpec = _spec.copyWith(rightVoutUpperbound: doubleValue);
        break;
      case 'rightIoutLowerbound':
        newSpec = _spec.copyWith(rightIoutLowerbound: doubleValue);
        break;
      case 'rightIoutUpperbound':
        newSpec = _spec.copyWith(rightIoutUpperbound: doubleValue);
        break;
      case 'rightPoutLowerbound':
        newSpec = _spec.copyWith(rightPoutLowerbound: doubleValue);
        break;
      case 'rightPoutUpperbound':
        newSpec = _spec.copyWith(rightPoutUpperbound: doubleValue);
        break;

      default:
        return;
    }

    _spec = newSpec;
    widget.onChanged(newSpec);
  }

  // 更新單位的方法
  void _updateUnit(String unitField, String unit) {
    InputOutputCharacteristicsSpec newSpec;

    switch (unitField) {
      case 'leftPinUnit':
        newSpec = _spec.copyWith(leftPinUnit: unit);
        break;
      case 'leftPoutUnit':
        newSpec = _spec.copyWith(leftPoutUnit: unit);
        break;
      case 'rightPinUnit':
        newSpec = _spec.copyWith(rightPinUnit: unit);
        break;
      case 'rightPoutUnit':
        newSpec = _spec.copyWith(rightPoutUnit: unit);
        break;
      default:
        return;
    }

    setState(() {
      _spec = newSpec;
    });
    widget.onChanged(newSpec);
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
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
              '輸入輸出特性規格',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // 單位選擇區域
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '單位設定',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  // Note: Unit selectors are now in left/right sections
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 左側規格
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '左側輸入特性',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              /*_buildRangeInputs(
                                  'Vin',
                                  'V',
                                  _controllers['leftVinLowerbound']!,
                                  _controllers['leftVinUpperbound']!),
                              _buildRangeInputs(
                                  'Iin',
                                  'A',
                                  _controllers['leftIinLowerbound']!,
                                  _controllers['leftIinUpperbound']!),*/
                              _buildRangeInputsWithUnitSelector(
                                  'Pin',
                                  _spec.leftPinUnit,
                                  _controllers['leftPinLowerbound']!,
                                  _controllers['leftPinUpperbound']!,
                                  ['kVA', 'kW'],
                                  'leftPinUnit'),
                              const SizedBox(height: 16),
                              Text(
                                '左側輸出特性',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              _buildRangeInputs(
                                  'Vout',
                                  'V',
                                  _controllers['leftVoutLowerbound']!,
                                  _controllers['leftVoutUpperbound']!),
                              _buildRangeInputs(
                                  'Iout',
                                  'A',
                                  _controllers['leftIoutLowerbound']!,
                                  _controllers['leftIoutUpperbound']!),
                              _buildRangeInputsWithUnitSelector(
                                  'Pout',
                                  _spec.leftPoutUnit,
                                  _controllers['leftPoutLowerbound']!,
                                  _controllers['leftPoutUpperbound']!,
                                  ['kW', 'kVA'],
                                  'leftPoutUnit'),
                            ],
                          ),
                        ),

                        const SizedBox(width: 32),

                        // 右側規格
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '右側輸入特性',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              /*_buildRangeInputs(
                                  'Vin',
                                  'V',
                                  _controllers['rightVinLowerbound']!,
                                  _controllers['rightVinUpperbound']!),
                              _buildRangeInputs(
                                  'Iin',
                                  'A',
                                  _controllers['rightIinLowerbound']!,
                                  _controllers['rightIinUpperbound']!),*/
                              _buildRangeInputsWithUnitSelector(
                                  'Pin',
                                  _spec.rightPinUnit,
                                  _controllers['rightPinLowerbound']!,
                                  _controllers['rightPinUpperbound']!,
                                  ['kVA', 'kW'],
                                  'rightPinUnit'),
                              const SizedBox(height: 16),
                              Text(
                                '右側輸出特性',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              _buildRangeInputs(
                                  'Vout',
                                  'V',
                                  _controllers['rightVoutLowerbound']!,
                                  _controllers['rightVoutUpperbound']!),
                              _buildRangeInputs(
                                  'Iout',
                                  'A',
                                  _controllers['rightIoutLowerbound']!,
                                  _controllers['rightIoutUpperbound']!),
                              _buildRangeInputsWithUnitSelector(
                                  'Pout',
                                  _spec.rightPoutUnit,
                                  _controllers['rightPoutLowerbound']!,
                                  _controllers['rightPoutUpperbound']!,
                                  ['kW', 'kVA'],
                                  'rightPoutUnit'),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildRangeInputs(
      String label,
      String unit,
      TextEditingController lowerController,
      TextEditingController upperController) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: RangeSpecInputField(
        label: '$label ($unit)',
        unit: unit,
        lowerController: lowerController,
        upperController: upperController,
        isRequired: true,
      ),
    );
  }

  // 新方法：帶有單位選擇器的範圍輸入欄位
  Widget _buildRangeInputsWithUnitSelector(
      String label,
      String currentUnit,
      TextEditingController lowerController,
      TextEditingController upperController,
      List<String> unitOptions,
      String unitField) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: currentUnit,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: unitOptions.map((unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _updateUnit(unitField, value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RangeSpecInputField(
            label: '',
            unit: currentUnit,
            lowerController: lowerController,
            upperController: upperController,
            isRequired: true,
          ),
        ],
      ),
    );
  }
}
