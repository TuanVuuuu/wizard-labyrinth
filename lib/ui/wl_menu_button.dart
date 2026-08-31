import 'package:flutter/material.dart';

import '../core/wl_colors.dart';
import '../core/wl_font.dart';

enum WLMenuButtonVariant { primary, secondary }

class WLMenuButton extends StatelessWidget {
  const WLMenuButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = WLMenuButtonVariant.primary,
  });

  final String label;
  final VoidCallback onPressed;
  final WLMenuButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: switch (variant) {
        WLMenuButtonVariant.primary => _buildPrimary(),
        WLMenuButtonVariant.secondary => _buildSecondary(),
      },
    );
  }

  Widget _buildPrimary() {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: WLColors.teal,
        foregroundColor: WLColors.mist,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: _buildLabel(),
    );
  }

  Widget _buildSecondary() {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: WLColors.mist,
        side: const BorderSide(color: WLColors.panelBorder, width: 1.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: _buildLabel(),
    );
  }

  Widget _buildLabel() {
    return Text(label, style: WLFont.medium.bold);
  }
}
