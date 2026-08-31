import 'package:flutter/material.dart';
import 'package:wl_components/src/toast/wl_toast_manager.dart';

enum WLToastPosition { top, center, bottom }

enum WLToastType { sequence, stack, replace }

class WLToast {
  static final WLToastManager _manager = WLToastManager();

  static void show(
    BuildContext context, {
    required String message,
    WLToastPosition position = WLToastPosition.bottom,
    WLToastType type = WLToastType.stack,
    Duration? duration,
    Color? backgroundColor,
    Color? textColor,
    Widget? icon,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? borderRadius,
    double? maxWidth,
    Duration? animationDuration,
  }) {
    _manager.show(
      context,
      message: message,
      position: position,
      type: type,
      duration: duration,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      maxWidth: maxWidth,
      animationDuration: animationDuration,
    );
  }

  static void dismissAll() {
    _manager.dismissAll();
  }
}
