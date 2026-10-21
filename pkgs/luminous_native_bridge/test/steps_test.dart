import 'package:flutter_test/flutter_test.dart';
import 'package:luminous_native_bridge/luminous_native_bridge.dart';
import 'package:luminous_native_bridge/src/generated/steps.g.dart' as pigeon;

class _FakeStepHostApi extends pigeon.StepHostApi {
  _FakeStepHostApi({required this.capabilityResult, required this.steps});

  final pigeon.StepCapability capabilityResult;
  final List<pigeon.NativeStep> steps;
  pigeon.StepReadRequest? lastRequest;

  @override
  Future<pigeon.StepCapability> capability() async => capabilityResult;

  @override
  Future<List<pigeon.NativeStep>> read(pigeon.StepReadRequest request) async {
    lastRequest = request;
    return steps;
  }
}

void main() {
  test('capability returns the host payload', () async {
    final api = _FakeStepHostApi(
      capabilityResult: pigeon.StepCapability(
        available: false,
        reason: 'permissionDenied',
        message: 'No permission',
      ),
      steps: const [],
    );
    final bridge = StepBridge(api: api);

    final capability = await bridge.capability();

    expect(capability.available, isFalse);
    expect(capability.reason, 'permissionDenied');
    expect(capability.message, 'No permission');
  });

  test('read forwards the requested range and returns samples', () async {
    final api = _FakeStepHostApi(
      capabilityResult: pigeon.StepCapability(available: true),
      steps: [
        pigeon.NativeStep(
          count: 42,
          startMs: 1000,
          endMs: 2000,
          source: 'android_sensor',
        ),
      ],
    );
    final bridge = StepBridge(api: api);

    final steps = await bridge.read(startMs: 1000, endMs: 2000);

    expect(api.lastRequest?.startMs, 1000);
    expect(api.lastRequest?.endMs, 2000);
    expect(steps.single.count, 42);
    expect(steps.single.source, 'android_sensor');
  });
}
