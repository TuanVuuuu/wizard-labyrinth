import 'package:flutter/services.dart';

import 'wl_player_input.dart';

class WLKeyboardControls {
  WLKeyboardControls._();

  static final Set<LogicalKeyboardKey> _leftKeys = {
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.keyA,
  };

  static final Set<LogicalKeyboardKey> _rightKeys = {
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.keyD,
  };

  static final Set<LogicalKeyboardKey> _jumpKeys = {
    LogicalKeyboardKey.space,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.keyW,
  };

  static bool isPauseKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.escape;
  }

  static bool isHandledKey(LogicalKeyboardKey key) {
    return _leftKeys.contains(key) ||
        _rightKeys.contains(key) ||
        _jumpKeys.contains(key) ||
        isPauseKey(key);
  }

  static void syncHeldKeys(WLPlayerInput input) {
    applyMovement(input, HardwareKeyboard.instance.logicalKeysPressed);
  }

  static void applyMovement(
    WLPlayerInput input,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final left = keysPressed.intersection(_leftKeys).isNotEmpty;
    final right = keysPressed.intersection(_rightKeys).isNotEmpty;
    if (left == right) {
      input.setKeyboardHorizontal(0);
      return;
    }
    input.setKeyboardHorizontal(left ? -1 : 1);
  }

  static bool shouldJump(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return false;
    }
    return _jumpKeys.contains(event.logicalKey);
  }
}
