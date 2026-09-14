import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/services/unit_conversion.dart';
import 'package:luminous/features/record/application/usecases/record_detail_actions.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/data/providers/water_target.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/controllers/meal_analysis_poller.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/utils/detail_labels.dart';
import 'package:luminous/features/record/presentation/utils/meal_analysis_payload_parser.dart';
import 'package:luminous/features/record/presentation/utils/sleep_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/detail/hero_avatar.dart';
import 'package:luminous/features/record/presentation/widgets/detail/image.dart';
import 'package:luminous/features/record/presentation/widgets/detail/info_rows.dart';
import 'package:luminous/features/record/presentation/widgets/detail/source_badge.dart';
import 'package:luminous/features/record/presentation/widgets/detail/surface.dart';
import 'package:luminous/features/record/presentation/widgets/detail/water_progress.dart';
import 'package:luminous/features/record/presentation/widgets/meal/analysis_status_badge.dart';
import 'package:luminous/features/record/presentation/widgets/meal/analysis_summary_card.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordDetailBody extends ConsumerStatefulWidget {
  const RecordDetailBody({super.key, required this.record});

  final DailyRecordItem record;

  @override
  ConsumerState<RecordDetailBody> createState() => _RecordDetailBodyState();
}

class _RecordDetailBodyState extends ConsumerState<RecordDetailBody> {
  late final MealAnalysisPoller _poller;

