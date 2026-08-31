# wl_components

Shared UI kit for Wizard: Mê Lộ (`WLFont`, `WLColors`, `WLButton`, `WLToast`, ...).

## Usage

In the app `pubspec.yaml`:

```yaml
dependencies:
  wl_components:
    path: packages/wl_components
```

```dart
import 'package:wl_components/wl_components.dart';

Text('Play', style: WLFont.medium.bold.onPrimaryColor);
```
