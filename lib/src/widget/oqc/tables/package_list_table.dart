import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:convert';
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/widget/common/camera_button.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/image_grid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/repo/sharepoint_uploader.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerova_oqc_report/src/report/spec/package_list_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/new_package_list_spec.dart.dart';


class ItemData {
  String name;
  String quantity;
  ValueNotifier<bool> isChecked;

  ItemData({this.name = '', this.quantity = '', bool isChecked = false})
      : isChecked = ValueNotifier(isChecked);
}

class CheckboxStateStorage {
  static Future<void> save(String sn, List<ItemData> items) async {
    final prefs = await SharedPreferences.getInstance();
    final data = items.map((item) => {
      'name': item.name,
      'isChecked': item.isChecked.value,
    }).toList();
    await prefs.setString('checkbox_state_$sn', jsonEncode(data));
  }

  static Future<Map<String, bool>> load(String sn) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('checkbox_state_$sn');
    if (str != null) {
      final List decoded = jsonDecode(str);
      return {
        for (var item in decoded)
          item['name'] as String: item['isChecked'] as bool,
      };
    }
    return {};
  }
}

final ValueNotifier<List<ItemData>> items = ValueNotifier<List<ItemData>>([]);

class PackageListTable extends StatelessWidget {
  final String sn;
  final String model;
  final PackageListResult data;

  const PackageListTable(
      this.data, {
        super.key,
        required this.sn,
        required this.model,
      });




  @override
  Widget build(BuildContext context) {
    if (!globalPackageListSpecInitialized) {
      final measurements = PackageListSpecGlobal.get().measurements;

      final initialItems = <ItemData>[];
      if (measurements.isNotEmpty) {
        CheckboxStateStorage.load(sn).then((savedCheckboxMap) {
          for (int i = 0; i < measurements.length; i++) {
            final m = measurements[i];
            final isChecked = savedCheckboxMap[m.itemName] ?? m.isCheck.value;

            print('itemName: ${m.itemName}, quantity: ${m.quantity}, isChecked: $isChecked');

            data.updateOrAddMeasurement(
              index: i,
              name: m.itemName,
              quantity: m.quantity,
              isChecked: isChecked,
            );

            initialItems.add(ItemData(
              name: m.itemName,
              quantity: m.quantity,
              isChecked: isChecked,
            ));
          }

          items.value = initialItems;
          globalPackageListSpecInitialized = true;
        });
      } else {
        globalPackageListSpecInitialized = true;
      }
    }

    return ValueListenableBuilder<int>(
      valueListenable: globalEditModeNotifier,
      builder: (context, editMode, _) {
        return ValueListenableBuilder<int>(
          valueListenable: permissions,
          builder: (context, permission, _) {
            final isEditable = editMode == 1 && (permission == 1 || permission == 2);
            //final isHeaderEditable = editMode == 1 && permission == 1;
            final isHeaderEditable = false;
            return TableWrapper(
              title: context.tr('package_list'),
              titleAction: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isHeaderEditable)
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Add Item',
                      onPressed: () {
                        items.value = List.from(items.value)..add(ItemData());
                      },
                    ),
                  if (isHeaderEditable)
                    IconButton(
                      icon: const Icon(Icons.remove),
                      tooltip: 'Remove Item',
                      onPressed: () {
                        if (items.value.isNotEmpty) {
                          final lastIndex = items.value.length - 1;
                          items.value = List.from(items.value)..removeLast();
                          data.removeMeasurementAt(lastIndex);
                        }
                      },
                    ),
                  /*IconButton(
                    icon: const Icon(Icons.cloud_download),
                    tooltip: 'Download to SharePoint',
                    onPressed: () {
                      //someFunction();F
                      SharePointUploader(uploadOrDownload: 2, sn: sn, model: '').startAuthorization(
                        categoryTranslations: {
                          "packageing_photo": "Packageing Photo ",
                          //"appearance_photo": "Appearance Photo ",
                          //"oqc_report": "OQC Report ",
                        },
                      );
                    },
                  ),*/
                  CameraButton(
                    sn: sn,
                    model: model,
                    packagingOrAttachment: 0,
                  ),
                ],
              ),

              content: Column(
                children: [
                  ValueListenableBuilder<List<ItemData>>(
                    valueListenable: items,
                    builder: (context, itemList, _) {
                      return Table(
                        border: TableBorder.all(color: AppColors.lightBlueColor),
                        children: [
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(child: Text('No.')),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(child: Text('Items')),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(child: Text('Q\'ty')),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(child: Text('Check')),
                              ),
                            ],
                          ),
                          ...itemList.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return TableRow(
                              children: [
                                // No.
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(child: Text('${index + 1}')),
                                ),
                                // Item (editable or plain text)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: isHeaderEditable
                                        ? TextFormField(
                                      initialValue: item.name,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                      ),
                                        onChanged: (val) {
                                          item.name = val;
                                          data.updateOrAddMeasurement(index: index, name: val);

                                          //PackageListSpecStore.instance.packageListData = data;
                                        }
                                    )
                                        : Text(item.name),
                                  ),
                                ),
                                // Quantity (editable or plain text)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: isHeaderEditable
                                        ? TextFormField(
                                      initialValue: item.quantity,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                      ),
                                        onChanged: (val) {
                                          item.quantity = val;
                                          data.updateOrAddMeasurement(index: index, quantity: val);
                                          //PackageListSpecStore.instance.packageListData = data;
                                        }
                                    )
                                        : Text(item.quantity),
                                  ),
                                ),
                                // Checkbox (always clickable)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: ValueListenableBuilder<bool>(
                                      valueListenable: item.isChecked,
                                      builder: (context, isChecked, _) {
                                        return Checkbox(
                                          value: isChecked,
                                            onChanged: (val) {
                                              item.isChecked.value = val ?? false;
                                              data.updateOrAddMeasurement(index: index, isChecked: val ?? false);
                                              CheckboxStateStorage.save(sn, items.value); // 加這行儲存 checkbox 狀態
                                              //PackageListSpecStore.instance.packageListData = data;
                                            }
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ImageGrid(
                    imagePath: 'Selected Photos\\$sn\\Packaging',
                    columns: 2,
                    cellHeight: 500,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
