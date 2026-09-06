import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import 'package:wizard/game/physics/wl_physics_step_result.dart';

/// Tính vị trí, vận tốc và trạng thái đứng đất cho nhân vật kiểu platformer (nhảy, rơi, đi ngang).
class WLPlatformerPhysics {
  WLPlatformerPhysics._();

  /// Một bước vật lý: áp trọng lực, di chuyển ngang/dọc, đẩy ra khỏi tường, rồi kiểm tra đang đứng đất.
  static WLPhysicsStepResult step({
    required Vector2 position,
    required Vector2 velocity,
    required bool grounded,
    required double hitboxWidth,
    required double hitboxHeight,
    required double dt,
    required List<Rect> solids,
    required double gravity,
    required double maxFallSpeed,
    required double skin,
  }) {
    // Vị trí mới sau khi di chuyển
    var nextPosition = position.clone();
    // Vận tốc mới sau khi di chuyển
    var nextVelocity = velocity.clone();

    if (!grounded) {
      nextVelocity.y += gravity * dt;
      if (nextVelocity.y > maxFallSpeed) {
        nextVelocity.y = maxFallSpeed;
      }
    } else if (nextVelocity.y > 0) {
      nextVelocity.y = 0;
    }

    final horizontalDelta = nextVelocity.x * dt;
    if (horizontalDelta != 0) {
      final horizontal = _moveHorizontal(
        position: nextPosition,
        delta: horizontalDelta,
        hitboxWidth: hitboxWidth,
        hitboxHeight: hitboxHeight,
        solids: solids,
        skin: skin,
      );
      nextPosition = horizontal.position;
      if (horizontal.blocked) {
        nextVelocity.x = 0;
      }
    }

    final verticalDelta = nextVelocity.y * dt;
    if (verticalDelta != 0 || !grounded) {
      final vertical = _moveVertical(
        position: nextPosition,
        delta: verticalDelta,
        hitboxWidth: hitboxWidth,
        hitboxHeight: hitboxHeight,
        solids: solids,
        skin: skin,
      );
      nextPosition = vertical.position;
      if (vertical.blocked) {
        nextVelocity.y = 0;
      }
    }
    // Vị trí trước khi di chuyển
    final beforePenetration = nextPosition.clone();
    // Đẩy ra khỏi tường
    nextPosition = _resolvePenetration(
      position: nextPosition,
      hitboxWidth: hitboxWidth,
      hitboxHeight: hitboxHeight,
      solids: solids,
      skin: skin,
    );
    // Nếu vị trí mới sau khi di chuyển cao hơn vị trí trước khi di chuyển và vận tốc y âm, đẩy lên
    if (nextPosition.y > beforePenetration.y && nextVelocity.y < 0) {
      nextVelocity.y = 0;
    }

    final nextGrounded = _isGrounded(
      position: nextPosition,
      hitboxWidth: hitboxWidth,
      hitboxHeight: hitboxHeight,
      solids: solids,
      skin: skin,
    );

    if (nextGrounded && nextVelocity.y > 0) {
      nextVelocity.y = 0;
    }

    return WLPhysicsStepResult(
      position: nextPosition,
      velocity: nextVelocity,
      grounded: nextGrounded,
    );
  }

  /// Di chuyển theo trục ngang; dừng lại nếu đụng tường.
  static _WLAxisResult _moveHorizontal({
    required Vector2 position,
    required double delta,
    required double hitboxWidth,
    required double hitboxHeight,
    required List<Rect> solids,
    required double skin,
  }) {
    if (delta == 0) {
      return _WLAxisResult(position: position);
    }

    final previous = hitboxRect(
      position: position,
      hitboxWidth: hitboxWidth,
      hitboxHeight: hitboxHeight,
    );
    final nextPosition = Vector2(position.x + delta, position.y);
    final next = hitboxRect(
      position: nextPosition,
      hitboxWidth: hitboxWidth,
      hitboxHeight: hitboxHeight,
    );

    var resolvedPosition = nextPosition;
    var blocked = false;

    for (final solid in solids) {
      if (!_blocksHorizontalCollision(previous, next, solid, skin)) {
        continue;
      }
      if (!_hitboxesOverlap(next, solid)) {
        continue;
      }

      if (delta > 0) {
        final wallX = solid.left - hitboxWidth / 2;
        if (!blocked || wallX < resolvedPosition.x) {
          resolvedPosition = Vector2(wallX, position.y);
          blocked = true;
        }
      } else {
        final wallX = solid.right + hitboxWidth / 2;
        if (!blocked || wallX > resolvedPosition.x) {
          resolvedPosition = Vector2(wallX, position.y);
          blocked = true;
        }
      }
    }

    return _WLAxisResult(position: resolvedPosition, blocked: blocked);
  }

