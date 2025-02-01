import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class CameraButton extends StatelessWidget {
  final String sn;
  final int packagingOrAttachment;

  const CameraButton({
    super.key,
    required this.sn,
    required this.packagingOrAttachment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: const Icon(Icons.camera_alt),
        onPressed: () => context.push('/camera', extra: {
          'sn': sn,
          'packagingOrAttachment': packagingOrAttachment,
        }),
        tooltip: context.tr('open_camera'),
        iconSize: 28,
        color: Colors.blue,
      ),
    );
  }
} 