import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/test_function.dart';
import 'package:go_router/go_router.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/image_grid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';

class PackageListTable extends StatelessWidget {
  final PackageListResult data;

  const PackageListTable(this.data, {super.key});

  List<String> get headers => data.header;

  @override
  Widget build(BuildContext context) {
    final cameraButton = Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: const Icon(Icons.camera_alt),
        onPressed: () => context.push('/camera'),
        tooltip: '開啟相機',
        iconSize: 28,
        color: AppColors.primaryColor,
      ),
    );

    return StyledCard(
      title: context.tr('package_list'),
      titleAction: cameraButton,
      content: Column(
        children: [
          Table(
            border: TableBorder.all(),
            children: [
              TableRow(
                children: headers.map((header) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text(header)),
                )).toList(),
              ),
              ...data.datas.asMap().entries.map((entry) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Text('${entry.key + 1}')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Text(entry.value.name)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Text(entry.value.spec.toString())),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: ValueListenableBuilder(
                          key: GlobalKey(debugLabel: 'checkbox_${entry.value.key}'),
                          valueListenable: entry.value.isCheck,
                          builder: (context, value, _) => Checkbox(
                            value: value,
                            onChanged: (isCheck) {
                              entry.value.toggle();
                            },
                            activeColor: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 20),
          const ImageGrid(
            imagePath: 'C:\\Users\\USER\\Pictures\\All',
            rows: 2,
            columns: 4,
            cellHeight: 100,
          ),
        ],
      ),
    );
  }

  static Future<pw.ImageProvider?> imageFromPath(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return pw.MemoryImage(bytes);
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
    }
    return null;
  }
}
