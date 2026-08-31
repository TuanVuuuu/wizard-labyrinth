import 'package:flutter/material.dart';
import 'package:wl_components/src/size/wl_padding.dart';
import 'package:wl_components/src/size/wl_radius.dart';
import 'package:wl_components/src/toast/wl_toast.dart';

class WLToastConfig {
  const WLToastConfig({
    this.message = '',
    this.position = WLToastPosition.bottom,
    this.duration = const Duration(seconds: 3),
    this.type = WLToastType.stack,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.padding = const EdgeInsets.symmetric(vertical: WLPadding.small),
    this.margin = const EdgeInsets.symmetric(vertical: WLPadding.small),
    this.borderRadius = WLRadius.small,
    this.maxWidth = 400.0,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  final String message;
  final WLToastPosition position;
  final Duration duration;
  final WLToastType type;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final double maxWidth;
  final Duration animationDuration;

  WLToastConfig copyWith({
    String? message,
    WLToastPosition? position,
    Duration? duration,
    WLToastType? type,
    Color? backgroundColor,
    Color? textColor,
    Widget? icon,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? borderRadius,
    double? maxWidth,
    Duration? animationDuration,
  }) {
    return WLToastConfig(
      message: message ?? this.message,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      icon: icon ?? this.icon,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      borderRadius: borderRadius ?? this.borderRadius,
      maxWidth: maxWidth ?? this.maxWidth,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}
