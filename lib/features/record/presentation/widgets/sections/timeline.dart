import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/sections/timeline_item.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:timeline_tile/timeline_tile.dart';

class RecordTimelinePanel extends StatelessWidget {
  const RecordTimelinePanel({
    super.key,
    required this.entries,
    required this.l10n,
    this.dense = false,
    this.onClearFilter,
    this.selectedDate,
    this.onRecordDateChange,
  });

  final List<RecordTimelineEntry> entries;
  final AppLocalizations l10n;
  final bool dense;
  final VoidCallback? onClearFilter;
  final DateTime? selectedDate;

  /// Called when the user drags a timeline card onto a calendar day.
  /// Receives the record ID and the new target date.
  /// Only invoked on desktop layouts; mobile uses tap-to-navigate.
  final void Function(String recordId, DateTime newDate)? onRecordDateChange;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return FCard(
      key: const Key('record-timeline'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.recordTimelineSectionTitle,
                  style: context.theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (selectedDate != null) ...[
                  const SizedBox(width: Spacing.level3),
                  Text(
                    DateFormat.yMd(
                      Localizations.localeOf(context).toString(),
                    ).format(selectedDate!),
                    style: context.theme.typography.body.sm.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                ],
                const Spacer(),
                if (onClearFilter != null)
                  FButton(
                    variant: FButtonVariant.ghost,
                    size: FButtonSizeVariant.xs,
                    mainAxisSize: MainAxisSize.min,
                    onPress: onClearFilter!,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.recordAllTypesAction,
                          style: TextStyle(
                            color: colors.foreground,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: Spacing.level1),
                        Icon(
                          SemanticIcons.actionExpand,
                          size: Spacing.level4,
                          color: colors.foreground,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.level4),
            if (entries.isEmpty)
              _DesktopTimelineEmptyState(
                l10n: l10n,
                onClearFilter: onClearFilter,
                onCreate: () => pushAuthRequiredRoute(
                  context,
                  Uri(
                    path: '/record/create',
                    queryParameters: {
                      'date': formatRecordDate(selectedDate ?? DateTime.now()),
                    },
                  ).toString(),
                ),
              )
            else
              Column(
                children: [
                  for (var index = 0; index < entries.length; index += 1)
                    _TimelineEntryRow(
                      index: index,
                      entry: entries[index],
                      l10n: l10n,
                      isLast: index == entries.length - 1,
                      dense: dense,
                      selectedDate: selectedDate,
                      onRecordDateChange: onRecordDateChange,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineEntryRow extends StatelessWidget {
  const _TimelineEntryRow({
    required this.index,
    required this.entry,
    required this.l10n,
    required this.isLast,
    required this.dense,
    this.selectedDate,
    this.onRecordDateChange,
  });

  final int index;
  final RecordTimelineEntry entry;
  final AppLocalizations l10n;
  final bool isLast;
  final bool dense;
  final DateTime? selectedDate;
  final void Function(String recordId, DateTime newDate)? onRecordDateChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: dense ? 44 : 56,
          child: Text(
            entry.time,
            style: context.theme.typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ),
        Expanded(
          child: TimelineTile(
            alignment: TimelineAlign.start,
            isFirst: index == 0,
            isLast: isLast,
            indicatorStyle: IndicatorStyle(
              width: 10,
              height: 10,
              indicator: TimelineDot(entry: entry, size: 10, borderWidth: 3),
              padding: const EdgeInsets.only(right: Spacing.level3),
              indicatorXY: 0.25,
            ),
            beforeLineStyle: LineStyle(
              color: SemanticColor.neutral.border(context),
              thickness: 1,
            ),
            afterLineStyle: LineStyle(
              color: SemanticColor.neutral.border(context),
              thickness: 1,
            ),
            endChild: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : Spacing.level4),
              child: TimelineCard(
                entry: entry,
                index: index,
                l10n: l10n,
                dense: dense,
                selectedDate: selectedDate,
                onRecordDateChange: onRecordDateChange,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopTimelineEmptyState extends StatelessWidget {
  const _DesktopTimelineEmptyState({
    required this.l10n,
    this.onClearFilter,
    required this.onCreate,
  });

  final AppLocalizations l10n;
  final VoidCallback? onClearFilter;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.level8),
          child: Column(
            children: [
              Icon(
                SemanticIcons.actionAdd,
                size: Spacing.level8,
                color: SemanticColor.neutral.solid(context),
              ),
              const SizedBox(height: Spacing.level4),
              Text(
                l10n.recordTimelineEmptyTitle,
                style: context.theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.level1),
              Text(
                l10n.recordTimelineEmptyDescription,
                style: context.theme.typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.level5),
              Wrap(
                spacing: Spacing.level3,
                runSpacing: Spacing.level2,
                alignment: WrapAlignment.center,
                children: [
                  FButton(
                    variant: FButtonVariant.primary,
                    size: FButtonSizeVariant.sm,
                    mainAxisSize: MainAxisSize.min,
                    onPress: onCreate,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          SemanticIcons.actionAdd,
                          size: IconSizeTokens.level2,
                        ),
                        const SizedBox(width: Spacing.level2),
                        Text(l10n.recordTimelineEmptyAction),
                      ],
                    ),
                  ),
                  if (onClearFilter != null)
                    FButton(
                      variant: FButtonVariant.ghost,
                      size: FButtonSizeVariant.sm,
                      mainAxisSize: MainAxisSize.min,
                      onPress: onClearFilter,
                      child: Text(l10n.recordTimelineClearFilter),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
