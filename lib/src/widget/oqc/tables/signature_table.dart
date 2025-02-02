import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';

class Signature extends StatefulWidget {
  final TextEditingController _picController;
  final TextEditingController _dateController;

  Signature(
      {super.key,
        TextEditingController? picController,
        TextEditingController? dateController})
      : _picController = picController ?? TextEditingController(),
        _dateController = dateController ?? TextEditingController();

  @override
  State<Signature> createState() => _SignatureState();
}

class _SignatureState extends State<Signature> {
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
  }

  @override
  Widget build(BuildContext context) {
    return StyledCard(
      title: 'Signature',
      content: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 100, // 固定標籤寬度
                child: const Text(
                  'PIC : ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlueColor,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget._picController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 100, // 固定標籤寬度
                child: const Text(
                  'Date : ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlueColor,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget._dateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
