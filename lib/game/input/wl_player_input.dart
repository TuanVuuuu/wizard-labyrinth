import 'package:wizard/core/wl_character_constants.dart';

class WLPlayerInput {
  double _touchHorizontal = 0;
  double _keyboardHorizontal = 0;
  double jumpBufferRemaining = 0;

  double get horizontal {
    if (_keyboardHorizontal.abs() >= WLCharacterConstants.joystickDeadZone) {
      return _keyboardHorizontal;
    }
    return _touchHorizontal;
  }

  void setTouchHorizontal(double value) {
    _touchHorizontal = value;
  }

  void setKeyboardHorizontal(double value) {
    _keyboardHorizontal = value;
  }

  void requestJump() {
    jumpBufferRemaining = WLCharacterConstants.jumpBufferSeconds;
  }

  void tick(double dt) {
    if (jumpBufferRemaining <= 0) {
      return;
    }
    jumpBufferRemaining -= dt;
    if (jumpBufferRemaining < 0) {
      jumpBufferRemaining = 0;
    }
  }

  bool get hasJumpRequest => jumpBufferRemaining > 0;

  void clearJumpRequest() {
    jumpBufferRemaining = 0;
  }

  void reset() {
    _touchHorizontal = 0;
    _keyboardHorizontal = 0;
    jumpBufferRemaining = 0;
  }
}
