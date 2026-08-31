import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/wl_wizard_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WLApp());
}

class WLApp extends StatelessWidget {
  const WLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wizard: Mê Lộ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A6A78),
          brightness: Brightness.dark,
        ),
      ),
      home: const Scaffold(
        body: WLGamePage(),
      ),
    );
  }
}

class WLGamePage extends StatelessWidget {
  const WLGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: WLWizardGame(),
      backgroundBuilder: (context) {
        return const ColoredBox(color: Color(0xFF061822));
      },
    );
  }
}
