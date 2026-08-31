// Define all the styles of text used in the app

import 'package:wl_components/src/colors/wl_colors.dart';
import 'package:flutter/material.dart';

// Example
// Text('Test Screen', style: WLFont.normal.bold.onPrimaryColor)

// == ONEFONT Define all the styles of text used in the app ==

class WLFont {
  // font family
  static const String fontFamily = 'Inter';

  /// Size 14, weight 400, color textNeutralStrong
  static TextStyle get normal => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    color: WLColors.textNormal(),
  );

  /// Size 12, weight 400, color textNeutralStrong
  static TextStyle get small => normal.copyWith(fontSize: 12);

  /// Size 16, weight 400, color textNeutralStrong
  static TextStyle get medium => normal.copyWith(fontSize: 16);

  /// Size 18, weight 400, color textNeutralStrong
  static TextStyle get large => normal.copyWith(fontSize: 18);

  /// Size 20, weight 400, color textNeutralStrong
  static TextStyle get xlarge => normal.copyWith(fontSize: 20);

  /// Size 24, weight 400, color textNeutralStrong
  static TextStyle get doubleSmall => normal.copyWith(fontSize: 24);
}

// == TEXT STYLE COLOR ==

extension WLTextStyleColor on TextStyle {
  // Primary & On-Color Text
  TextStyle get primaryColor => copyWith(color: Color(0xFFFFFFFF));
  TextStyle get primaryMutedColor => copyWith(color: Color(0x99FFFFFF));
  TextStyle get primaryDefaultColor => copyWith(color: WLColors.primary());
  TextStyle get onPrimaryColor => copyWith(color: Color(0xFFFFFFFF));
  TextStyle get onBrightsColor => copyWith(color: Color(0xFF0F1319));

  // Neutral Text Scale
  TextStyle get neutralStrongColor => copyWith(color: Color(0xFF0F1319));
  TextStyle get neutralDarkerColor => copyWith(color: Color(0xFF323232));
  TextStyle get neutralMediumColor => copyWith(color: Color(0xFF394867));
  TextStyle get neutralLightColor => copyWith(color: Color(0xFF5E7699));
  TextStyle get neutralLighterColor => copyWith(color: Color(0xFFAEB9CD));
  TextStyle get neutralGrayColor => copyWith(color: Color(0xFF8B9CB2));
  TextStyle get neutralDarkColor => copyWith(color: Color(0xFF34404B));

  // Status & State Text
  TextStyle get disabledColor => copyWith(color: Color(0x4002173C));
  TextStyle get errorStrongColor => copyWith(color: Color(0xFFD82D2A));
  TextStyle get successStrongColor => copyWith(color: Color(0xFF07945F));
}

// == TEXT STYLE WEIGHT ==
extension WLTextStyleWeight on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  TextStyle get semibold => copyWith(fontWeight: FontWeight.w600);

  TextStyle get mediumWeight => copyWith(fontWeight: FontWeight.w500);

  TextStyle get lightWeight => copyWith(fontWeight: FontWeight.w300);
}

// == TEXT STYLE STYLE ==
extension WLTextStyleStyle on TextStyle {
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
}

// ==========  COPY WITH  ==========
extension WLTextStyleCopyWith on TextStyle {
  TextStyle copyWith({
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) => TextStyle(
    inherit: inherit,
    color: color ?? this.color,
    fontSize: fontSize,
    fontWeight: fontWeight ?? this.fontWeight,
    fontStyle: fontStyle ?? this.fontStyle,
    fontFamily: fontFamily,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
    textBaseline: textBaseline,
    height: height,
    leadingDistribution: leadingDistribution,
    locale: locale,
    foreground: foreground,
    background: background,
    shadows: shadows,
    fontFeatures: fontFeatures,
    decoration: decoration,
    decorationColor: decorationColor,
    decorationStyle: decorationStyle,
    decorationThickness: decorationThickness,
    debugLabel: debugLabel,
    fontFamilyFallback: fontFamilyFallback,
  );
}
