import 'package:flutter/material.dart';
import 'package:wl_components/src/colors/wl_colors_palette.dart';

/// Bảng màu light (đồng bộ token với `AppColors` app CIC).
class WLColorsLight implements WLColorsPalette {
  WLColorsLight._();

  static final WLColorsLight instance = WLColorsLight._();

  Color _primary = const Color(0xFF005993);
  List<Color> _primaryGradient = const [Color(0xFF005baa), Color(0xFF005baa)];

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
  Color divider() => const Color(0xFFE8E8E8);

  @override
  Color dropdownBackground() => const Color(0xFFFFFFFF);

  @override
  Color dropdownIsSelected() => const Color(0xFF005BAA);

  @override
  Color edtBorderUnfocused() => const Color(0xFF8294A2);

  @override
  Color edtBorderFocused() => const Color(0xFF111111);

  @override
  Color statusError() => const Color(0xFFB02A37);

  @override
  Color statusSuccess() => const Color(0xFF0F8B5E);

  @override
  Color statusInfo() => const Color(0xFF005993);

  @override
  Color btnPrimaryDisabled() => const Color(0xFFf2f6f9);

  @override
  Color btnPrimaryDisabledChild() => const Color(0xFF9BA3B1);

  @override
  Color textNormal() => const Color(0xFF111111);

  @override
  Color textNeutralLight() => const Color(0xFF58647A);

  @override
  Color textNeutralLighter() => const Color(0xFF8193A1);

  @override
  Color textNeutral() => const Color(0xFF666666);

  @override
  Color textDisabled() => const Color(0xFF9d9d9d);

  @override
  Color toastDefaultBackground() => const Color(0xFF25273f);
}
