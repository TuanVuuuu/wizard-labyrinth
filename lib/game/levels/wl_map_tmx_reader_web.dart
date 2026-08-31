import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Future<String> readMapTmx(String assetPath, String cacheVersion) async {
  if (cacheVersion == 'dev') {
    return rootBundle.loadString(assetPath);
  }

  final url = Uri.base.resolve(
    'assets/$assetPath?v=${Uri.encodeComponent(cacheVersion)}',
  );
  final response = await http.get(
    url,
    headers: const {'Cache-Control': 'no-cache'},
  );
  if (response.statusCode != 200) {
    throw StateError(
      'Không load được map: $url (HTTP ${response.statusCode})',
    );
  }
  return response.body;
}
