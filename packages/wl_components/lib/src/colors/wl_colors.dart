// Define all the colors used in the app

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:wl_components/src/colors/wl_colors_dark.dart';
import 'package:wl_components/src/colors/wl_colors_light.dart';
import 'package:wl_components/src/colors/wl_colors_palette.dart';

/// Resolver dark mode do app host inject (GetX, ThemeService, v.v.).
bool Function() _isDarkModeResolver = () => false;

/// Gọi một lần khi khởi động app để `WLColors` tự chọn light/dark.
void configureWLColors({required bool Function() isDarkMode}) {
  _isDarkModeResolver = isDarkMode;
}

final WLColors = _WLColors();

class _WLColors {
  bool get _isDarkMode => _isDarkModeResolver();

  WLColorsPalette get _palette =>
      _isDarkMode ? WLColorsDark.instance : WLColorsLight.instance;

  Color primary() => _palette.primary();

  List<Color> primaryGradient() => _palette.primaryGradient();

  Color primaryLighter() => primary().withValues(alpha: 0.1);

  Color black() => _palette.black();

  Color white() => _palette.white();

  Color transparent() => _palette.transparent();

  Color divider() => _palette.divider();

  Color dropdownBackground() => _palette.dropdownBackground();

  Color dropdownIsSelected() => _palette.dropdownIsSelected();

  Color edtBorderUnfocused() => _palette.edtBorderUnfocused();

  Color edtBorderFocused() => _palette.edtBorderFocused();

  Color statusError() => _palette.statusError();
  Color statusSuccess() => _palette.statusSuccess();
  Color statusInfo() => _palette.statusInfo();

  Color btnPrimaryPressed() => primary().withValues(alpha: 0.2);

  Color btnPrimaryDisabled() => _palette.btnPrimaryDisabled();

  Color btnPrimaryDisabledChild() => _palette.btnPrimaryDisabledChild();

  Color textNormal() => _palette.textNormal();

  Color textNeutralLight() => _palette.textNeutralLight();

  Color textNeutralLighter() => _palette.textNeutralLighter();

  Color textNeutral() => _palette.textNeutral();

  Color textDisabled() => _palette.textDisabled();

  Color toastDefaultBackground() => _palette.toastDefaultBackground();
}

// ignore: library_private_types_in_public_api
extension WLColorsEx on _WLColors {
  void update({Color? primary, List<Color>? primaryGradient}) {
    WLColorsLight.instance.update(
      primary: primary,
      primaryGradient: primaryGradient,
    );
    WLColorsDark.instance.update(
      primary: primary,
      primaryGradient: primaryGradient,
    );
  }
}
