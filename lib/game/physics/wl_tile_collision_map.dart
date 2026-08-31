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
    var nextGrounded = false;

    if (!grounded) {
      nextVelocity.y += gravity * dt;
      if (nextVelocity.y > maxFallSpeed) {
        nextVelocity.y = maxFallSpeed;
      }
    } else {
      nextVelocity.y = 0;
    }

    final horizontal = _resolveAxis(
      position: nextPosition,
      delta: nextVelocity.x * dt,
      hitboxWidth: hitboxWidth,
      hitboxHeight: hitboxHeight,
      solids: solids,
      axis: _WLPhysicsAxis.horizontal,
      skin: skin,
    );
    nextPosition = horizontal.position;

    nextGrounded = _isGrounded(
      position: nextPosition,
      hitboxWidth: hitboxWidth,
      hitboxHeight: hitboxHeight,
      solids: solids,
      skin: skin,
    );

    if (!nextGrounded || nextVelocity.y.abs() > 0.5) {
      final vertical = _resolveAxis(
        position: nextPosition,
        delta: nextVelocity.y * dt,
        hitboxWidth: hitboxWidth,
        hitboxHeight: hitboxHeight,
        solids: solids,
        axis: _WLPhysicsAxis.vertical,
        skin: skin,
      );
      nextPosition = vertical.position;
      nextGrounded = vertical.grounded;
      if (vertical.blocked) {
        nextVelocity.y = 0;
      } else if (!vertical.grounded) {
        nextGrounded = _isGrounded(
          position: nextPosition,
          hitboxWidth: hitboxWidth,
          hitboxHeight: hitboxHeight,
          solids: solids,
          skin: skin,
        );
      }
    }

    return WLPhysicsStepResult(
      position: nextPosition,
      velocity: nextVelocity,
      grounded: nextGrounded,
    );
  }

  static _WLAxisResult _resolveAxis({
    required Vector2 position,
    required double delta,
    required double hitboxWidth,
    required double hitboxHeight,
    required List<Rect> solids,
    required _WLPhysicsAxis axis,
    required double skin,
  }) {
    if (delta == 0) {
      return _WLAxisResult(
        position: position,
        grounded: axis == _WLPhysicsAxis.vertical && _isGrounded(
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
    final nextPosition = axis == _WLPhysicsAxis.horizontal
        ? Vector2(position.x + delta, position.y)
        : Vector2(position.x, position.y + delta);
    final next = _hitboxRect(
      position: nextPosition,
      hitboxWidth: hitboxWidth,
      hitboxHeight: hitboxHeight,
    );

    var resolvedPosition = nextPosition;
    var grounded = false;
    var blocked = false;

    for (final solid in solids) {
      if (!_overlapsAxis(previous, next, solid, axis, skin)) {
        continue;
      }

      switch (axis) {
        case _WLPhysicsAxis.horizontal:
          if (delta > 0 &&
              next.right > solid.left &&
              previous.right <= solid.left + skin) {
            final candidateX = solid.left - hitboxWidth / 2;
            if (!blocked || candidateX < resolvedPosition.x) {
              resolvedPosition = Vector2(candidateX, position.y);
              blocked = true;
            }
          } else if (delta < 0 &&
              next.left < solid.right &&
              previous.left >= solid.right - skin) {
            final candidateX = solid.right + hitboxWidth / 2;
            if (!blocked || candidateX > resolvedPosition.x) {
              resolvedPosition = Vector2(candidateX, position.y);
              blocked = true;
            }
          }
        case _WLPhysicsAxis.vertical:
          if (delta > 0 &&
              next.bottom > solid.top &&
              previous.bottom <= solid.top + skin) {
            if (!blocked || solid.top < resolvedPosition.y) {
              resolvedPosition = Vector2(position.x, solid.top);
              grounded = true;
              blocked = true;
            }
          } else if (delta < 0 &&
              next.top < solid.bottom &&
              previous.top >= solid.bottom - skin) {
            if (!blocked || solid.bottom + hitboxHeight > resolvedPosition.y) {
              resolvedPosition = Vector2(
                position.x,
                solid.bottom + hitboxHeight,
              );
              blocked = true;
            }
          }
      }
    }

    if (!blocked && axis == _WLPhysicsAxis.vertical && delta == 0) {
      grounded = _isGrounded(
        position: resolvedPosition,
        hitboxWidth: hitboxWidth,
        hitboxHeight: hitboxHeight,
        solids: solids,
        skin: skin,
      );
    }

    return _WLAxisResult(
      position: resolvedPosition,
      grounded: grounded,
      blocked: blocked,
    );
  }

  static bool _isGrounded({
    required Vector2 position,
    required double hitboxWidth,
    required double hitboxHeight,
    required List<Rect> solids,
    required double skin,
  }) {
    final feet = position.y + skin;
    final halfWidth = hitboxWidth / 2;
    for (final solid in solids) {
      if (feet < solid.top || feet > solid.top + skin * 2) {
        continue;
      }
      if (position.x + halfWidth <= solid.left || position.x - halfWidth >= solid.right) {
        continue;
      }
      return true;
    }
    return false;
  }

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

  static bool _overlapsAxis(
    Rect previous,
    Rect next,
    Rect solid,
    _WLPhysicsAxis axis,
    double skin,
  ) {
    if (!_overlapsPerpendicular(previous, next, solid, axis)) {
      return false;
    }

    return switch (axis) {
      _WLPhysicsAxis.horizontal =>
        next.right > solid.left && previous.right <= solid.left ||
            next.left < solid.right && previous.left >= solid.right,
      _WLPhysicsAxis.vertical =>
        next.bottom > solid.top && previous.bottom <= solid.top ||
            next.top < solid.bottom && previous.top >= solid.bottom,
    };
  }

  static bool _overlapsPerpendicular(
    Rect previous,
    Rect next,
    Rect solid,
    _WLPhysicsAxis axis,
  ) {
    final probe = next;
    return switch (axis) {
      _WLPhysicsAxis.horizontal =>
        probe.bottom > solid.top && probe.top < solid.bottom,
      _WLPhysicsAxis.vertical =>
        probe.right > solid.left && probe.left < solid.right,
    };
  }
}

enum _WLPhysicsAxis { horizontal, vertical }

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
