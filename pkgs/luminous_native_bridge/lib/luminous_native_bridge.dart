import 'package:flutter/services.dart';

class LuminousNativeBridge {
  LuminousNativeBridge({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('luminous_native_bridge');

  final MethodChannel _channel;

  Future<String> ping() async {
    final result = await _channel.invokeMethod<String>('ping');
    if (result == null) {
      throw PlatformException(
        code: 'empty_response',
        message: 'Native bridge returned no payload for ping.',
      );
    }
    return result;
  }
}
