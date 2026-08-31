// Extension for GlobalKey

import 'package:flutter/material.dart';

extension WLGlobalKeySizeX on GlobalKey {
  double get height {
    final RenderBox? renderBox =
        currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.height ?? 0;
  }

  double get width {
    final RenderBox? renderBox =
        currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 0;
  }

  Offset get position {
    final RenderBox? renderBox =
        currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
  }
}
