import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';

class PsuSerialNumbersTable extends StatelessWidget {
  final Psuserialnumber data;

  const PsuSerialNumbersTable(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    final dataTable = StyledDataTable(
      columns: [
        OqcTableStyle.getDataColumn('No.'),
        const DataColumn(
          label: Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'S/N',
                  style: TableTextStyle.headerStyle,
                ),
                Text(
                  'Spec : 4',
                  style: TableTextStyle.headerStyle,
                ),
              ],
            ),
          ),
        ),
      ],
      rows: List.generate(
        4,
        (index) => DataRow(
          cells: [
            OqcTableStyle.getDataCell((index + 1).toString()),
            OqcTableStyle.getDataCell(data.psuSN[index].value),
          ],
        ),
      ),
    );

    return TableWrapper(
      title: 'PSU S/N',
      content: dataTable,
    );
  }

}
