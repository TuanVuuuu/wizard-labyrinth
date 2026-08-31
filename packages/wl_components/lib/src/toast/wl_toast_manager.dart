import 'package:flutter/material.dart';
import 'package:wl_components/src/toast/wl_toast.dart';
import 'package:wl_components/src/toast/wl_toast_config.dart';
import 'package:wl_components/src/toast/wl_toast_theme.dart';
import 'package:wl_components/src/toast/wl_toast_widget.dart';

class WLToastManager {
  static final WLToastManager _instance = WLToastManager._internal();
  factory WLToastManager() => _instance;
  WLToastManager._internal();

  final List<_ToastEntry> _toastStack = [];
  final WLToastTheme _defaultTheme = const WLToastTheme();
  static const int _maxToasts = 3;

  void show(
    BuildContext context, {
    required String message,
    WLToastPosition position = WLToastPosition.bottom,
    WLToastType type = WLToastType.replace,
    Duration? duration,
    Color? backgroundColor,
    Color? textColor,
    Widget? icon,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? borderRadius,
    double? maxWidth,
    Duration? animationDuration,
  }) {
    final config = WLToastConfig(
      message: message,
      position: position,
      duration: duration ?? const Duration(seconds: 1),
      type: type,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
      padding: padding ?? _defaultTheme.padding,
      margin: margin ?? _defaultTheme.margin,
      borderRadius: borderRadius ?? _defaultTheme.borderRadius,
      maxWidth: maxWidth ?? _defaultTheme.maxWidth,
      animationDuration: animationDuration ?? _defaultTheme.animationDuration,
    );

    _addToast(context, config);
  }

  void _addToast(BuildContext context, WLToastConfig config) {
    if (config.type == WLToastType.sequence) {
      _showSequence(context, config);
      return;
    }
    if (config.type == WLToastType.replace) {
      _showReplace(context, config);
      return;
    }
    final entry = _ToastEntry(context, config);
    final overlay = Overlay.of(context);

    if (config.position == WLToastPosition.top) {
      _toastStack.insert(0, entry);
    } else {
      _toastStack.add(entry);
    }

    final samePosition = _toastStack
        .where((t) => t.config.position == config.position)
        .toList(growable: false);
    if (samePosition.length > _maxToasts) {
      final ordered = _orderedByNearestEdge(samePosition, config.position);
      final toRemove = ordered.last;
      _removeToast(toRemove);
    }

    final overlayEntry = OverlayEntry(
      builder: (_) => _buildOverlayWidget(entry),
    );
    entry.overlayEntry = overlayEntry;
    overlay.insert(overlayEntry);

    for (final toast in _toastStack) {
      if (toast != entry) toast.overlayEntry?.markNeedsBuild();
    }
  }

  // ============ Replace mode (replace at same position) ============
  void _showReplace(BuildContext context, WLToastConfig config) {
    // Remove all existing toasts at same position first
    final toRemove = _toastStack
        .where((t) => t.config.position == config.position)
        .toList(growable: false);
    for (final t in toRemove) {
      _removeToast(t);
    }

    // Then show a single new toast (reuse stack animation but with single item)
    final entry = _ToastEntry(context, config);
    final overlay = Overlay.of(context);
    _toastStack.add(entry);
    final overlayEntry = OverlayEntry(
      builder: (_) => _buildOverlayWidget(entry),
    );
    entry.overlayEntry = overlayEntry;
    overlay.insert(overlayEntry);
  }

  // ============ Sequence mode (one at a time) ============
  final List<_ToastEntry> _seqQueue = [];
  OverlayEntry? _seqOverlay;

  void _showSequence(BuildContext context, WLToastConfig config) {
    final entry = _ToastEntry(context, config);
    _seqQueue.add(entry);
    if (_seqOverlay == null) {
      _dequeueAndShow();
    }
  }

