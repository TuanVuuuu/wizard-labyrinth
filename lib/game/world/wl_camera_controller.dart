import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

import 'package:wizard/core/wl_map_constants.dart';

/// Camera (máy quay) theo nhân vật, kẹp khung nhìn trong map.
class WLCameraController {
  WLCameraController._();
  
  /// Gắn camera vào nhân vật, kẹp khung nhìn trong map.
  static void attach({
    required CameraComponent camera,
    required Vector2 viewSize,
    required Rect worldBounds,
    required PositionComponent target,
    required bool snapToTarget,
  }) {
    if (!_canAttach(viewSize: viewSize, worldBounds: worldBounds)) {
      return;
    }

    final zoom = _zoom(viewSize: viewSize, worldBounds: worldBounds);
    final centerBounds = _centerBounds(
      viewSize: viewSize,
      worldBounds: worldBounds,
      zoom: zoom,
    );
    _applyView(
      camera: camera,
      target: target,
      zoom: zoom,
      centerBounds: centerBounds,
      snapToTarget: snapToTarget,
    );
  }
  
  /// Kiểm tra xem có thể gắn camera vào nhân vật, kẹp khung nhìn trong map không
  static bool _canAttach({
    required Vector2 viewSize,
    required Rect worldBounds,
  }) {
    if (viewSize.x <= 0 || viewSize.y <= 0) {
      return false;
    }
    return worldBounds.width > 0 && worldBounds.height > 0;
  }
  
  /// Tính toán zoom của camera
  static double _zoom({
    required Vector2 viewSize,
    required Rect worldBounds,
  }) {
    final targetWidth = min(
      WLMapConstants.visibleWorldWidth,
      worldBounds.width,
    );
    final zoomForWidth = viewSize.x / targetWidth;
    final zoomForHeight = viewSize.y / worldBounds.height;
    return max(zoomForWidth, zoomForHeight);
  }

  /// Vùng cho phép của tâm camera (máy quay), đã trừ nửa màn hình.
  static Rectangle _centerBounds({
    required Vector2 viewSize,
    required Rect worldBounds,
    required double zoom,
  }) {
    final halfVisible = Vector2(
      viewSize.x / zoom / 2,
      viewSize.y / zoom / 2,
    );
    final xRange = _axisRange(
      worldBounds.left,
      worldBounds.right,
      halfVisible.x,
    );
    final yRange = _axisRange(
      worldBounds.top,
      worldBounds.bottom,
      halfVisible.y,
    );
    return Rectangle.fromLTRB(xRange.min, yRange.min, xRange.max, yRange.max);
  }
  
  /// Tính toán khoảng cách cho phép của tâm camera (máy quay), đã trừ nửa màn hình.
  static ({double min, double max}) _axisRange(
    double start,
    double end,
    double halfVisible,
  ) {
    final minValue = start + halfVisible;
    final maxValue = end - halfVisible;
    if (minValue > maxValue) {
      final center = (start + end) / 2;
      return (min: center, max: center);
    }
    return (min: minValue, max: maxValue);
  }
  
  /// Áp dụng view của camera
  static void _applyView({
    required CameraComponent camera,
    required PositionComponent target,
    required double zoom,
    required Rectangle centerBounds,
    required bool snapToTarget,
  }) {
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.zoom = zoom;
    camera.setBounds(centerBounds, considerViewport: false);
    camera.follow(target, snap: snapToTarget);
    if (!snapToTarget) {
      return;
    }
    camera.viewfinder.position = _clampedPosition(
      target.position,
      centerBounds,
    );
  }
  
  /// Giới hạn vị trí của camera
  static Vector2 _clampedPosition(Vector2 position, Rectangle bounds) {
    return Vector2(
      position.x.clamp(bounds.left, bounds.right),
      position.y.clamp(bounds.top, bounds.bottom),
    );
  }
}
