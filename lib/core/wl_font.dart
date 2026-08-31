import 'package:flutter/material.dart';

import 'wl_colors.dart';

class WLFont {
  WLFont._();

  static const TextStyle display = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: WLColors.mist,
    decoration: TextDecoration.none,
  );

  static const TextStyle large = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: WLColors.mist,
    decoration: TextDecoration.none,
  );

  static const TextStyle medium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: WLColors.mist,
    decoration: TextDecoration.none,
  );

  static const TextStyle small = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: WLColors.mist,
    decoration: TextDecoration.none,
  );
}

extension WLTextStyleX on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  TextStyle get onPrimaryColor => copyWith(color: WLColors.cavernDeep);
}
