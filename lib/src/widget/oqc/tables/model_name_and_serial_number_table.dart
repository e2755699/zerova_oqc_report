import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';

class ModelNameAndSerialNumberTable extends StatelessWidget {
  final String model;
  final String sn;

  const ModelNameAndSerialNumberTable({
    super.key,
    required this.model,
    required this.sn,
  });

  @override
  Widget build(BuildContext context) {
    return TableWrapper(
      title: context.tr('basic_info'),
      content: StyledDataTable(
        columns: [
          OqcTableStyle.getDataColumn('Item'),
          OqcTableStyle.getDataColumn('Value'),
        ],
        rows: [
          DataRow(cells: [
            OqcTableStyle.getDataCell('Model Name'),
            OqcTableStyle.getDataCell(model),
          ]),
          DataRow(cells: [
            OqcTableStyle.getDataCell('Serial Number'),
            OqcTableStyle.getDataCell(sn),
          ]),
        ],
      ),
    );
  }
}
