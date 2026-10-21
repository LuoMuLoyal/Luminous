import 'package:flutter/services.dart';

import 'src/steps/bridge.dart';

export 'src/steps/bridge.dart' show StepBridge;
export 'src/steps/model.dart' show NativeStepSample, StepCapability;

class LuminousNativeBridge {
  LuminousNativeBridge({MethodChannel? channel, StepBridge? steps})
    : _channel = channel ?? const MethodChannel('luminous_native_bridge'),
      steps = steps ?? StepBridge();

  final MethodChannel _channel;
  final StepBridge steps;

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
