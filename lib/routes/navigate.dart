import 'package:flutter/material.dart';

class WLNavigate {
  WLNavigate._();

  static const String home = '/';
  static const String game = '/game';

  static void toGame(BuildContext context) {
    Navigator.of(context).pushNamed(game);
  }

  static void exitGame(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
