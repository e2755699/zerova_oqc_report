import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/report/spec/account_data.dart';

class SignatureTable extends StatefulWidget {
  final TextEditingController _picController;
  final TextEditingController _dateController;

  SignatureTable(
      {super.key,
      TextEditingController? picController,
      TextEditingController? dateController})
      : _picController = picController ?? TextEditingController(),
        _dateController = dateController ?? TextEditingController();

  @override
  State<SignatureTable> createState() => _SignatureTableState();
}

class _SignatureTableState extends State<SignatureTable> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget._dateController.text =
            DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // 設定預設日期為今天
    widget._dateController.text =
        DateFormat('yyyy-MM-dd').format(_selectedDate);

    // 設定預設簽名人姓名為目前登入帳號對應的 name
    widget._picController.text = currentUser?['name'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return TableWrapper(
      title: context.tr('signature'),
      content: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 100, // 固定標籤寬度
                child: Text(
                  context.tr('name'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlueColor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  widget._picController.text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 100, // 固定標籤寬度
                child: Text(
                  context.tr('date'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlueColor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  widget._dateController.text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
