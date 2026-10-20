import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous_native_bridge/luminous_native_bridge.dart';

final nativeBridgeProvider = Provider<LuminousNativeBridge>((ref) {
  return LuminousNativeBridge();
});
