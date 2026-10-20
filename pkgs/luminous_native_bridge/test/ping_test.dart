import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous_native_bridge/luminous_native_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('luminous_native_bridge');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'ping') {
        return 'pong';
      }
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('ping returns the native result', () async {
    expect(await LuminousNativeBridge().ping(), 'pong');
  });
}
