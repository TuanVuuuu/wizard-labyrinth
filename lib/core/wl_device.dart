import 'package:flutter/foundation.dart';

/// Nhận diện form-factor. Trên web, [defaultTargetPlatform] lấy từ user-agent
/// của trình duyệt nên phân biệt được Chrome trên máy tính với Safari/Chrome điện thoại.
class WLDevice {
  WLDevice._();

  static bool get isWeb => kIsWeb;

  static bool get isDesktop {
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return false;
    }
  }

  static bool get isMobile => !isDesktop;

  static bool get isDesktopWeb => isWeb && isDesktop;

  static bool get isMobileWeb => isWeb && isMobile;

  static bool get isNativeMobile => !isWeb && isMobile;

  /// Chỉ hiển thị nút điều khiển trên thiết bị di động
  static bool get shouldShowOnscreenControls => isMobile;
}
