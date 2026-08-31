import 'package:flutter/material.dart';

/// Contract cho bảng màu light / dark.
abstract class WLColorsPalette {
  Color primary();
  List<Color> primaryGradient();

  Color black();
  Color white();
  Color transparent();
  Color divider();

  Color dropdownBackground();
  Color dropdownIsSelected();

  Color edtBorderUnfocused();
  Color edtBorderFocused();

  Color statusError();
  Color statusSuccess();
  Color statusInfo();

  Color btnPrimaryDisabled();
  Color btnPrimaryDisabledChild();

  Color textNormal();
  Color textNeutralLight();
  Color textNeutralLighter();
  Color textNeutral();
  Color textDisabled();

  Color toastDefaultBackground();
}
