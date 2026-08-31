import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/services/unit_conversion.dart';
import 'package:luminous/features/record/application/usecases/record_detail_actions.dart';
import 'package:luminous/features/record/data/datasources/quick_entry_preferences.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/data/providers/water_target.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/type_mapping.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/utils/meal_analysis_payload_parser.dart';
import 'package:luminous/features/record/presentation/widgets/forms/sleep_structured_fields.dart';
import 'package:luminous/features/record/presentation/widgets/meal/analysis_status_badge.dart';
import 'package:luminous/features/record/presentation/widgets/meal/analysis_summary_card.dart';
import 'package:luminous/features/record/presentation/widgets/shared/dashboard_tokens.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordDetailPage extends ConsumerWidget {
  const RecordDetailPage({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    final Widget content;

    if (!session.canAccessProtectedData) {
      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile
                ? Spacing.level6
                : Spacing.level7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              session.isLoading
                  ? const _RecordDetailLoading()
                  : AuthRequiredDialogGate(
                      onLogin: () =>
                          context.push(loginRouteForCurrentLocation(context)),
                    ),
            ],
          ),
        ),
      );
    } else {
      final detail = ref.watch(dailyRecordDetailProvider(recordId));

      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile
                ? Spacing.level6
                : Spacing.level7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              detail.when(
                data: (record) => _RecordDetailBody(record: record),
                loading: () => const _RecordDetailLoading(),
                error: (_, __) => StateErrorView(
                  title: l10n.recordDetailErrorTitle,
                  description: l10n.recordErrorDescription,
                  icon: SemanticIcons.tabRecord,
                  actionLabel: l10n.todayRetryAction,
                  onAction: () =>
                      ref.invalidate(dailyRecordDetailProvider(recordId)),
                  tone: StateTone.warning,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // The edit entry point lives in the page body as the primary action,
    // keeping the header clean and the detail page clearly read-only.
    return PageScaffold(
      title: l10n.recordDetailTitle,
      child: SingleChildScrollView(child: content),
    );
  }
}

class _RecordDetailBody extends ConsumerStatefulWidget {
  const _RecordDetailBody({required this.record});

  final DailyRecordItem record;

  @override
  ConsumerState<_RecordDetailBody> createState() => _RecordDetailBodyState();
}

class _RecordDetailBodyState extends ConsumerState<_RecordDetailBody> {
  Timer? _analysisPoller;

  /// Guards against overlapping polls: when a refresh takes longer than the
  /// current interval, the next tick is skipped instead of stacking requests.
  bool _isPolling = false;

  /// Guards against re-entrant meal-analysis confirm requests while one is in
  /// flight; the summary card shows a loading state while this is true.
  bool _isConfirming = false;

  /// Current poll interval. Starts at [_initialPollInterval] and backs off
  /// exponentially on failure up to [_maxPollInterval].
  Duration _pollInterval = _initialPollInterval;

  static const _initialPollInterval = Duration(seconds: 5);
  static const _maxPollInterval = Duration(seconds: 30);

  @override
  void dispose() {
    _analysisPoller?.cancel();
    super.dispose();
  }

  /// Start/stop the analysis poller based on the current meal analysis status.
  void _syncAnalysisPoller(bool isAnalyzing) {
    if (isAnalyzing && _analysisPoller == null) {
      _pollInterval = _initialPollInterval;
      _scheduleNextPoll();
    } else if (!isAnalyzing && _analysisPoller != null) {
      _analysisPoller!.cancel();
      _analysisPoller = null;
    }
  }

  /// Schedules the next poll as a chained single-shot [Timer] instead of
  /// `Timer.periodic`, so each round can apply backoff and skip while a
  /// previous request is still in flight.
  void _scheduleNextPoll() {
    _analysisPoller?.cancel();
    _analysisPoller = Timer(_pollInterval, () async {
      if (!mounted || _isPolling) return;
      _isPolling = true;
      try {
        // Invalidate + read triggers a fresh load; awaiting its future lets
        // the lock cover the whole request instead of just the tick.
        ref.invalidate(dailyRecordDetailProvider(widget.record.id));
        await ref.read(dailyRecordDetailProvider(widget.record.id).future);
        // Successful refresh: reset to the base interval (analysis is
        // presumably still running while this poller is active).
        _pollInterval = _initialPollInterval;
      } catch (_) {
        // Transient failure: back off so a degraded backend is not
        // hammered at the base rate.
        final doubled = Duration(seconds: _pollInterval.inSeconds * 2);
        _pollInterval = doubled > _maxPollInterval ? _maxPollInterval : doubled;
      } finally {
        _isPolling = false;
      }
      if (!mounted) return;
      _scheduleNextPoll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
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
      ..sort(_compareRecords);
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
      if (mounted) _syncAnalysisPoller(isAnalyzing);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetailSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KindHeroAvatar(kind: record.kind),
                  const SizedBox(width: Spacing.level4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                record.title ?? _kindLabel(l10n, record.kind),
                                style: typography.display.xl.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (_nonEmpty(record.source) != null) ...[
                              const SizedBox(width: Spacing.level3),
                              _SourceBadge(
                                label: _sourceLabel(l10n, record.source!),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: Spacing.level2),
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
              const SizedBox(height: Spacing.level5),
              _DetailRows(
                rows: [
                  _DetailRowData(
                    l10n.recordCreateFieldKind,
                    _kindLabel(l10n, record.kind),
                  ),
                  if (_nonEmpty(record.value) != null)
                    _DetailRowData(
                      l10n.recordDetailValueLabel,
                      _valueWithUnit(record.value!, record.unit),
                      highlight: true,
                    ),
                  if (_moodLabel(l10n, record) != null)
                    _DetailRowData(
                      l10n.recordDetailMoodLabel,
                      _moodLabel(l10n, record)!,
                    ),
                  if (_nonEmpty(record.note) != null)
                    _DetailRowData(l10n.recordCreateFieldNote, record.note!),
                  _DetailRowData(
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
          const SizedBox(height: Spacing.level4),
          if (mealAnalysis.status == 'analyzing')
            _DetailSurface(
              child: Row(
                children: [
                  MealAnalysisStatusBadge(
                    status: mealAnalysis.status,
                    coverage: mealAnalysis.coverage,
                    large: true,
                  ),
                  const SizedBox(width: Spacing.level3),
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
            _DetailSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MealAnalysisStatusBadge(
                    status: mealAnalysis.status,
                    coverage: mealAnalysis.coverage,
                    large: true,
                  ),
                  if (_nonEmpty(mealAnalysis.failureReason) != null) ...[
                    const SizedBox(height: Spacing.level3),
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
              onConfirm: _confirmMealAnalysis,
              isConfirming: _isConfirming,
            ),
        ],
        if (imageAttachment != null) ...[
          const SizedBox(height: Spacing.level4),
          _DetailSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.recordImageSectionTitle,
                  style: typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.level4),
                _RecordDetailImage(attachment: imageAttachment),
                if (_nonEmpty(imageAttachment.fileName) != null) ...[
                  const SizedBox(height: Spacing.level3),
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
          const SizedBox(height: Spacing.level4),
          _DetailSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(SemanticIcons.recordWater, size: 18),
                    const SizedBox(width: Spacing.level3),
                    Expanded(
                      child: Text(
                        l10n.recordDetailDailyWaterTitle,
                        style: typography.body.sm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      isImperialWater
                          ? l10n.recordDetailDailyWaterProgressOz(
                              _formatFlOz(waterTotalMl),
                              _formatFlOz(waterTargetMl),
                            )
                          : l10n.recordDetailDailyWaterProgress(
                              waterTotalMl,
                              waterTargetMl,
                            ),
                      style: typography.body.xs.copyWith(
                        color: SemanticColor.neutral.solid(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.level4),
                ClipRRect(
                  borderRadius: context.theme.style.borderRadius.xs2,
                  child: LinearProgressIndicator(
                    value: (waterTotalMl / waterTargetMl).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: colors.muted,
                    color: SemanticColor.primary.solid(context),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: Spacing.level4),
        FButton(
          key: const Key('record-detail-edit-action'),
          onPress: () => editRecord(context, record.id),
          prefix: const Icon(SemanticIcons.actionEdit, size: 18),
          child: Text(l10n.recordDetailEditAction),
        ),
        const SizedBox(height: Spacing.level4),
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
            const SizedBox(width: Spacing.level3),
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
        const SizedBox(height: Spacing.level4),
        FButton(
          key: const Key('record-detail-copy-action'),
          variant: FButtonVariant.ghost,
          onPress: () => unawaited(_copySummary(context, l10n, record)),
          prefix: const Icon(SemanticIcons.actionCopy, size: 18),
          child: Text(l10n.recordDetailCopyAction),
        ),
        const SizedBox(height: Spacing.level4),
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

  /// Confirms the meal-analysis result in place, reusing the same PATCH
  /// `analysisStatus='confirmed'` chain as the edit page. On success the
  /// detail provider is invalidated so the badge flips to confirmed and the
  /// DataChangeBus broadcasts [DataChangeTopic.dailyRecords] so keepAlive
  /// dashboards (e.g. the record timeline) refresh; on failure the state is
  /// untouched and an error toast is shown.
  Future<void> _confirmMealAnalysis() async {
    if (_isConfirming) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isConfirming = true);
    try {
      final result = await ref
          .read(dailyRecordRepositoryProvider)
          .update(
            widget.record.id,
            const DailyRecordUpdateInput(
              payload: <String, dynamic>{
                'mealAnalysis': <String, dynamic>{
                  'analysisStatus': 'confirmed',
                },
              },
            ),
          )
          .run();
      result.fold((failure) => throw failure, (_) {});
      if (!mounted) return;
      ref.invalidate(dailyRecordDetailProvider(widget.record.id));
      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.dailyRecords);
      await Toast.show(context, l10n.recordCreateSavedToast);
    } catch (e, st) {
      ref.read(talkerProvider).error('_confirmMealAnalysis: failed: $e', st);
      if (!mounted) return;
      await Toast.show(context, l10n.recordMealConfirmFailedToast);
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  Future<void> _copySummary(
    BuildContext context,
    AppLocalizations l10n,
    DailyRecordItem record,
  ) async {
    final lines = <String>[
      '${l10n.recordCreateFieldKind}：${_kindLabel(l10n, record.kind)}',
      if (_nonEmpty(record.value) != null)
        '${l10n.recordDetailValueLabel}：${_valueWithUnit(record.value!, record.unit)}',
      if (_moodLabel(l10n, record) != null)
        '${l10n.recordDetailMoodLabel}：${_moodLabel(l10n, record)}',
      if (_nonEmpty(record.note) != null)
        '${l10n.recordCreateFieldNote}：${record.note}',
      if (_nonEmpty(record.source) != null)
        '${l10n.recordDetailSourceLabel}：${_sourceLabel(l10n, record.source!)}',
      '${l10n.recordDetailUpdatedAtLabel}：${formatRecordDateTimeLabel(record.updatedAt)}',
    ];
    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (context.mounted) {
      await Toast.show(context, l10n.recordDetailCopiedToast);
    }
  }

  List<Widget> _buildSleepDetails(
    AppLocalizations l10n,
    Map<String, dynamic>? payload,
  ) {
    if (payload == null || widget.record.kind != DailyRecordKind.sleep) {
      return const [];
    }

    final rows = <_DetailRowData>[];

    final startAt = payload['startAt'] as String?;
    final endAt = payload['endAt'] as String?;
    if (startAt != null && endAt != null) {
      final startDt = DateTime.tryParse(startAt);
      final endDt = DateTime.tryParse(endAt);
      if (startDt != null && endDt != null) {
        final range = formatSleepTimeRange(
          TimeOfDay.fromDateTime(startDt.toLocal()),
          TimeOfDay.fromDateTime(endDt.toLocal()),
        );
        if (range != null) {
          rows.add(_DetailRowData(l10n.recordSleepTimeRangeLabel, range));
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
      rows.add(_DetailRowData(l10n.recordSleepDurationLabel, text));
    }

    final quality = payload['quality'] as String?;
    if (quality != null) {
      final qualityLabel = _sleepQualityLabel(l10n, quality);
      rows.add(_DetailRowData(l10n.recordSleepQualityLabel, qualityLabel));
    }

    final deep = payload['deepMinutes'];
    if (deep is num && deep > 0) {
      rows.add(
        _DetailRowData(l10n.recordSleepDeepMinutesLabel, '${deep.round()}'),
      );
    }
    final light = payload['lightMinutes'];
    if (light is num && light > 0) {
      rows.add(
        _DetailRowData(l10n.recordSleepLightMinutesLabel, '${light.round()}'),
      );
    }
    final rem = payload['remMinutes'];
    if (rem is num && rem > 0) {
      rows.add(
        _DetailRowData(l10n.recordSleepRemMinutesLabel, '${rem.round()}'),
      );
    }

    if (rows.isEmpty) return const [];

    return [const SizedBox(height: Spacing.level5), _DetailRows(rows: rows)];
  }
}

class _DetailRows extends StatelessWidget {
  const _DetailRows({required this.rows});

  final List<_DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < rows.length; index += 1) ...[
          _DetailRow(data: rows[index]),
          if (index != rows.length - 1) const AppDivider(),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.data});

  final _DetailRowData data;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.level3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: Spacing.level8 * 2,
              maxWidth: Spacing.level8 * 2 + Spacing.level4,
            ),
            child: Text(
              data.label,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ),
          const SizedBox(width: Spacing.level4),
          Expanded(
            child: Text(
              data.value,
              style: data.highlight
                  ? typography.display.lg.copyWith(
                      fontWeight: FontWeight.w800,
                      color: SemanticColor.primary.solid(context),
                    )
                  : typography.body.md.copyWith(fontWeight: FontWeight.w700),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRowData {
  const _DetailRowData(this.label, this.value, {this.highlight = false});

  final String label;
  final String value;

  /// Renders the value at a larger, primary-colored size (receipt-style
  /// emphasis for the record's key number).
  final bool highlight;
}

class _DetailSurface extends StatelessWidget {
  const _DetailSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: child,
      ),
    );
  }
}

/// Hero avatar for the record detail header.
///
/// Uses the kind's quick-action accent colors and resolves the user-customized
/// icon (same source as the quick-entry panel), so the same record reads
/// consistently across surfaces. Falls back to the neutral primary style for
/// kinds without a quick action (vitals / activity).
class _KindHeroAvatar extends ConsumerWidget {
  const _KindHeroAvatar({required this.kind});

  final DailyRecordKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final entryType = recordEntryTypeForDailyRecordKind(kind);
    final action = RecordDashboard.quickActionFor(entryType);
    final prefs =
        ref.watch(quickEntryPreferencesProvider).asData?.value ??
        const QuickEntryPreferences();

    final accent =
        action?.accent.solid(context) ?? SemanticColor.primary.solid(context);
    final soft = action?.softColor.subtle(context) ?? colors.secondary;
    final icon = action == null
        ? _kindIconFallback(kind)
        : resolveQuickActionIcon(action, prefs);

    return FAvatar.raw(
      size: 52,
      style: .delta(backgroundColor: soft),
      child: Icon(icon, color: accent, size: 24),
    );
  }
}

/// Lightweight source badge shown next to the detail title.
class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: context.theme.style.borderRadius.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level2,
          vertical: 1,
        ),
        child: Text(
          label,
          style: context.theme.typography.body.xs3.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
      ),
    );
  }
}

/// Fallback icon for kinds without a quick action (vitals / activity).
IconData _kindIconFallback(DailyRecordKind kind) {
  return switch (kind) {
    DailyRecordKind.water => SemanticIcons.recordWater,
    DailyRecordKind.meal => SemanticIcons.recordMeal,
    DailyRecordKind.vital => SemanticIcons.profileCondition,
    DailyRecordKind.mood => SemanticIcons.recordMood,
    DailyRecordKind.symptom => SemanticIcons.safetyDanger,
    DailyRecordKind.activity => SemanticIcons.recordActivity,
    DailyRecordKind.note => SemanticIcons.tabRecord,
    DailyRecordKind.sleep => SemanticIcons.recordSleep,
  };
}

class _RecordDetailImage extends StatelessWidget {
  const _RecordDetailImage({required this.attachment});

  final DailyRecordAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final imageUrl = attachment.displayUrl;

    return ClipRRect(
      borderRadius: context.theme.style.borderRadius.sm,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: SemanticColor.neutral.subtle(context),
          ),
          child: imageUrl == null
              ? Center(
                  child: Icon(
                    SemanticIcons.actionImage,
                    color: SemanticColor.neutral.solid(context),
                    size: 28,
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: Icon(
                      SemanticIcons.actionImage,
                      color: SemanticColor.neutral.solid(context),
                      size: 28,
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(
                      SemanticIcons.statusUnavailable,
                      color: SemanticColor.neutral.solid(context),
                      size: 28,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _RecordDetailLoading extends StatelessWidget {
  const _RecordDetailLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InlineSkeletonSection(
          children: [
            InlineSkeletonBlock(height: 18, widthFactor: 0.34),
            InlineSkeletonBlock(height: 42),
            InlineSkeletonBlock(height: 18, widthFactor: 0.74),
          ],
        ),
        SizedBox(height: Spacing.level4),
        InlineSkeletonSection(
          children: [
            InlineSkeletonBlock(height: 160),
            InlineSkeletonBlock(height: 18, widthFactor: 0.42),
          ],
        ),
      ],
    );
  }
}

/// Orders same-day records by occurrence date/time (ascending).
int _compareRecords(DailyRecordItem a, DailyRecordItem b) {
  final byDate = a.occurredAt.compareTo(b.occurredAt);
  if (byDate != 0) return byDate;
  return (a.occurredTime ?? '').compareTo(b.occurredTime ?? '');
}

/// Returns the localized mood label for a mood record, or null when the
/// record is not a mood or has no recognizable mood payload.
String? _moodLabel(AppLocalizations l10n, DailyRecordItem record) {
  if (record.kind != DailyRecordKind.mood) return null;
  final label = record.payload?['moodLabel'];
  if (label is! String) return null;
  return switch (label) {
    'great' => l10n.recordTimelineMoodGreat,
    'good' => l10n.recordTimelineMoodGood,
    'okay' => l10n.recordTimelineMoodOkay,
    'bad' => l10n.recordTimelineMoodBad,
    'terrible' => l10n.recordTimelineMoodTerrible,
    _ => null,
  };
}

String _kindLabel(AppLocalizations l10n, DailyRecordKind kind) {
  return switch (kind) {
    DailyRecordKind.water => l10n.recordTypeWater,
    DailyRecordKind.meal => l10n.recordTypeMeal,
    DailyRecordKind.vital => l10n.recordTypeVitals,
    DailyRecordKind.mood => l10n.recordTypeMood,
    DailyRecordKind.symptom => l10n.recordTypeSymptom,
    DailyRecordKind.activity => l10n.recordTypeActivity,
    DailyRecordKind.note => l10n.recordCreateKindNote,
    DailyRecordKind.sleep => l10n.recordTypeSleep,
  };
}

String _valueWithUnit(String value, String? unit) {
  final trimmedUnit = unit?.trim();
  if (trimmedUnit == null || trimmedUnit.isEmpty) return value;
  return '$value $trimmedUnit';
}

/// Formats an ml value as a fl oz string with one decimal place for the
/// imperial water progress label (e.g. "18.6"). Display-only conversion;
/// storage stays in ml.
String _formatFlOz(num ml) => waterInFlOz(ml).toStringAsFixed(1);

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

String _sleepQualityLabel(AppLocalizations l10n, String quality) {
  return switch (quality) {
    'poor' => l10n.recordSleepQualityPoor,
    'fair' => l10n.recordSleepQualityFair,
    'good' => l10n.recordSleepQualityGood,
    'excellent' => l10n.recordSleepQualityExcellent,
    _ => quality,
  };
}

/// Maps a record source wire value to a user-facing label.
/// Returns the raw value for unknown sources so data is not hidden.
String _sourceLabel(AppLocalizations l10n, String source) {
  return switch (source) {
    'manual' => l10n.recordSourceManual,
    'local' => l10n.recordSourceLocal,
    'ai' => l10n.recordSourceAi,
    'import' => l10n.recordSourceImport,
    _ => source,
  };
}
