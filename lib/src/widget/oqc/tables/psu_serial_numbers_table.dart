import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';

class PsuSerialNumbersTable extends StatelessWidget {
  final Psuserialnumber data;

  const PsuSerialNumbersTable(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return TableWrapper(
      title: 'PSU S/N',
      content: StyledDataTable(
      columns: [
        OqcTableStyle.getDataColumn('No.'),
        DataColumn(
          label: Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'S/N',
                  style: TableTextStyle.headerStyle(),
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  'Spec : 4',
                  style: TableTextStyle.headerStyle(),
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
    ),
    );
  }
}
