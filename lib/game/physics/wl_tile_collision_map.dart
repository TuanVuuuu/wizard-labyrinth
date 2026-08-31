import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class WLTileCollisionMap {
  WLTileCollisionMap._(this.solids);

  final List<Rect> solids;

  static const List<String> collisionLayerNames = ['ground', 'platforms'];

  static WLTileCollisionMap fromTiledMap(TiledComponent map) {
    final solids = <Rect>[];
    final tileMap = map.tileMap;
    final tiledMap = tileMap.map;
    final destTileSize = tileMap.destTileSize;

    for (final layerName in collisionLayerNames) {
      final layer = tileMap.getLayer<TileLayer>(layerName);
      if (layer == null) {
        continue;
      }
      _collectLayerSolids(
        layer: layer,
        tiledMap: tiledMap,
        destTileSize: destTileSize,
        solids: solids,
      );
    }

    return WLTileCollisionMap._(solids);
  }

  static void _collectLayerSolids({
    required TileLayer layer,
    required TiledMap tiledMap,
    required Vector2 destTileSize,
    required List<Rect> solids,
  }) {
    final tileData = layer.tileData;
    if (tileData == null) {
      return;
    }

    for (var row = 0; row < tileData.length; row++) {
      for (var col = 0; col < tileData[row].length; col++) {
        final gid = tileData[row][col];
        if (gid.tile == 0) {
          continue;
        }

        final tile = tiledMap.tileByGid(gid.tile);
        if (tile == null || tile.isEmpty) {
          continue;
        }

        final tileset = tiledMap.tilesetByTileGId(gid.tile);
        final sourceTileWidth =
            tileset.tileWidth?.toDouble() ?? destTileSize.x;
        final sourceTileHeight =
            tileset.tileHeight?.toDouble() ?? destTileSize.y;
        final scaleX = destTileSize.x / sourceTileWidth;
        final scaleY = destTileSize.y / sourceTileHeight;
        final tileX = col * destTileSize.x + layer.offsetX;
        final tileY = row * destTileSize.y + layer.offsetY;

        final objectGroup = tile.objectGroup;
        if (objectGroup is ObjectGroup && objectGroup.objects.isNotEmpty) {
          _addTileObjectSolids(
            objectGroup: objectGroup,
            tileX: tileX,
            tileY: tileY,
            scaleX: scaleX,
            scaleY: scaleY,
            solids: solids,
          );
          continue;
        }

        solids.add(
          Rect.fromLTWH(tileX, tileY, destTileSize.x, destTileSize.y),
        );
      }
    }
  }

  static void _addTileObjectSolids({
    required ObjectGroup objectGroup,
    required double tileX,
    required double tileY,
    required double scaleX,
    required double scaleY,
    required List<Rect> solids,
  }) {
    for (final object in objectGroup.objects) {
      if (!object.isRectangle || object.width <= 0 || object.height <= 0) {
        continue;
      }
      solids.add(
        Rect.fromLTWH(
          tileX + object.x * scaleX,
          tileY + object.y * scaleY,
          object.width * scaleX,
          object.height * scaleY,
        ),
      );
    }
  }
}

class WLPlatformerPhysics {
  WLPlatformerPhysics._();

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
    var nextPosition = position.clone();
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

    nextPosition = _resolvePenetration(
      position: nextPosition,
      hitboxWidth: hitboxWidth,
      hitboxHeight: hitboxHeight,
      solids: solids,
      skin: skin,
    );

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

    final previous = _hitboxRect(
      position: position,
      hitboxWidth: hitboxWidth,
      hitboxHeight: hitboxHeight,
    );
    final nextPosition = Vector2(position.x + delta, position.y);
    final next = _hitboxRect(
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

    final previous = _hitboxRect(
      position: position,
      hitboxWidth: hitboxWidth,
      hitboxHeight: hitboxHeight,
    );
    final nextPosition = Vector2(position.x, position.y + delta);
    final next = _hitboxRect(
      position: nextPosition,
      hitboxWidth: hitboxWidth,
      hitboxHeight: hitboxHeight,
    );

    var resolvedPosition = nextPosition;
    var grounded = false;
    var blocked = false;

    for (final solid in solids) {
      if (!_hitboxesOverlap(next, solid) && !_hitboxesOverlap(previous, solid)) {
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
      final hitbox = _hitboxRect(
        position: resolved,
        hitboxWidth: hitboxWidth,
        hitboxHeight: hitboxHeight,
      );

      for (final solid in solids) {
        if (!_hitboxesOverlap(hitbox, solid)) {
          continue;
        }

        final overlapX = _overlapAmount(hitbox, solid, horizontal: true);
        final overlapY = _overlapAmount(hitbox, solid, horizontal: false);
        if (overlapX <= 0 && overlapY <= 0) {
          continue;
        }

        final feetOnTop = resolved.y <= solid.top + skin &&
            resolved.y >= solid.top - skin &&
            hitbox.right > solid.left + skin &&
            hitbox.left < solid.right - skin;

        if (feetOnTop || overlapY <= overlapX) {
          resolved.y = solid.top;
        } else if (overlapX < overlapY) {
          if (resolved.x < solid.center.dx) {
            resolved.x = solid.left - hitboxWidth / 2;
          } else {
            resolved.x = solid.right + hitboxWidth / 2;
          }
        } else {
          if (resolved.y < solid.center.dy) {
            resolved.y = solid.top;
          } else {
            resolved.y = solid.bottom + hitboxHeight;
          }
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

  static bool _isHittingCeiling(
    Rect previous,
    Rect next,
    Rect solid,
    double skin,
  ) {
    if (next.top >= solid.bottom - skin) {
      return false;
    }
    if (previous.top < solid.bottom - skin) {
      return false;
    }
    if (next.right <= solid.left + skin || next.left >= solid.right - skin) {
      return false;
    }
    return true;
  }

  static bool _isGrounded({
    required Vector2 position,
    required double hitboxWidth,
    required double hitboxHeight,
    required List<Rect> solids,
    required double skin,
  }) {
    final hitbox = _hitboxRect(
      position: position,
      hitboxWidth: hitboxWidth,
      hitboxHeight: hitboxHeight,
    );
    final feet = position.y;

    for (final solid in solids) {
      if (feet < solid.top - skin || feet > solid.top + skin * 2) {
        continue;
      }
      if (hitbox.right <= solid.left + skin || hitbox.left >= solid.right - skin) {
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

  static bool _hitboxesOverlap(Rect a, Rect b) {
    return a.left < b.right && a.right > b.left && a.top < b.bottom && a.bottom > b.top;
  }

  static double _overlapAmount(Rect hitbox, Rect solid, {required bool horizontal}) {
    if (horizontal) {
      return min(hitbox.right - solid.left, solid.right - hitbox.left);
    }
    return min(hitbox.bottom - solid.top, solid.bottom - hitbox.top);
  }

  static double min(double a, double b) => a < b ? a : b;

  static Rect _hitboxRect({
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

class _WLAxisResult {
  const _WLAxisResult({
    required this.position,
    this.grounded = false,
    this.blocked = false,
  });

  final Vector2 position;
  final bool grounded;
  final bool blocked;
}

class WLPhysicsStepResult {
  const WLPhysicsStepResult({
    required this.position,
    required this.velocity,
    required this.grounded,
  });

  final Vector2 position;
  final Vector2 velocity;
  final bool grounded;
}
