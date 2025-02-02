import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';

class ModelNameAndSerialNumberTable extends StatelessWidget {
  final String model;
  final String sn;

  const ModelNameAndSerialNumberTable(
      {super.key, required this.model, required this.sn});

  @override
  Widget build(BuildContext context) {
    return StyledCard(
      title: 'Model Name & Serial Number',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Model Name : ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlueColor,
                ),
              ),
              Text(
                model,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.blackColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'SN : ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlueColor,
                ),
              ),
              Text(
                sn, // 這裡可以放入實際的 SN
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.blackColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  StyledCard buildStyledCard(String model, String sn) {
    return StyledCard(
      title: 'Model Name & Serial Number',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Model Name : ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlueColor,
                ),
              ),
              Text(
                model,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.blackColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'SN : ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlueColor,
                ),
              ),
              Text(
                sn, // 這裡可以放入實際的 SN
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.blackColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
