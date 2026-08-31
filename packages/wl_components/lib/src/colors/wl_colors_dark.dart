import 'package:flutter/material.dart';
import 'package:wl_components/src/colors/wl_colors_palette.dart';

/// Bảng màu dark (đồng bộ token với `AppColors` app CIC).
class WLColorsDark implements WLColorsPalette {
  WLColorsDark._();

  static final WLColorsDark instance = WLColorsDark._();

  Color _primary = const Color(0xFF3e4161);
  List<Color> _primaryGradient = const [Color(0xFF3e4161), Color(0xFF3e4161)];

  void update({Color? primary, List<Color>? primaryGradient}) {
    if (primary != null) {
      _primary = primary;
    }
    if (primaryGradient != null) {
      _primaryGradient = primaryGradient;
    }
    if (_primaryGradient.isEmpty) {
      _primaryGradient = [_primary, _primary];
    }
  }

  @override
  Color primary() => _primary;

  @override
  List<Color> primaryGradient() => _primaryGradient;

  @override
  Color black() => const Color(0xFF000000);

  @override
  Color white() => const Color(0xFFFFFFFF);

  @override
  Color transparent() => const Color(0x00000000);

  @override
  Color divider() => const Color(0xFF4A5568);

  @override
  Color dropdownBackground() => const Color(0xFF3e4161);

  @override
  Color dropdownIsSelected() => const Color(0xFF005BAA);

  @override
  Color edtBorderUnfocused() => const Color(0x33FFFFFF);

  @override
  Color edtBorderFocused() => const Color(0xFFE8E8E8);

  @override
  Color statusError() => const Color(0xFF6B3F44);

  @override
  Color statusSuccess() => const Color(0xFF3F6151);

  @override
  Color statusInfo() => const Color(0xFF3E4161);

  @override
  Color btnPrimaryDisabled() => const Color(0xFF2b3f58);

  @override
  Color btnPrimaryDisabledChild() => const Color(0xFF8393A0);

  @override
  Color textNormal() => const Color(0xFFFFFFFF);

  @override
  Color textNeutralLight() => const Color(0xB3FFFFFF);

  @override
  Color textNeutralLighter() => const Color(0xFF8393A0);

  @override
  Color textNeutral() => const Color(0xB3FFFFFF);

  @override
  Color textDisabled() => const Color(0xFF9d9d9d);

  @override
  Color toastDefaultBackground() => const Color(0xff101A2B);
}
