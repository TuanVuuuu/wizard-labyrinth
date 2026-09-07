import 'package:flutter/material.dart';

class WLNavigate {
  WLNavigate._();

  static const String home = '/';
  static const String game = '/game';
  static const String webGame = '/web-game';

  static void toGame(BuildContext context) {
    Navigator.of(context).pushNamed(game);
  }

  static void toWebGame(BuildContext context) {
    Navigator.of(context).pushNamed(webGame);
  }

  static void back(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void exitGame(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
