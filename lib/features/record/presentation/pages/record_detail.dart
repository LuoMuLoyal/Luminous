import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/record_type_colors.dart';
import 'package:luminous/features/record/presentation/providers/record_dashboard_provider.dart';
import 'package:luminous/features/record/presentation/utils/record_date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/forms/sleep_structured_fields.dart';
import 'package:luminous/features/report/presentation/providers/report_dashboard_provider.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordDetailPage extends ConsumerWidget {
  const RecordDetailPage({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    if (!session.canAccessProtectedData) {
      return PageScaffoldShell(
        title: l10n.recordDetailTitle,
        centerTitle: true,
        leading: const AppBackButton(),
        children: [
          session.isLoading
              ? const _RecordDetailLoading()
              : AuthRequiredDialogGate(
                  onLogin: () =>
                      context.push(loginRouteForCurrentLocation(context)),
                ),
        ],
      );
    }

    final detail = ref.watch(dailyRecordDetailProvider(recordId));

    return PageScaffoldShell(
      title: l10n.recordDetailTitle,
      centerTitle: true,
      leading: const AppBackButton(),
      actions: [
        IconButton(
          tooltip: l10n.recordEditAction,
          onPressed: () =>
              pushAuthRequiredRoute(context, '/record/$recordId/edit'),
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
      children: [
        detail.when(
          data: (record) => _RecordDetailBody(record: record),
          loading: () => const _RecordDetailLoading(),
          error: (_, __) => AppStateErrorView(
            title: l10n.recordDetailErrorTitle,
            description: l10n.recordErrorDescription,
            icon: Icons.edit_calendar_outlined,
            actionLabel: l10n.todayRetryAction,
            onAction: () => ref.invalidate(dailyRecordDetailProvider(recordId)),
            tone: AppStateTone.warning,
          ),
        ),
      ],
    );
  }
}

class _RecordDetailBody extends ConsumerWidget {
  const _RecordDetailBody({required this.record});

  final DailyRecordItem record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final imageAttachment = record.attachments
        .where((item) => item.kind == DailyRecordAttachmentKind.image)
        .firstOrNull;

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
                  _KindIcon(kind: record.kind),
                  const SizedBox(width: AppSpacingTokens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.title ?? _kindLabel(l10n, record.kind),
                          style: typography.displaySm,
                        ),
                        const SizedBox(height: AppSpacingTokens.xs),
                        Text(
                          formatRecordDateTimeLabel(
                            record.occurredAt,
                            occurredTime: record.occurredTime,
                          ),
                          style: typography.bodySm.copyWith(
                            color: surface.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.lg),
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
                    ),
                  if (_nonEmpty(record.note) != null)
                    _DetailRowData(l10n.recordCreateFieldNote, record.note!),
                  if (_nonEmpty(record.source) != null)
                    _DetailRowData(
                      l10n.recordDetailSourceLabel,
                      record.source!,
                    ),
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
        if (imageAttachment != null) ...[
          const SizedBox(height: AppSpacingTokens.md),
          _DetailSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.recordImageSectionTitle,
                  style: typography.bodyMdStrong,
                ),
                const SizedBox(height: AppSpacingTokens.md),
                _RecordDetailImage(attachment: imageAttachment),
                if (_nonEmpty(imageAttachment.fileName) != null) ...[
                  const SizedBox(height: AppSpacingTokens.sm),
                  Text(
                    imageAttachment.fileName!,
                    style: typography.caption.copyWith(color: surface.body),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacingTokens.md),
        FilledButton.icon(
          key: const Key('record-detail-edit-action'),
          onPressed: () =>
              pushAuthRequiredRoute(context, '/record/${record.id}/edit'),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(l10n.recordEditAction),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        OutlinedButton.icon(
          key: const Key('record-detail-delete-action'),
          onPressed: () => _deleteRecord(context, ref, record.id),
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          label: Text(l10n.recordDeleteAction),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSleepDetails(
    AppLocalizations l10n,
    Map<String, dynamic>? payload,
  ) {
    if (payload == null || record.kind != DailyRecordKind.sleep) {
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

    return [
      const SizedBox(height: AppSpacingTokens.lg),
      _DetailRows(rows: rows),
    ];
  }

  Future<void> _deleteRecord(
    BuildContext context,
    WidgetRef ref,
    String recordId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.recordDeleteAction),
        content: Text(l10n.recordDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.authCancelAction),
          ),
          FilledButton(
            key: const Key('record-delete-confirm-action'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.recordDeleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(dailyRecordRepositoryProvider).delete(recordId);
      ref.invalidate(dailyRecordDetailProvider(recordId));
      ref.invalidate(recordDashboardProvider);
      ref.invalidate(todayDashboardProvider);
      ref.invalidate(reportDashboardProvider);
      if (!context.mounted) return;
      await AppToast.show(context, l10n.mineEditDeletedToast);
      if (context.mounted) context.pop();
    } catch (_) {
      if (context.mounted) {
        await AppToast.show(context, l10n.recordCreateFailedToast);
      }
    }
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
          if (index != rows.length - 1)
            const SizedBox(height: AppSpacingTokens.md),
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
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            data.label,
            style: typography.bodySm.copyWith(color: surface.body),
          ),
        ),
        const SizedBox(width: AppSpacingTokens.md),
        Expanded(
          child: Text(
            data.value,
            style: typography.bodySmStrong,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}

class _DetailRowData {
  const _DetailRowData(this.label, this.value);

  final String label;
  final String value;
}

class _DetailSurface extends StatelessWidget {
  const _DetailSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
        boxShadow: AppShadowTokens.level1,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
        child: child,
      ),
    );
  }
}

class _KindIcon extends StatelessWidget {
  const _KindIcon({required this.kind});

  final DailyRecordKind kind;

  @override
  Widget build(BuildContext context) {
    final (color, background) = RecordTypeColors.forKind(kind);

    final icon = switch (kind) {
      DailyRecordKind.water => Icons.water_drop_rounded,
      DailyRecordKind.meal => Icons.restaurant_rounded,
      DailyRecordKind.vital => Icons.favorite_rounded,
      DailyRecordKind.mood => Icons.sentiment_satisfied_rounded,
      DailyRecordKind.symptom => Icons.healing_rounded,
      DailyRecordKind.activity => Icons.directions_run_rounded,
      DailyRecordKind.note => Icons.notes_rounded,
      DailyRecordKind.sleep => Icons.dark_mode_rounded,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      ),
      child: SizedBox.square(
        dimension: 44,
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _RecordDetailImage extends StatelessWidget {
  const _RecordDetailImage({required this.attachment});

  final DailyRecordAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final imageUrl = attachment.displayUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadiusTokens.md),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(color: surface.canvasSoft2),
          child: imageUrl == null
              ? Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: surface.mute,
                    size: 28,
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: surface.mute,
                      size: 28,
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: surface.mute,
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
        AppInlineSkeletonSection(
          children: [
            AppInlineSkeletonBlock(height: 18, widthFactor: 0.34),
            AppInlineSkeletonBlock(height: 42),
            AppInlineSkeletonBlock(height: 18, widthFactor: 0.74),
          ],
        ),
        SizedBox(height: AppSpacingTokens.md),
        AppInlineSkeletonSection(
          children: [
            AppInlineSkeletonBlock(height: 160),
            AppInlineSkeletonBlock(height: 18, widthFactor: 0.42),
          ],
        ),
      ],
    );
  }
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
