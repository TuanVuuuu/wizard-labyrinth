import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' show EdgeInsets;

import '../../core/wl_character_constants.dart';
import 'wl_player_input.dart';

const double _joystickSize = 132;
const double _joystickKnobRadius = 26;
const double _jumpButtonSize = 84;
const double _hudMargin = 36;
const int _hudPriority = 100;

class WLGameControls {
  WLGameControls._();

  static const double joystickSize = _joystickSize;
  static const double hudMargin = _hudMargin;

  static Future<void> mount({
    required FlameGame game,
    required WLPlayerInput input,
  }) async {
    await game.camera.viewport.addAll([
      WLMovementJoystick(
        input: input,
        margin: const EdgeInsets.only(
          left: _hudMargin,
          bottom: _hudMargin,
        ),
        priority: _hudPriority,
      ),
      WLJumpButton(
        input: input,
        margin: const EdgeInsets.only(
          right: _hudMargin,
          bottom: _hudMargin,
        ),
        priority: _hudPriority,
      ),
    ]);
  }
}

class WLMovementJoystick extends JoystickComponent {
  WLMovementJoystick({
    required this.input,
    required EdgeInsets margin,
    required int priority,
  }) : super(
          margin: margin,
          anchor: Anchor.center,
          size: _joystickSize,
          knobRadius: _joystickKnobRadius,
          priority: priority,
          knob: CircleComponent(
            radius: _joystickKnobRadius,
            paint: Paint()..color = const Color(0xE6D8F4F8),
          ),
          background: CircleComponent(
            radius: _joystickSize / 2,
            paint: Paint()..color = const Color(0x661A6A78),
          ),
        );

  final WLPlayerInput input;

  @override
  void update(double dt) {
    super.update(dt);
    final axis = relativeDelta.x;
    if (axis.abs() < WLCharacterConstants.joystickDeadZone) {
      input.horizontal = 0;
      return;
    }
    input.horizontal = axis.clamp(-1.0, 1.0);
  }

  @override
  void onDragStop() {
    super.onDragStop();
    input.horizontal = 0;
  }
}

class WLJumpButton extends HudButtonComponent {
  WLJumpButton({
    required this.input,
    required EdgeInsets margin,
    required int priority,
  }) : super(
          margin: margin,
          anchor: Anchor.center,
          size: Vector2.all(_jumpButtonSize),
          priority: priority,
          onPressed: () => input.requestJump(),
          button: _WLJumpButtonVisual(pressed: false),
          buttonDown: _WLJumpButtonVisual(pressed: true),
        );

  final WLPlayerInput input;
}

class _WLJumpButtonVisual extends PositionComponent {
  _WLJumpButtonVisual({required this.pressed}) : super(size: Vector2.all(84));

  final bool pressed;

  @override
  void render(Canvas canvas) {
    final center = size / 2;
    final radius = size.x / 2;
    canvas.drawCircle(
      center.toOffset(),
      radius,
      Paint()
        ..color = pressed ? const Color(0xE61A6A78) : const Color(0x991A6A78),
    );
    canvas.drawCircle(
      center.toOffset(),
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xB3D8F4F8),
    );

    final arrowPaint = Paint()..color = const Color(0xF2D8F4F8);
    final tip = Offset(center.x, center.y - 14);
    final left = Offset(center.x - 12, center.y + 8);
    final right = Offset(center.x + 12, center.y + 8);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(left.dx, left.dy)
        ..lineTo(right.dx, right.dy)
        ..close(),
      arrowPaint,
    );
  }
}
