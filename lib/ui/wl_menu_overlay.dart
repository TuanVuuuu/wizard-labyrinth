import 'package:flutter/material.dart';

import '../core/wl_colors.dart';
import '../core/wl_font.dart';

class WLMenuOverlay extends StatelessWidget {
  const WLMenuOverlay({
    super.key,
    required this.title,
    required this.actions,
  });

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WLColors.overlayScrim,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _WLMenuPanel(
            title: title,
            actions: actions,
          ),
        ),
      ),
    );
  }
}

class _WLMenuPanel extends StatelessWidget {
  const _WLMenuPanel({
    required this.title,
    required this.actions,
  });

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: WLColors.panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: WLColors.panelBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitle(),
              const SizedBox(height: 24),
              ..._buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: WLFont.large.bold,
    );
  }

  List<Widget> _buildActions() {
    final spaced = <Widget>[];
    for (final action in actions) {
      if (spaced.isNotEmpty) {
        spaced.add(const SizedBox(height: 12));
      }
      spaced.add(action);
    }
    return spaced;
  }
}
