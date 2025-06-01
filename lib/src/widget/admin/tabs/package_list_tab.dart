import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';

class PackageListTab extends StatefulWidget {
  final PackageListResult? spec;
  final Function(PackageListResult) onChanged;

  const PackageListTab({
    super.key,
    required this.spec,
    required this.onChanged,
  });

  @override
  State<PackageListTab> createState() => _PackageListTabState();
}

class _PackageListTabState extends State<PackageListTab> {
  late PackageListResult _spec;
  final List<TextEditingController> _itemControllers = [];
  final List<TextEditingController> _quantityControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeSpec();
  }

  @override
  void didUpdateWidget(PackageListTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spec != oldWidget.spec) {
      _disposeControllers();
      _initializeSpec();
    }
  }

  void _initializeSpec() {
    _spec = widget.spec ?? PackageListResult();

    // 如果沒有任何測量項目，添加一些預設項目
    if (_spec.measurements.isEmpty) {
      _addDefaultItems();
    }

    // 初始化控制器
    _initializeControllers();
  }

  void _addDefaultItems() {
    final defaultItems = [
      {'itemName': 'PSU主體', 'quantity': '1'},
      {'itemName': '電源線', 'quantity': '1'},
      {'itemName': '使用手冊', 'quantity': '1'},
      {'itemName': '保固書', 'quantity': '1'},
      {'itemName': '包裝盒', 'quantity': '1'},
    ];

    for (int i = 0; i < defaultItems.length; i++) {
      _spec.updateOrAddMeasurement(
        index: i,
        name: defaultItems[i]['itemName']!,
        quantity: defaultItems[i]['quantity']!,
        isChecked: false,
      );
    }
  }

  void _initializeControllers() {
    for (int i = 0; i < _spec.measurements.length; i++) {
      final measurement = _spec.measurements[i];

      final itemController = TextEditingController(text: measurement.itemName);
      final quantityController =
          TextEditingController(text: measurement.quantity);

      itemController.addListener(
          () => _updateMeasurement(i, 'itemName', itemController.text));
      quantityController.addListener(
          () => _updateMeasurement(i, 'quantity', quantityController.text));

      _itemControllers.add(itemController);
      _quantityControllers.add(quantityController);
    }
  }

  void _updateMeasurement(int index, String field, String value) {
    if (index < _spec.measurements.length) {
      switch (field) {
        case 'itemName':
          _spec.measurements[index].itemName = value;
          break;
        case 'quantity':
          _spec.measurements[index].quantity = value;
          break;
      }
      widget.onChanged(_spec);
    }
  }

  void _addNewItem() {
    final index = _spec.measurements.length;
    _spec.updateOrAddMeasurement(
      index: index,
      name: '',
      quantity: '1',
      isChecked: false,
    );

    final itemController = TextEditingController();
    final quantityController = TextEditingController(text: '1');

    itemController.addListener(
        () => _updateMeasurement(index, 'itemName', itemController.text));
    quantityController.addListener(
        () => _updateMeasurement(index, 'quantity', quantityController.text));

    _itemControllers.add(itemController);
    _quantityControllers.add(quantityController);

    setState(() {});
    widget.onChanged(_spec);
  }

  void _removeItem(int index) {
    if (index < _spec.measurements.length) {
      _spec.removeMeasurementAt(index);

      if (index < _itemControllers.length) {
        _itemControllers[index].dispose();
        _itemControllers.removeAt(index);
      }

      if (index < _quantityControllers.length) {
        _quantityControllers[index].dispose();
        _quantityControllers.removeAt(index);
      }

      setState(() {});
      widget.onChanged(_spec);
    }
  }

  void _disposeControllers() {
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    for (final controller in _quantityControllers) {
      controller.dispose();
    }
    _itemControllers.clear();
    _quantityControllers.clear();
  }

  @override
  void dispose() {
    _disposeControllers();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '包裝清單規格',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: _addNewItem,
                  icon: const Icon(Icons.add),
                  label: const Text('新增項目'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(8)),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                            width: 40,
                            child: Text('No.',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 3,
                            child: Text('項目名稱',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 1,
                            child: Text('數量',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(
                            width: 60,
                            child: Text('操作',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(8)),
                      ),
                      child: ListView.builder(
                        itemCount: _spec.measurements.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: index < _spec.measurements.length - 1
                                  ? Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade300))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: TextField(
                                      controller:
                                          index < _itemControllers.length
                                              ? _itemControllers[index]
                                              : null,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        hintText: '輸入項目名稱',
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: TextField(
                                      controller:
                                          index < _quantityControllers.length
                                              ? _quantityControllers[index]
                                              : null,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        hintText: '數量',
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _removeItem(index),
                                    tooltip: '刪除此項目',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
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
                      Icon(Icons.info_outline, color: Colors.blue.shade600),
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
                    '• 包裝清單: 設定此模型的包裝清單項目和數量\n'
                    '• 可以新增、編輯或刪除包裝項目\n'
                    '• 每個項目包含名稱和數量\n'
                    '• 此設定將用於 OQC 報告的包裝清單表格',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
