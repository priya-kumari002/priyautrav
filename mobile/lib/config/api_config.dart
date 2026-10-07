import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// **Real phone:** set your PC Wi‑Fi IPv4 (same Wi‑Fi as phone), e.g. `192.168.1.5`.
/// Leave empty to use emulator defaults.
const String phoneApiHost = '192.168.29.248';

String get apiBaseUrl {
  const port = 3000;
  if (phoneApiHost.isNotEmpty) {
    return 'http://$phoneApiHost:$port';
  }
  if (kIsWeb) return 'http://localhost:$port';
  if (Platform.isAndroid) return 'http://10.0.2.2:$port';
  return 'http://localhost:$port';
}
