import 'package:flutter/material.dart';

import 'package:wizard/core/wl_device.dart';
import 'package:wizard/core/wl_font.dart';
import 'package:wizard/routes/navigate.dart';
import 'package:wizard/ui/wl_cavern_backdrop.dart';
import 'package:wizard/ui/wl_menu_button.dart';

class WLHomePage extends StatelessWidget {
  const WLHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WLCavernBackdrop(),
          SafeArea(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitle(),
            const SizedBox(height: 36),
            _buildPlayButton(context),
            if (WLDevice.isNativeMobile) ..._buildWebGameAction(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Wizard: Mê Lộ',
      textAlign: TextAlign.center,
      style: WLFont.display.bold,
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return _buildMenuButton(
      label: 'Play',
      onPressed: () => WLNavigate.toGame(context),
    );
  }

  List<Widget> _buildWebGameAction(BuildContext context) {
    return [
      const SizedBox(height: 12),
      _buildMenuButton(
        label: 'Web game',
        variant: WLMenuButtonVariant.secondary,
        onPressed: () => WLNavigate.toWebGame(context),
      ),
    ];
  }

  Widget _buildMenuButton({
    required String label,
    required VoidCallback onPressed,
    WLMenuButtonVariant variant = WLMenuButtonVariant.primary,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: WLMenuButton(
        label: label,
        variant: variant,
        onPressed: onPressed,
      ),
    );
  }
}
