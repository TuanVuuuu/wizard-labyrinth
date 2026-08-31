import '../../core/wl_character_constants.dart';

class WLPlayerInput {
  double horizontal = 0;
  double jumpBufferRemaining = 0;

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
    horizontal = 0;
    jumpBufferRemaining = 0;
  }
}