  /// Di chuyển theo trục dọc; đáp xuống nền hoặc đụng trần thì dừng.
  static _WLAxisResult _moveVertical({
    required Vector2 position,
    required double delta,
    required double hitboxWidth,
    required double hitboxHeight,
    required List<Rect> solids,
    required double skin,
  }) {
    if (delta == 0) {
      return _WLAxisResult(
        position: position,
        grounded: _isGrounded(
          position: position,
          hitboxWidth: hitboxWidth,
          hitboxHeight: hitboxHeight,
          solids: solids,
          skin: skin,
        ),
      );
    }

    final previous = hitboxRect(
      position: position,
      hitboxWidth: hitboxWidth,
      hitboxHeight: hitboxHeight,
    );
    final nextPosition = Vector2(position.x, position.y + delta);
    final next = hitboxRect(
      position: nextPosition,
      hitboxWidth: hitboxWidth,
      hitboxHeight: hitboxHeight,
    );

    var resolvedPosition = nextPosition;
    var grounded = false;
    var blocked = false;

    for (final solid in solids) {
      if (!_hitboxesOverlap(next, solid) &&
          !_hitboxesOverlap(previous, solid)) {
        continue;
      }

      if (delta > 0) {
        if (!_isLandingOnTop(previous, next, solid, skin)) {
          continue;
        }
        if (!blocked || solid.top < resolvedPosition.y) {
          resolvedPosition = Vector2(position.x, solid.top);
          grounded = true;
          blocked = true;
        }
      } else {
        if (!_isHittingCeiling(previous, next, solid, skin)) {
          continue;
        }
        final ceilingY = solid.bottom + hitboxHeight;
        if (!blocked || ceilingY > resolvedPosition.y) {
          resolvedPosition = Vector2(position.x, ceilingY);
          blocked = true;
        }
      }
    }

    return _WLAxisResult(
      position: resolvedPosition,
      grounded: grounded,
      blocked: blocked,
    );
  }

  /// Nếu hitbox (hộp va chạm) đang cắm vào tường/nền, đẩy nhân vật ra ngoài.
  static Vector2 _resolvePenetration({
    required Vector2 position,
    required double hitboxWidth,
    required double hitboxHeight,
    required List<Rect> solids,
    required double skin,
  }) {
    var resolved = position.clone();

    for (var pass = 0; pass < 4; pass++) {
      var moved = false;
      final hitbox = hitboxRect(
        position: resolved,
        hitboxWidth: hitboxWidth,
        hitboxHeight: hitboxHeight,
      );
      // Lặp qua các khối đặc
      for (final solid in solids) {
        // Nếu khối đặc không chồng lên hitbox, không cần xử lý
        if (!_hitboxesOverlap(hitbox, solid)) {
          continue;
        }
        // Tính độ chồng theo ngang và dọc
        final overlapX = _overlapAmount(hitbox, solid, horizontal: true);
        final overlapY = _overlapAmount(hitbox, solid, horizontal: false);
        // Nếu không có độ chồng, không cần xử lý
        if (overlapX <= 0 && overlapY <= 0) {
          continue;
        }
        // Kiểm tra chân nhân vật có đứng trên khối đặc không
        final feetOnTop = resolved.y <= solid.top + skin &&
            resolved.y >= solid.top - skin &&
            hitbox.right > solid.left + skin &&
            hitbox.left < solid.right - skin;

        // Tính vị trí tâm của hitbox
        final hitboxCenterY = resolved.y - hitboxHeight / 2;
        // Kiểm tra nhân vật có ở trên khối đặc không
        final isAboveSolid = hitboxCenterY < solid.center.dy;
        // Tính vị trí mới sau khi đẩy ra khỏi tường
        final snappedY = isAboveSolid ? solid.top : solid.bottom + hitboxHeight;

        // Nếu chân nhân vật đứng trên khối đặc, đẩy lên trên
        if (feetOnTop) {
          resolved.y = solid.top;
        } else if (overlapY <= overlapX) {
          resolved.y = snappedY;
        } else if (overlapX < overlapY) {
          if (resolved.x < solid.center.dx) {
            resolved.x = solid.left - hitboxWidth / 2;
          } else {
            resolved.x = solid.right + hitboxWidth / 2;
          }
        } else {
          resolved.y = snappedY;
        }
        moved = true;
        break;
      }

      if (!moved) {
        break;
      }
    }

    return resolved;
  }

