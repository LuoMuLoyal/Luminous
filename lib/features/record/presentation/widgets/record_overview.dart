import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/record_components.dart';
import 'package:luminous/features/record/presentation/widgets/record_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordWeekStrip extends StatelessWidget {
  const RecordWeekStrip({
    super.key,
    required this.days,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<RecordWeekDay> days;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return RecordSectionSurface(
      typography: typography,
      surface: surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.sm,
        vertical: AppSpacingTokens.md,
      ),
      child: Row(
        children: days
            .map(
              (day) => Expanded(
                child: _WeekDayCell(
                  day: day,
                  l10n: l10n,
                  typography: typography,
                  surface: surface,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class RecordQuickActions extends StatelessWidget {
  const RecordQuickActions({
    super.key,
    required this.actions,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.compact = false,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return RecordSectionSurface(
      key: const Key('record-quick-actions'),
      title: l10n.recordQuickSectionTitle,
      typography: typography,
      surface: surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = compact || constraints.maxWidth < 520 ? 4 : 7;
          return Wrap(
            spacing: AppSpacingTokens.sm,
            runSpacing: AppSpacingTokens.sm,
            children: actions
                .map(
                  (action) => SizedBox(
                    width:
                        (constraints.maxWidth -
                            AppSpacingTokens.sm * (columns - 1)) /
                        columns,
                    child: _QuickActionTile(
                      action: action,
                      l10n: l10n,
                      typography: typography,
                      surface: surface,
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class RecordSummaryGrid extends StatelessWidget {
  const RecordSummaryGrid({
    super.key,
    required this.summary,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final RecordDaySummary summary;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return RecordSectionSurface(
      key: const Key('record-summary'),
      title: l10n.recordSummarySectionTitle,
      subtitle: l10n.recordSummaryDateLabel,
      typography: typography,
      surface: surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 520 ? 2 : 5;
          return Wrap(
            spacing: AppSpacingTokens.sm,
            runSpacing: AppSpacingTokens.sm,
            children: summary.items
                .map(
                  (item) => SizedBox(
                    width:
                        (constraints.maxWidth -
                            AppSpacingTokens.sm * (columns - 1)) /
                        columns,
                    child: _SummaryTile(
                      item: item,
                      l10n: l10n,
                      typography: typography,
                      surface: surface,
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class RecordNewEntryPanel extends StatelessWidget {
  const RecordNewEntryPanel({
    super.key,
    required this.actions,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return RecordSectionSurface(
      key: const Key('record-new-entry-panel'),
      title: l10n.recordNewEntrySectionTitle,
      typography: typography,
      surface: surface,
      child: Column(
        children: [
          Wrap(
            spacing: AppSpacingTokens.sm,
            runSpacing: AppSpacingTokens.sm,
            children: actions
                .take(7)
                .map(
                  (action) => _NewEntryChip(
                    action: action,
                    l10n: l10n,
                    typography: typography,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => showRecordToast(context, l10n.recordVoiceAction),
              borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: surface.canvasSoft,
                  borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                  border: Border.all(color: surface.hairline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.mic_none_rounded,
                        color: Color(0xFF159B55),
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      Flexible(
                        child: Text(
                          l10n.recordVoiceAction,
                          style: typography.bodySmStrong.copyWith(
                            color: const Color(0xFF159B55),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekDayCell extends StatelessWidget {
  const _WeekDayCell({
    required this.day,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final RecordWeekDay day;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF159B55);
    final foreground = day.selected
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            showRecordToast(context, '${l10n.recordOpenDateAction} ${day.day}'),
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.xs),
          child: Column(
            children: [
              Text(
                recordCopy(l10n, day.weekdayKey),
                style: typography.caption.copyWith(color: surface.body),
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: day.selected ? accent : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 30,
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: typography.bodySmStrong.copyWith(
                        color: foreground,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              _MarkerDots(colors: day.markers, hasAlert: day.hasAlert),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.action,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final label = recordCopy(l10n, action.titleKey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showRecordToast(context, label),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: action.softColor.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: surface.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.xs,
              vertical: AppSpacingTokens.md,
            ),
            child: Column(
              children: [
                RecordIconBadge(
                  icon: action.icon,
                  color: action.accent,
                  backgroundColor: Colors.white.withValues(alpha: 0.7),
                  size: 40,
                ),
                const SizedBox(height: AppSpacingTokens.sm),
                Text(
                  label,
                  style: typography.bodySmStrong,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.item,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final RecordSummaryItem item;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final unit = item.unitKey == null ? null : recordCopy(l10n, item.unitKey!);
    final detail = item.detailKey == null
        ? null
        : recordCopy(l10n, item.detailKey!);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showRecordToast(context, recordCopy(l10n, item.titleKey)),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvasSoft,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: surface.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RecordIconBadge(
                      icon: item.icon,
                      color: item.accent,
                      backgroundColor: item.softColor,
                      size: 30,
                      iconSize: 17,
                    ),
                    const SizedBox(width: AppSpacingTokens.sm),
                    Expanded(
                      child: Text(
                        recordCopy(l10n, item.titleKey),
                        style: typography.caption.copyWith(color: surface.body),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.sm),
                if (item.value.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      style: typography.displaySm.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(text: item.value),
                        if (unit != null)
                          TextSpan(
                            text: ' $unit',
                            style: typography.caption.copyWith(
                              color: surface.body,
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  Text(detail ?? '', style: typography.bodySmStrong),
                if (detail != null && item.value.isNotEmpty) ...[
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    detail,
                    style: typography.caption.copyWith(color: item.accent),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewEntryChip extends StatelessWidget {
  const _NewEntryChip({
    required this.action,
    required this.l10n,
    required this.typography,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final AppTypographyScale typography;

  @override
  Widget build(BuildContext context) {
    final label = recordCopy(l10n, action.titleKey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showRecordToast(context, label),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: action.softColor.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.sm,
              vertical: AppSpacingTokens.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(action.icon, color: action.accent, size: 16),
                const SizedBox(width: AppSpacingTokens.xs),
                Text(
                  label,
                  style: typography.caption.copyWith(
                    color: action.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkerDots extends StatelessWidget {
  const _MarkerDots({required this.colors, required this.hasAlert});

  final List<Color> colors;
  final bool hasAlert;

  @override
  Widget build(BuildContext context) {
    final markerColors = hasAlert
        ? [...colors, const Color(0xFFFF4D57)]
        : colors;

    return SizedBox(
      height: 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: markerColors
            .take(3)
            .map(
              (color) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox.square(dimension: 4),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
