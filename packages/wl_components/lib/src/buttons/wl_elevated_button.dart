import 'package:flutter/material.dart';

class WLElevatedButton extends StatelessWidget {
  const WLElevatedButton({
    super.key,
    required this.title,
    required this.height,
    required this.decoration,
    required this.onPressed,
    required this.isLoading,
    required this.showLoading,
    required this.textStyle,
    required this.loadingBuilder,
    this.textScaleFactor,
  });

  final String title;
  final double height;
  final BoxDecoration decoration;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool showLoading;
  final TextStyle textStyle;
  final Widget loadingBuilder;
  final double? textScaleFactor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: decoration,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading && showLoading) {
      return loadingBuilder;
    }

    final scale = textScaleFactor;
    return Text(
      title,
      style: textStyle,
      textAlign: TextAlign.center,
      textScaler: scale == null ? null : TextScaler.linear(scale),
    );
  }
}