  /// True nếu lần di chuyển ngang này thật sự đụng một khối đặc.
  static bool _blocksHorizontalCollision(
    Rect previous,
    Rect next,
    Rect solid,
    double skin,
  ) {
    if (next.bottom <= solid.top + skin) {
      return false;
    }
    if (next.top >= solid.bottom - skin) {
      return false;
    }
    if (next.right <= solid.left || next.left >= solid.right) {
      return false;
    }
    return previous.right > solid.left + skin && next.right > solid.left ||
        previous.left < solid.right - skin && next.left < solid.right;
  }

  /// True nếu nhân vật vừa rơi xuống và đáp lên mặt trên của khối đặc.
  static bool _isLandingOnTop(
    Rect previous,
    Rect next,
    Rect solid,
    double skin,
  ) {
    if (next.bottom <= solid.top + skin) {
      return false;
    }
    if (previous.bottom > solid.top + skin) {
      return false;
    }
    if (next.right <= solid.left + skin || next.left >= solid.right - skin) {
      return false;
    }
    return true;
  }

  /// True nếu nhân vật vừa nhảy lên và đụng mặt dưới (trần) của khối đặc.
  static bool _isHittingCeiling(
    Rect previous,
    Rect next,
    Rect solid,
    double skin,
  ) {
    if (next.right <= solid.left + skin || next.left >= solid.right - skin) {
      return false;
    }
    if (next.top >= solid.bottom) {
      return false;
    }
    if (previous.bottom <= solid.top + skin) {
      return false;
    }
    return previous.top >= solid.bottom - skin ||
        previous.bottom > solid.bottom;
  }

  /// True nếu chân nhân vật đang đứng trên một khối đặc.
  static bool _isGrounded({
    required Vector2 position,
    required double hitboxWidth,
    required double hitboxHeight,
    required List<Rect> solids,
    required double skin,
  }) {
    final hitbox = hitboxRect(
      position: position,
      hitboxWidth: hitboxWidth,
      hitboxHeight: hitboxHeight,
    );
    final feet = position.y;

    for (final solid in solids) {
      if (feet < solid.top - skin || feet > solid.top + skin * 2) {
        continue;
      }
      if (hitbox.right <= solid.left + skin ||
          hitbox.left >= solid.right - skin) {
        continue;
      }
      if (hitbox.bottom < solid.top - skin) {
        continue;
      }
      if (hitbox.bottom > solid.top + skin) {
        continue;
      }
      return true;
    }
    return false;
  }

  /// True nếu hai hình chữ nhật chồng lên nhau.
  static bool _hitboxesOverlap(Rect a, Rect b) {
    return a.left < b.right &&
        a.right > b.left &&
        a.top < b.bottom &&
        a.bottom > b.top;
  }

  /// Độ chồng theo ngang hoặc dọc giữa hitbox và khối đặc.
  static double _overlapAmount(Rect hitbox, Rect solid,
      {required bool horizontal}) {
    if (horizontal) {
      return min(hitbox.right - solid.left, solid.right - hitbox.left);
    }
    return min(hitbox.bottom - solid.top, solid.bottom - hitbox.top);
  }

  /// Tạo hình chữ nhật va chạm: neo ở chân nhân vật, rộng/cao theo hitbox.
  static Rect hitboxRect({
    required Vector2 position,
    required double hitboxWidth,
    required double hitboxHeight,
  }) {
    return Rect.fromLTWH(
      position.x - hitboxWidth / 2,
      position.y - hitboxHeight,
      hitboxWidth,
      hitboxHeight,
    );
  }
}

/// Kết quả di chuyển trên một trục: vị trí mới, có bị chặn, có đang đứng đất.
class _WLAxisResult {
  const _WLAxisResult({
    required this.position,
    this.grounded = false,
    this.blocked = false,
  });

  /// Vị trí mới sau khi di chuyển
  final Vector2 position;

  /// Có đang đứng đất hay không
  final bool grounded;

  /// Có bị chặn hay không (đụng tường hoặc nền => để dừng di chuyển)
  final bool blocked;
}
