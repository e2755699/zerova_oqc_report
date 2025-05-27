import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/widget/common/camera_button.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/image_grid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/repo/sharepoint_uploader.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';
import 'package:zerova_oqc_report/src/report/spec/package_list_spec.dart';
import 'package:flutter/services.dart';

class PackageListTable extends StatelessWidget {
  final String sn;
  final String model;
  final PackageListResult data;

  const PackageListTable(this.data, {super.key, required this.sn, required this.model});

  List<String> get headers => data.header;

  void someFunction() {
    final spec = globalPackageListSpec;
    if (spec == null) {
      print("globalPackageListSpec 尚未初始化");
      return;
    }
    print('--- PackageListSpec ---');
    print('RFID Card: ${spec.rfidcard} (${spec.rfidcardspec})');
    print('Product Certificate Card: ${spec.productcertificatecard} (${spec.productcertificatecardspec})');
    print('Screw Assy M4*12: ${spec.screwassym4} (${spec.screwassym4spec})');
    print('Bolts Cover: ${spec.boltscover} (${spec.boltscoverspec})');
    print('User Manual: ${spec.usermanual} (${spec.usermanualspec})');
    print('-----------------------');
  }

  String _defaultIfEmptyString(String? value, String defaultValue) {
    return (value == null || value.isEmpty) ? defaultValue : value;
  }

  int _defaultIfEmptyInt(int? value, int defaultValue) {
    return (value == null) ? defaultValue : value;
  }

  Map<int, String> get _defaultSpecNames {
    final spec = globalPackageListSpec;
    return {
      1: _defaultIfEmptyString(spec?.rfidcard, "RFID Card"),
      2: _defaultIfEmptyString(spec?.productcertificatecard, "Product Certificate Card"),
      3: _defaultIfEmptyString(spec?.screwassym4, "Screw Assy M4*12"),
      4: _defaultIfEmptyString(spec?.boltscover, "Bolts Cover"),
      5: _defaultIfEmptyString(spec?.usermanual, "User Manual"),
    };
  }

  Map<int, int> get _defaultSpecValues {
    final spec = globalPackageListSpec;
    return {
      6: _defaultIfEmptyInt(spec?.rfidcardspec, 2),
      7: _defaultIfEmptyInt(spec?.productcertificatecardspec, 1),
      8: _defaultIfEmptyInt(spec?.screwassym4spec, 22),
      9: _defaultIfEmptyInt(spec?.boltscoverspec, 4),
      10: _defaultIfEmptyInt(spec?.usermanualspec, 1),
    };
  }


  void initializeGlobalSpec() {
    final specNames = _defaultSpecNames;
    final specValues = _defaultSpecValues;

    globalPackageListSpec = PackageListSpec(
      rfidcard: specNames[1] ?? "RFID Card",
      productcertificatecard: specNames[2] ?? "Product Certificate Card",
      screwassym4: specNames[3] ?? "Screw Assy M4*12",
      boltscover: specNames[4] ?? "Bolts Cover",
      usermanual: specNames[5] ?? "User Manual",
      rfidcardspec: specValues[6] ?? 2,
      productcertificatecardspec: specValues[7] ?? 1,
      screwassym4spec: specValues[8] ?? 22,
      boltscoverspec: specValues[9] ?? 4,
      usermanualspec: specValues[10] ?? 1,
    );
    //print("globalPackageListSpec initialized: ${globalPackageListSpec}");
  }

  @override
  Widget build(BuildContext context) {
    if (!globalPackageListSpecInitialized) {
      initializeGlobalSpec();
      someFunction();
      globalPackageListSpecInitialized = true;
    } else {
      print("globalPackageListSpec 已存在，不執行初始化");
    }
    return ValueListenableBuilder<int>(
      valueListenable: globalEditModeNotifier,
      builder: (context, editMode, _) {
        return ValueListenableBuilder<int>(
          valueListenable: permissions,
          builder: (context, permission, _) {
            final isEditable = editMode == 1 && (permission == 1 || permission == 2);
            final isHeaderEditable = editMode == 1 && permission == 1;
            return TableWrapper(
              title: context.tr('package_list'),
              titleAction: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.cloud_download),
                    tooltip: 'Download to SharePoint',
                    onPressed: () {
                      SharePointUploader(uploadOrDownload: 2, sn: sn, model: '').startAuthorization(
                        categoryTranslations: {
                          "packageing_photo": "Packageing Photo ",
                        },
                      );
                    },
                  ),
                  CameraButton(
                    sn: sn,
                    model: model,
                    packagingOrAttachment: 0,
                  ),
                ],
              ),
              content: Column(
                children: [
                  Table(
                    border: TableBorder.all(color: AppColors.lightBlueColor),
                    children: [
                      TableRow(
                        children: headers
                            .map((header) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text(header)),
                        ))
                            .toList(),
                      ),
                      ...data.datas.asMap().entries.map((entry) {
                        return TableRow(
                          children: [
                            // No.
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text('${entry.key + 1}')),
                            ),
                            // Item
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: isHeaderEditable
                                    ? TextFormField(
                                  initialValue: _defaultSpecNames[entry.key + 1],
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(6)),
                                    ),
                                  ),
                                  keyboardType: TextInputType.text,
                                  onChanged: (val) {
                                    switch (entry.key + 1) {
                                      case 1:
                                        globalPackageListSpec = globalPackageListSpec?.copyWith(rfidcard: val);
                                        break;
                                      case 2:
                                        globalPackageListSpec = globalPackageListSpec?.copyWith(productcertificatecard: val);
                                        break;
                                      case 3:
                                        globalPackageListSpec = globalPackageListSpec?.copyWith(screwassym4: val);
                                        break;
                                      case 4:
                                        globalPackageListSpec = globalPackageListSpec?.copyWith(boltscover: val);
                                        break;
                                      case 5:
                                        globalPackageListSpec = globalPackageListSpec?.copyWith(usermanual: val);
                                        break;
                                    }
                                  },
                                )
                                    : Text(_defaultSpecNames[entry.key + 1] ?? ''),
                              ),
                            ),

                            // Q'ty
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: isHeaderEditable
                                    ? SizedBox(
                                  width: 120, // 你可以調整這個寬度
                                  height: 36,
                                  child: TextFormField(
                                    initialValue: _defaultSpecValues[entry.key + 6]?.toString() ?? '',
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    onChanged: (val) {
                                      final parsed = int.tryParse(val);
                                      if (parsed != null) {
                                        switch (entry.key + 6) {
                                          case 6:
                                            globalPackageListSpec = globalPackageListSpec?.copyWith(rfidcardspec: parsed);
                                            break;
                                          case 7:
                                            globalPackageListSpec = globalPackageListSpec?.copyWith(productcertificatecardspec: parsed);
                                            break;
                                          case 8:
                                            globalPackageListSpec = globalPackageListSpec?.copyWith(screwassym4spec: parsed);
                                            break;
                                          case 9:
                                            globalPackageListSpec = globalPackageListSpec?.copyWith(boltscoverspec: parsed);
                                            break;
                                          case 10:
                                            globalPackageListSpec = globalPackageListSpec?.copyWith(usermanualspec: parsed);
                                            break;
                                        }
                                      }
                                    },
                                  ),
                                )
                                    : Text(_defaultSpecValues[entry.key + 6]?.toString() ?? ''),
                              ),
                            ),
                            // Checkbox
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
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ImageGrid(
                    imagePath: 'Selected Photos\\$sn\\Packaging',
                    columns: 4,
                    cellHeight: 100,
                  ),
                ],
              ),
            );
          },
        );
      },
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