  /// Guards against re-entrant meal-analysis confirm requests while one is in
  /// flight; the summary card shows a loading state while this is true.
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _poller = MealAnalysisPoller(recordId: widget.record.id, ref: ref);
  }

  @override
  void dispose() {
    _poller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final record = widget.record;

    final imageAttachment = record.attachments
        .where((item) => item.kind == DailyRecordAttachmentKind.image)
        .firstOrNull;
    final mealAnalysis = record.kind == DailyRecordKind.meal
        ? parseMealAnalysisViewData(record.payload)
        : null;

    // Same-day records drive adjacent navigation and the water progress card.
    final recordDate = DateTime.tryParse(record.occurredAt);
    final dayList = recordDate == null
        ? null
        : ref.watch(dailyRecordListForDateProvider(recordDate));
    final dayItems = <DailyRecordItem>[...?dayList?.asData?.value.items]
      ..sort(compareRecords);
    final currentIndex = dayItems.indexWhere((item) => item.id == record.id);
    final previousRecord = currentIndex > 0 ? dayItems[currentIndex - 1] : null;
    final nextRecord = currentIndex >= 0 && currentIndex < dayItems.length - 1
        ? dayItems[currentIndex + 1]
        : null;

    // Aggregate today's water in ml for the progress card (ml units only).
    var waterTotalMl = 0;
    final typography = context.theme.typography;
    for (final item in dayItems) {
      if (item.kind == DailyRecordKind.water && item.unit == 'ml') {
        final value = int.tryParse(item.value ?? '');
        if (value != null && value > 0) waterTotalMl += value;
      }
    }

    // Daily water target (ml) for the progress card: read from user-settings
    // `waterTargetCount × 250`, the same source as Today Analysis. While
    // settings are loading or fail, the mirrored default (8 × 250 = 2000 ml)
    // keeps the card stable; the target is always > 0, guarding the progress
    // ratio against division by zero. Only water records with ml data watch
    // settings, so other record kinds do not trigger a settings fetch.
    final waterTargetCount =
        record.kind == DailyRecordKind.water && waterTotalMl > 0
        ? ref.watch(recordWaterTargetCountProvider).asData?.value ??
              recordWaterDefaultTargetCount
        : 0;
    final waterTargetMl = waterTargetCount * recordWaterMlPerCount;

    // Unit system for display-only conversions (kg/lb, ml/fl oz). Read from
    // the shared health-context snapshot; while loading or on error it falls
    // back to null = metric. Only water records with ml data watch the
    // snapshot, so other record kinds do not trigger a health-context fetch
    // (same conditional-watch pattern as recordWaterTargetCountProvider).
    final unitSystem = record.kind == DailyRecordKind.water && waterTotalMl > 0
        ? ref
              .watch(healthContextSnapshotProvider)
              .asData
              ?.value
              .profile
              .unitSystem
        : null;
    final isImperialWater = isImperialUnitSystem(unitSystem);

    // Sync the analysis poller with the current status.
    final isAnalyzing =
        mealAnalysis != null && mealAnalysis.status == 'analyzing';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _poller.sync(isAnalyzing);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KindHeroAvatar(kind: record.kind),
                  const SizedBox(width: Spacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                record.title ?? kindLabel(l10n, record.kind),
                                style: typography.display.xl.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (nonEmpty(record.source) != null) ...[
                              const SizedBox(width: Spacing.md),
                              SourceBadge(
                                label: sourceLabel(l10n, record.source!),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          formatRecordDateTimeLabel(
                            record.occurredAt,
                            occurredTime: record.occurredTime,
                          ),
                          style: typography.body.xs.copyWith(
                            color: SemanticColor.neutral.solid(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xl),
              DetailRows(
                rows: [
                  DetailRowData(
                    l10n.recordCreateFieldKind,
                    kindLabel(l10n, record.kind),
                  ),
                  if (nonEmpty(record.value) != null)
                    DetailRowData(
                      l10n.recordDetailValueLabel,
                      valueWithUnit(record.value!, record.unit),
                      highlight: true,
                    ),
                  if (moodLabel(l10n, record) != null)
                    DetailRowData(
                      l10n.recordDetailMoodLabel,
                      moodLabel(l10n, record)!,
                    ),
                  if (nonEmpty(record.note) != null)
                    DetailRowData(l10n.recordCreateFieldNote, record.note!),
                  DetailRowData(
                    l10n.recordDetailUpdatedAtLabel,
                    formatRecordDateTimeLabel(record.updatedAt),
                  ),
                ],
              ),
              ..._buildSleepDetails(l10n, record.payload),
            ],
          ),
        ),
        if (record.kind == DailyRecordKind.meal && mealAnalysis != null) ...[
          const SizedBox(height: Spacing.lg),
          if (mealAnalysis.status == 'analyzing')
            DetailSurface(
              child: Row(
                children: [
                  MealAnalysisStatusBadge(
                    status: mealAnalysis.status,
                    coverage: mealAnalysis.coverage,
                    large: true,
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Text(
                      l10n.recordMealAnalysisStatusAnalyzing,
                      style: typography.body.xs.copyWith(
                        color: SemanticColor.neutral.solid(context),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (mealAnalysis.status == 'analysis_failed')
            DetailSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MealAnalysisStatusBadge(
                    status: mealAnalysis.status,
                    coverage: mealAnalysis.coverage,
                    large: true,
                  ),
                  if (nonEmpty(mealAnalysis.failureReason) != null) ...[
                    const SizedBox(height: Spacing.md),
                    Text(
                      mealAnalysis.failureReason!,
                      style: typography.body.xs.copyWith(
                        color: SemanticColor.neutral.solid(context),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            MealAnalysisSummaryCard(
              data: mealAnalysis,
              onConfirm: _handleConfirmMealAnalysis,
              isConfirming: _isConfirming,
            ),
        ],
        if (imageAttachment != null) ...[
          const SizedBox(height: Spacing.lg),
          DetailSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.recordImageSectionTitle,
                  style: typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                RecordDetailImage(attachment: imageAttachment),
                if (nonEmpty(imageAttachment.fileName) != null) ...[
                  const SizedBox(height: Spacing.md),
                  Text(
                    imageAttachment.fileName!,
                    style: typography.body.xs.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
        if (record.kind == DailyRecordKind.water && waterTotalMl > 0) ...[
          const SizedBox(height: Spacing.lg),
          WaterProgressCard(
            waterTotalMl: waterTotalMl,
            waterTargetMl: waterTargetMl,
            isImperialWater: isImperialWater,
          ),
        ],
        const SizedBox(height: Spacing.lg),
        FButton(
          key: const Key('record-detail-edit-action'),
          onPress: () => editRecord(context, record.id),
          prefix: const Icon(SemanticIcons.actionEdit, size: 18),
          child: Text(l10n.recordDetailEditAction),
        ),
        const SizedBox(height: Spacing.lg),
        Row(
          children: [
            Expanded(
              child: FButton(
                key: const Key('record-detail-previous-action'),
                variant: FButtonVariant.ghost,
                onPress: previousRecord == null
                    ? null
                    : () => context.pushReplacement(
                        '/record/${previousRecord.id}',
                      ),
                prefix: const Icon(SemanticIcons.actionPrev),
                child: Text(l10n.recordDetailPreviousAction),
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: FButton(
                key: const Key('record-detail-next-action'),
                variant: FButtonVariant.ghost,
                onPress: nextRecord == null
                    ? null
                    : () => context.pushReplacement('/record/${nextRecord.id}'),
                suffix: const Icon(SemanticIcons.actionNext),
                child: Text(l10n.recordDetailNextAction),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        FButton(
          key: const Key('record-detail-copy-action'),
          variant: FButtonVariant.ghost,
          onPress: () => unawaited(copyRecordSummary(context, l10n, record)),
          prefix: const Icon(SemanticIcons.actionCopy, size: 18),
          child: Text(l10n.recordDetailCopyAction),
        ),
        const SizedBox(height: Spacing.lg),
        FButton(
          key: const Key('record-detail-delete-action'),
          variant: FButtonVariant.destructive,
          onPress: () => deleteRecord(
            ref: ref,
            context: context,
            recordId: record.id,
            popCount: 1,
          ),
          prefix: const Icon(SemanticIcons.actionDelete, size: 18),
          child: Text(l10n.recordDeleteAction),
        ),
      ],
    );
  }

  void _handleConfirmMealAnalysis() {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);
    unawaited(
      confirmMealAnalysis(
        ref: ref,
        context: context,
        recordId: widget.record.id,
      ).whenComplete(() {
        if (mounted) setState(() => _isConfirming = false);
      }),
    );
  }

  List<Widget> _buildSleepDetails(
    AppLocalizations l10n,
    Map<String, dynamic>? payload,
  ) {
    if (payload == null || widget.record.kind != DailyRecordKind.sleep) {
      return const [];
    }

    final rows = <DetailRowData>[];

    final startAt = payload['startedAt'] as String?;
    final endAt = payload['endedAt'] as String?;
    if (startAt != null && endAt != null) {
      final startDt = DateTime.tryParse(startAt);
      final endDt = DateTime.tryParse(endAt);
      if (startDt != null && endDt != null) {
        final range = formatSleepTimeRange(
          TimeOfDay.fromDateTime(startDt.toLocal()),
          TimeOfDay.fromDateTime(endDt.toLocal()),
        );
        if (range != null) {
          rows.add(DetailRowData(l10n.recordSleepTimeRangeLabel, range));
        }
      }
    }

    final durationMinutes = payload['durationMinutes'];
    if (durationMinutes is num && durationMinutes > 0) {
      final h = durationMinutes ~/ 60;
      final m = durationMinutes.round() % 60;
      final text = m == 0
          ? '$h${l10n.todayVitalSleepUnit}'
          : '$h${l10n.todayVitalSleepUnit} $m${l10n.recordSleepMinutesUnit}';
      rows.add(DetailRowData(l10n.recordSleepDurationLabel, text));
    }

    final quality = payload['quality'] as String?;
    if (quality != null) {
      final qualityLbl = sleepQualityLabel(l10n, quality);
      rows.add(DetailRowData(l10n.recordSleepQualityLabel, qualityLbl));
    }

    final deep = payload['deepMinutes'];
    if (deep is num && deep > 0) {
      rows.add(
        DetailRowData(l10n.recordSleepDeepMinutesLabel, '${deep.round()}'),
      );
    }
    final light = payload['lightMinutes'];
    if (light is num && light > 0) {
      rows.add(
        DetailRowData(l10n.recordSleepLightMinutesLabel, '${light.round()}'),
      );
    }
    final rem = payload['remMinutes'];
    if (rem is num && rem > 0) {
      rows.add(
        DetailRowData(l10n.recordSleepRemMinutesLabel, '${rem.round()}'),
      );
    }

    if (rows.isEmpty) return const [];

    return [const SizedBox(height: Spacing.xl), DetailRows(rows: rows)];
  }
}
