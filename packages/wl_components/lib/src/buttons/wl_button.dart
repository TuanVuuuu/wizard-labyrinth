import 'package:flutter/material.dart';
import 'package:wl_components/src/buttons/wl_elevated_button.dart';
import 'package:wl_components/src/colors/wl_colors.dart';
import 'package:wl_components/src/fonts/wl_font.dart';

enum WLButtonType { small, medium, large }

enum _WLButtonVariant { elevated, iconCapture }

class WLButton extends StatelessWidget {
  static const double _defaultButtonHeight = 50;
  static const double _defaultButtonRadius = 8;
  static const double _defaultLoadingSize = 20;

  static DateTime? _dateTime;

  final String text;
  final Function? onPressed;
  final List<Color>? colors;
  final bool enable;
  final bool isLoading;
  final bool showLoading;
  final bool isGradient;
  final bool isShow;
  final Color? colorText;
  final double borderRadiusBtn;
  final double? fontBtn;
  final double? height;
  final TextStyle? textStyle;
  final Border? border;
  final double? textScaleFactor;
  final double? width;

  final _WLButtonVariant _variant;
  final IconData? icons;
  final Color? iconBackgroundColor;
  final double sizeIcon;
  final double radius;
  final double iconPadding;
  final Color? iconTitleColor;
  final double? sizeBackGround;
  final Color? iconColor;
  final String? imgAsset;

  const WLButton(
    this.text,
    this.onPressed, {
    super.key,
    this.colors,
    this.enable = true,
    this.isLoading = false,
    this.showLoading = true,
    this.borderRadiusBtn = _defaultButtonRadius,
    this.colorText,
    this.isGradient = true,
    this.isShow = true,
    this.fontBtn,
    this.height,
    this.textStyle,
    this.border,
    this.textScaleFactor,
    this.width,
  }) : _variant = _WLButtonVariant.elevated,
       icons = null,
       iconBackgroundColor = null,
       sizeIcon = 30,
       radius = 30,
       iconPadding = 8,
       iconTitleColor = null,
       sizeBackGround = null,
       iconColor = null,
       imgAsset = null;

  const WLButton.iconCapture({
    super.key,
    required this.icons,
    required Function func,
    Color? colors,
    String title = '',
    this.sizeIcon = 30,
    this.radius = 30,
    double padding = 8.0,
    Color? textColor,
    this.sizeBackGround,
    this.iconColor,
    this.imgAsset,
  }) : text = title,
       onPressed = func,
       colors = null,
       enable = true,
       isLoading = false,
       showLoading = true,
       isGradient = true,
       isShow = true,
       colorText = null,
       borderRadiusBtn = _defaultButtonRadius,
       fontBtn = null,
       height = null,
       textStyle = null,
       border = null,
       textScaleFactor = null,
       width = null,
       _variant = _WLButtonVariant.iconCapture,
       iconBackgroundColor = colors,
       iconPadding = padding,
       iconTitleColor = textColor;

  List<Color> get _colors => colors ?? WLColors.primaryGradient();

  Color get _textColor => colorText ?? WLColors.white();

  Color get _iconColor => iconColor ?? WLColors.primary();

  TextStyle get _textStyle {
    final style = textStyle;
    if (style != null) {
      return style;
    }

    return WLFont.medium.mediumWeight.merge(
      TextStyle(color: _textColor, fontSize: fontBtn),
    );
  }

  BoxDecoration get _decoration {
    return BoxDecoration(
      gradient:
          isGradient
              ? LinearGradient(
                colors: _colors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
              : null,
      color: isGradient ? null : _colors.firstOrNull,
      borderRadius: BorderRadius.circular(borderRadiusBtn),
      border: border ?? const Border(),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_variant) {
      case _WLButtonVariant.iconCapture:
        return _buildIconCapture();
      case _WLButtonVariant.elevated:
        return _buildElevatedButton();
    }
  }

  Widget _buildElevatedButton() {
    final button = WLElevatedButton(
      title: text,
      height: height ?? _defaultButtonHeight,
      decoration: _decoration,
      onPressed: enable && !isLoading ? () => onPressed?.call() : null,
      isLoading: isLoading,
      showLoading: showLoading,
      textStyle: _textStyle,
      textScaleFactor: textScaleFactor,
      loadingBuilder: SizedBox(
        height: _defaultLoadingSize,
        width: _defaultLoadingSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          backgroundColor: WLColors.white(),
          valueColor: AlwaysStoppedAnimation<Color>(WLColors.statusError()),
        ),
      ),
    );

    final content = enable ? button : Opacity(opacity: 0.4, child: button);
    if (width == null) {
      return content;
    }
    return SizedBox(width: width, child: content);
  }

  Widget _buildIconCapture() {
    return _baseOnAction(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: sizeBackGround,
            width: sizeBackGround,
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: _buildIconCaptureVisual(),
          ),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                text,
                style: WLFont.normal.copyWith(
                  color: iconTitleColor ?? WLColors.textNormal(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconCaptureVisual() {
    final asset = imgAsset;
    if (asset != null) {
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        height: sizeIcon,
        width: sizeIcon,
      );
    }
    return Icon(icons, color: _iconColor, size: sizeIcon);
  }

  Widget _baseOnAction({required Function? onTap, required Widget child}) {
    return GestureDetector(
      onTap: () {
        final now = DateTime.now();
        final dateTime = _dateTime;
        if (dateTime == null ||
            now.difference(dateTime) > const Duration(seconds: 1)) {
          _dateTime = now;
          onTap?.call();
        }
      },
      child: child,
    );
  }
}
