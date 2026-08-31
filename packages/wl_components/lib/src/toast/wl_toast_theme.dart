import 'package:flutter/material.dart';
import 'package:wl_components/src/size/wl_padding.dart';
import 'package:wl_components/src/size/wl_radius.dart';
import 'package:wl_components/src/toast/wl_toast_config.dart';

class WLToastTheme {
  const WLToastTheme({
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(vertical: WLPadding.small),
    this.margin = const EdgeInsets.symmetric(vertical: WLPadding.small),
    this.borderRadius = WLRadius.small,
    this.maxWidth = 400.0,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  final Color textColor;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final double maxWidth;
  final Duration animationDuration;

  WLToastConfig getDefaultConfig() {
    return WLToastConfig(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      maxWidth: maxWidth,
      animationDuration: animationDuration,
    );
  }
}