  void _dequeueAndShow() {
    if (_seqQueue.isEmpty) {
      _seqOverlay?.remove();
      _seqOverlay = null;
      return;
    }
    final entry = _seqQueue.removeAt(0);
    final overlay = Overlay.of(entry.context);
    final overlayEntry = OverlayEntry(
      builder: (_) => _buildSequenceWidget(entry),
    );
    _seqOverlay = overlayEntry;
    overlay.insert(overlayEntry);
  }

  Widget _buildSequenceWidget(_ToastEntry entry) {
    final baseOffset = 50.0;
    return Positioned(
      top: entry.config.position == WLToastPosition.top ? baseOffset : null,
      bottom:
          entry.config.position == WLToastPosition.bottom ? baseOffset : null,
      left: 0,
      right: 0,
      child: Align(
        alignment: _getAlignment(entry.config.position),
        child: WLToastWidget(
          config: entry.config,
          theme: _defaultTheme,
          onDismiss: () {
            _seqOverlay?.remove();
            _seqOverlay = null;
            _dequeueAndShow();
          },
        ),
      ),
    );
  }

  Widget _buildOverlayWidget(_ToastEntry entry) {
    final group = _toastStack
        .where((t) => t.config.position == entry.config.position)
        .toList(growable: false);
    final ordered = _orderedByNearestEdge(group, entry.config.position);
    final index = ordered.indexOf(entry);
    final baseOffset = 50.0 + _defaultTheme.padding.top;
    final double translateY =
        baseOffset * index * _directionFor(entry.config.position);
    final double opacity = _opacityForIndex(index);

    return Positioned(
      top: entry.config.position == WLToastPosition.top ? baseOffset : null,
      bottom:
          entry.config.position == WLToastPosition.bottom ? baseOffset : null,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: true,
        child: Align(
          alignment: _getAlignment(entry.config.position),
          child: _RepositionAnimated(
            dy: translateY,
            duration: entry.config.animationDuration,
            child: Opacity(
              opacity: opacity,
              child: WLToastWidget(
                config: entry.config,
                theme: _defaultTheme,
                onDismiss: () => _removeToast(entry),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _directionFor(WLToastPosition position) {
    switch (position) {
      case WLToastPosition.top:
        return 1.0; // downwards
      case WLToastPosition.center:
        return 1.0; // stack downward by default
      case WLToastPosition.bottom:
        return -1.0; // upwards
    }
  }

  List<_ToastEntry> _orderedByNearestEdge(
    List<_ToastEntry> list,
    WLToastPosition position,
  ) {
    if (position == WLToastPosition.bottom) {
      return list.reversed.toList(growable: false);
    }
    return list;
  }

  double _opacityForIndex(int index) {
    final value = 1.0 - (index * 0.15);
    if (value < 0.5) return 0.5;
    if (value > 1.0) return 1.0;
    return value;
  }

  Alignment _getAlignment(WLToastPosition position) {
    switch (position) {
      case WLToastPosition.top:
        return Alignment.topCenter;
      case WLToastPosition.center:
        return Alignment.center;
      case WLToastPosition.bottom:
        return Alignment.bottomCenter;
    }
  }

  void _removeToast(_ToastEntry entry) {
    entry.overlayEntry?.remove();
    _toastStack.remove(entry);
    _markAllForRebuild();
  }

  void dismissAll() {
    for (var toast in _toastStack) {
      toast.overlayEntry?.remove();
    }
    _toastStack.clear();
  }

  void _markAllForRebuild() {
    for (final toast in _toastStack) {
      toast.overlayEntry?.markNeedsBuild();
    }
  }
}

class _RepositionAnimated extends StatelessWidget {
  const _RepositionAnimated({
    required this.dy,
    required this.duration,
    required this.child,
  });

  final double dy;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: dy, end: dy),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(offset: Offset(0, value), child: child);
      },
      child: child,
    );
  }
}

class _ToastEntry {
  _ToastEntry(this.context, this.config);
  final BuildContext context;
  final WLToastConfig config;
  OverlayEntry? overlayEntry;
}
