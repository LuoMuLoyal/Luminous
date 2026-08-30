import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/features/health_data/data/providers/health_sync.dart';
import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous/features/health_data/domain/entities/health_permission.dart';
import 'package:luminous/features/health_data/domain/entities/health_sync_result.dart';
import 'package:luminous/features/health_data/presentation/providers/health_auto_sync.dart';
import 'package:luminous/features/health_data/presentation/providers/health_sync.dart';
import 'package:luminous/features/health_data/presentation/providers/health_sync_controller.dart';
import 'package:luminous/l10n/app_localizations.dart';

class HealthSyncPage extends ConsumerWidget {
  const HealthSyncPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(healthSyncControllerProvider);
    final controller = ref.read(healthSyncControllerProvider.notifier);
    final repo = ref.watch(healthSyncRepositoryProvider);
    final autoSyncAvailability = ref.watch(healthAutoSyncAvailabilityProvider);

    if (!repo.isPlatformAvailable) {
      return PageScaffold(
        title: l10n.healthSyncTitle,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.level6),
            child: Text(
              l10n.healthSyncNotAvailable,
              style: context.theme.typography.body.md,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return PageScaffold(
      title: l10n.healthSyncTitle,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.healthSyncDescription,
              style: context.theme.typography.body.md.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            if (autoSyncAvailability ==
                HealthAutoSyncAvailability.notConfigured) ...[
              const SizedBox(height: Spacing.level3),
              Text(
                l10n.healthSyncAutoSyncNotConfigured,
                style: context.theme.typography.body.md.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
            const SizedBox(height: Spacing.level6),
            _MetricTypeSection(
              selectedTypes: state.selectedTypes,
              onToggle: controller.toggleType,
            ),
            const SizedBox(height: Spacing.level6),
            _TimeRangeSection(
              selectedRange: state.timeRange,
              onChanged: controller.setTimeRange,
            ),
            const SizedBox(height: Spacing.level6),
            if (state.error != null) ...[
              Container(
                padding: const EdgeInsets.all(Spacing.level4),
                decoration: BoxDecoration(
                  color: context.theme.colors.error.withValues(alpha: 0.1),
                  borderRadius: context.theme.style.borderRadius.xs,
                ),
                child: Text(
                  state.error!,
                  style: context.theme.typography.body.md.copyWith(
                    color: context.theme.colors.error,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.level4),
            ],
            if (state.syncResult != null) ...[
              _SyncResultSection(result: state.syncResult!),
              const SizedBox(height: Spacing.level4),
            ],
            if (state.fetchedMetrics.isNotEmpty) ...[
              _MetricsPreviewSection(metrics: state.fetchedMetrics),
              const SizedBox(height: Spacing.level4),
            ],
            if (state.fetchedMetrics.isEmpty) ...[
              FButton(
                onPress: state.isLoading
                    ? null
                    : () async {
                        final status = await controller.requestPermissions();
                        if (status == HealthPermissionStatus.granted) {
                          await controller.fetchData();
                        }
                      },
                child: Text(l10n.healthSyncFetchButton),
              ),
            ] else ...[
              FButton(
                onPress: state.isSyncing ? null : () async => controller.sync(),
                child: Text(
                  state.isSyncing
                      ? l10n.healthSyncSyncing
                      : l10n.healthSyncImportButton(
                          state.fetchedMetrics.length,
                        ),
                ),
              ),
              const SizedBox(height: Spacing.level3),
              FButton(
                variant: FButtonVariant.outline,
                onPress: state.isLoading ? null : controller.reset,
                child: Text(l10n.healthSyncResetButton),
              ),
            ],
            if (state.isLoading)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.level4),
                child: Center(
                  child: FProgress(semanticsLabel: l10n.healthSyncLoading),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricTypeSection extends StatelessWidget {
  const _MetricTypeSection({
    required this.selectedTypes,
    required this.onToggle,
  });

  final Set<HealthMetricType> selectedTypes;
  final void Function(HealthMetricType) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allTypes = [
      HealthMetricType.heartRate,
      HealthMetricType.bloodPressure,
      HealthMetricType.bloodOxygen,
      HealthMetricType.bloodGlucose,
      HealthMetricType.bodyTemperature,
      HealthMetricType.weight,
      HealthMetricType.respiratoryRate,
      HealthMetricType.steps,
      HealthMetricType.flightsClimbed,
      HealthMetricType.exerciseTime,
      HealthMetricType.sleep,
      HealthMetricType.height,
      HealthMetricType.water,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.healthSyncMetricTypes,
          style: context.theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Spacing.level3),
        Wrap(
          spacing: Spacing.level2,
          runSpacing: Spacing.level2,
          children: allTypes.map((type) {
            final selected = selectedTypes.contains(type);
            return FButton(
              variant: selected
                  ? FButtonVariant.primary
                  : FButtonVariant.outline,
              onPress: () => onToggle(type),
              child: Text(_metricLabel(l10n, type)),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _metricLabel(AppLocalizations l10n, HealthMetricType type) {
    return switch (type) {
      HealthMetricType.heartRate => l10n.healthSyncMetricHeartRate,
      HealthMetricType.bloodPressure => l10n.healthSyncMetricBloodPressure,
      HealthMetricType.bloodOxygen => l10n.healthSyncMetricBloodOxygen,
      HealthMetricType.bloodGlucose => l10n.healthSyncMetricBloodGlucose,
      HealthMetricType.bodyTemperature => l10n.healthSyncMetricBodyTemperature,
      HealthMetricType.weight => l10n.healthSyncMetricWeight,
      HealthMetricType.respiratoryRate => l10n.healthSyncMetricRespiratoryRate,
      HealthMetricType.steps => l10n.healthSyncMetricSteps,
      HealthMetricType.flightsClimbed => l10n.healthSyncMetricFlightsClimbed,
      HealthMetricType.exerciseTime => l10n.healthSyncMetricExerciseTime,
      HealthMetricType.sleep => l10n.healthSyncMetricSleep,
      HealthMetricType.water => l10n.healthSyncMetricWater,
      HealthMetricType.height => l10n.healthSyncMetricHeight,
    };
  }
}

class _TimeRangeSection extends StatelessWidget {
  const _TimeRangeSection({
    required this.selectedRange,
    required this.onChanged,
  });

  final HealthSyncTimeRange selectedRange;
  final void Function(HealthSyncTimeRange) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.healthSyncTimeRange,
          style: context.theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Spacing.level3),
        FSelect<HealthSyncTimeRange>.rich(
          label: Text(l10n.healthSyncTimeRange),
          hint: l10n.healthSyncTimeRange,
          format: (value) => _rangeLabel(l10n, value),
          control: FSelectControl.lifted(
            value: selectedRange,
            onChange: (value) {
              if (value != null) onChanged(value);
            },
          ),
          children: HealthSyncTimeRange.values
              .map(
                (range) => FSelectItem.item(
                  title: Text(_rangeLabel(l10n, range)),
                  value: range,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  String _rangeLabel(AppLocalizations l10n, HealthSyncTimeRange range) {
    return switch (range) {
      HealthSyncTimeRange.today => l10n.healthSyncRangeToday,
      HealthSyncTimeRange.threeDays => l10n.healthSyncRangeThreeDays,
      HealthSyncTimeRange.sevenDays => l10n.healthSyncRangeSevenDays,
    };
  }
}

class _SyncResultSection extends StatelessWidget {
  const _SyncResultSection({required this.result});

  final HealthSyncResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return Container(
      padding: const EdgeInsets.all(Spacing.level4),
      decoration: BoxDecoration(
        color: SemanticColor.primary.solid(context).withValues(alpha: 0.08),
        borderRadius: context.theme.style.borderRadius.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.healthSyncResultTitle,
            style: context.theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.level3),
          _ResultRow(
            label: l10n.healthSyncResultSuccess(result.successCount),
            color: SemanticColor.primary.solid(context),
          ),
          _ResultRow(
            label: l10n.healthSyncResultSkipped(result.skippedCount),
            color: SemanticColor.neutral.solid(context),
          ),
          if (result.failedCount > 0)
            _ResultRow(
              label: l10n.healthSyncResultFailed(result.failedCount),
              color: colors.error,
            ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.level1),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: Spacing.level4, color: color),
          const SizedBox(width: Spacing.level2),
          Text(label, style: context.theme.typography.body.md),
        ],
      ),
    );
  }
}

class _MetricsPreviewSection extends StatelessWidget {
  const _MetricsPreviewSection({required this.metrics});

  final List<HealthMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.healthSyncPreviewTitle,
          style: context.theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Spacing.level3),
        FTileGroup(
          divider: FItemDivider.full,
          children: metrics.take(20).map((metric) {
            return FTile(
              title: Text(_metricTitle(l10n, metric)),
              subtitle: Text(_metricSubtitle(metric)),
            );
          }).toList(),
        ),
        if (metrics.length > 20)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.level2),
            child: Text(
              l10n.healthSyncPreviewMore(metrics.length - 20),
              style: context.theme.typography.body.md.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ),
      ],
    );
  }

  String _metricTitle(AppLocalizations l10n, HealthMetric metric) {
    final sleepDurationText = _sleepDurationText(metric.sleepDuration);
    return switch (metric.type) {
      HealthMetricType.heartRate => l10n.healthSyncMetricTitleHeartRate(
        metric.value.toStringAsFixed(0),
        metric.unit,
      ),
      HealthMetricType.bloodPressure => l10n.healthSyncMetricTitleBloodPressure(
        metric.value.toStringAsFixed(0),
        metric.secondaryValue?.toStringAsFixed(0) ?? '--',
        metric.unit,
      ),
      HealthMetricType.bloodOxygen => l10n.healthSyncMetricTitleBloodOxygen(
        metric.value.toStringAsFixed(1),
        metric.unit,
      ),
      HealthMetricType.bloodGlucose => l10n.healthSyncMetricTitleBloodGlucose(
        metric.value.toStringAsFixed(1),
        metric.unit,
      ),
      HealthMetricType.bodyTemperature =>
        l10n.healthSyncMetricTitleBodyTemperature(
          metric.value.toStringAsFixed(1),
          metric.unit,
        ),
      HealthMetricType.weight => l10n.healthSyncMetricTitleWeight(
        metric.value.toStringAsFixed(1),
        metric.unit,
      ),
      HealthMetricType.respiratoryRate =>
        l10n.healthSyncMetricTitleRespiratoryRate(
          metric.value.toStringAsFixed(0),
          metric.unit,
        ),
      HealthMetricType.steps => l10n.healthSyncMetricTitleSteps(
        metric.value.toStringAsFixed(0),
        metric.unit,
      ),
      HealthMetricType.flightsClimbed =>
        l10n.healthSyncMetricTitleFlightsClimbed(
          metric.value.toStringAsFixed(0),
          metric.unit,
        ),
      HealthMetricType.exerciseTime => l10n.healthSyncMetricTitleExerciseTime(
        metric.value.toStringAsFixed(0),
        metric.unit,
      ),
      HealthMetricType.sleep => l10n.healthSyncMetricTitleSleep(
        sleepDurationText,
      ),
      HealthMetricType.water => l10n.healthSyncMetricTitleWater(
        metric.value.toStringAsFixed(2),
        metric.unit,
      ),
      HealthMetricType.height => l10n.healthSyncMetricTitleHeight(
        metric.value.toStringAsFixed(1),
        metric.unit,
      ),
    };
  }

  String _sleepDurationText(Duration? duration) {
    return '${duration?.inHours ?? 0}h ${(duration?.inMinutes ?? 0) % 60}m';
  }

  String _metricSubtitle(HealthMetric metric) {
    final dt = metric.recordedAt;
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
