import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous_native_bridge/luminous_native_bridge.dart';

class NativeStepMapper {
  const NativeStepMapper();

  List<HealthMetric> toMetrics(List<NativeStepSample> samples) {
    final metrics = <HealthMetric>[];
    for (final sample in samples) {
      if (sample.count <= 0 || sample.endMs <= sample.startMs) continue;
      final start = DateTime.fromMillisecondsSinceEpoch(sample.startMs);
      final end = DateTime.fromMillisecondsSinceEpoch(sample.endMs);
      metrics.add(
        HealthMetric(
          type: HealthMetricType.steps,
          value: sample.count.toDouble(),
          unit: 'count',
          recordedAt: end,
          source: sample.source,
          sourceId: sample.source,
          sourcePlatform: sample.source,
          startAt: start,
          endAt: end,
        ),
      );
    }
    return metrics;
  }
}
