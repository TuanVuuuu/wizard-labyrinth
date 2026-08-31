import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../core/wl_colors.dart';
import '../game/overlays/wl_death_overlay.dart';
import '../game/overlays/wl_exit_confirm_overlay.dart';
import '../game/overlays/wl_game_hud.dart';
import '../game/overlays/wl_game_overlay_id.dart';
import '../game/overlays/wl_pause_overlay.dart';
import '../game/wl_wizard_game.dart';

class WLGamePage extends StatefulWidget {
  const WLGamePage({super.key});

  @override
  State<WLGamePage> createState() => _WLGamePageState();
}

class _WLGamePageState extends State<WLGamePage> {
  late final WLWizardGame _game;

  @override
  void initState() {
    super.initState();
    _game = WLWizardGame();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _game.handleSystemBack();
      },
      child: GameWidget<WLWizardGame>(
        game: _game,
        overlayBuilderMap: _overlayBuilders,
        initialActiveOverlays: const [WLGameOverlayId.hud],
        backgroundBuilder: _buildBackground,
        loadingBuilder: _buildLoading,
      ),
    );
  }

  Map<String, OverlayWidgetBuilder<WLWizardGame>> get _overlayBuilders {
    return {
      WLGameOverlayId.hud: (context, game) => WLGameHud(game: game),
      WLGameOverlayId.pause: (context, game) => WLPauseOverlay(game: game),
      WLGameOverlayId.exitConfirm: (context, game) =>
          WLExitConfirmOverlay(game: game),
      WLGameOverlayId.death: (context, game) => WLDeathOverlay(game: game),
    };
  }

  Widget _buildBackground(BuildContext context) {
    return const ColoredBox(color: WLColors.cavernDeep);
  }

  Widget _buildLoading(BuildContext context) {
    return const ColoredBox(
      color: WLColors.cavernDeep,
      child: Center(
        child: CircularProgressIndicator(color: WLColors.mist),
      ),
    );
  }
}
