import '../generated/steps.g.dart' as pigeon;
import 'model.dart';

class StepBridge {
  StepBridge({pigeon.StepHostApi? api}) : _api = api ?? pigeon.StepHostApi();

  final pigeon.StepHostApi _api;

  Future<StepCapability> capability() async {
    final capability = await _api.capability();
    return StepCapability(
      available: capability.available,
      reason: capability.reason,
      message: capability.message,
    );
  }

  Future<List<NativeStepSample>> read({
    required int startMs,
    required int endMs,
  }) async {
    final steps = await _api.read(
      pigeon.StepReadRequest(startMs: startMs, endMs: endMs),
    );
    return steps
        .map(
          (step) => NativeStepSample(
            count: step.count,
            startMs: step.startMs,
            endMs: step.endMs,
            source: step.source,
          ),
        )
        .toList(growable: false);
  }
}
