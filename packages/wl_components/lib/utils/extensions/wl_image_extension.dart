import 'package:flutter/material.dart';

extension WLImageX on Image {
  Widget tintColor(Color color) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: this,
    );
  }
}
