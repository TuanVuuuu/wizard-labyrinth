import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:wizard/core/wl_colors.dart';
import 'package:wizard/pages/wl_game_page.dart';
import 'package:wizard/pages/wl_home_page.dart';
import 'package:wizard/pages/wl_web_game_page.dart';
import 'package:wizard/routes/navigate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
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
        WLNavigate.webGame: (_) => const WLWebGamePage(),
      },
    );
  }
}
