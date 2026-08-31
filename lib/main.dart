import 'package:flutter/material.dart';

import 'core/wl_colors.dart';
import 'pages/wl_game_page.dart';
import 'pages/wl_home_page.dart';
import 'routes/navigate.dart';

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
          seedColor: WLColors.teal,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: WLNavigate.home,
      routes: {
        WLNavigate.home: (_) => const WLHomePage(),
        WLNavigate.game: (_) => const WLGamePage(),
      },
    );
  }
}
