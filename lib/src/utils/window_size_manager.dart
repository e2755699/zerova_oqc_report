import 'package:flutter/material.dart';

class WindowSizeManager {
  static double? _aspectRatio;

  static void updateSize(Size size) {
    _aspectRatio = size.width / size.height;
  }

  static double getFontSizeMultiplier() {
    if (_aspectRatio == null) return 1.0;
    return _aspectRatio! < 1 ? 2 / 3 : 1.0;
  }
}
