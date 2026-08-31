import 'package:flutter/services.dart';

Future<String> readMapTmx(String assetPath, String cacheVersion) {
  return rootBundle.loadString(assetPath);
}
