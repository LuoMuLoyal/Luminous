import 'package:luminous/features/health_data/data/mappers/native_step_mapper.dart';
import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous_native_bridge/luminous_native_bridge.dart';

class NativeStepSource {
  NativeStepSource({
    required this.bridge,
    this.mapper = const NativeStepMapper(),
  });

  final StepBridge bridge;
  final NativeStepMapper mapper;

  Future<StepCapability> capability() => bridge.capability();

  Future<List<HealthMetric>> fetchMetrics({
    required DateTime start,
    required DateTime end,
  }) async {
    final samples = await bridge.read(
      startMs: start.millisecondsSinceEpoch,
      endMs: end.millisecondsSinceEpoch,
    );
    return mapper.toMetrics(samples);
  }
}
