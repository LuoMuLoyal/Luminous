import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';

Future<ReportDashboardQuery?> showReportRangePickerDialog(
  BuildContext context, {
  required ReportDashboardQuery selectedQuery,
}) {
  final l10n = AppLocalizations.of(context)!;

  return showFDialog<ReportDashboardQuery>(
    context: context,
    builder: (dialogContext, style, animation) {
      return FDialog(
        title: Text(l10n.reportRangePickerTitle),
        actions: const [],
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RangeOptionTile(
              label: l10n.reportRangeLast7Days,
              selected: selectedQuery.range == ReportDashboardRange.last7Days,
              onTap: () => Navigator.of(dialogContext).pop(
                const ReportDashboardQuery(
                  range: ReportDashboardRange.last7Days,
                ),
              ),
            ),
            _RangeOptionTile(
              label: l10n.reportRangeLast30Days,
              selected: selectedQuery.range == ReportDashboardRange.last30Days,
              onTap: () => Navigator.of(dialogContext).pop(
                const ReportDashboardQuery(
                  range: ReportDashboardRange.last30Days,
                ),
              ),
            ),
            _RangeOptionTile(
              label: l10n.reportRangeCustom,
              selected: selectedQuery.range == ReportDashboardRange.custom,
              onTap: () async {
                final now = clock.now();
                // Normalize to date-only (midnight) to avoid forui calendar
                // debug range checks failing on time components.
                final today = DateTime(now.year, now.month, now.day);
                // Extend end to the last day of the current month so the
                // calendar grid can render all visible dates without
                // triggering forui's debugCheckInclusiveDateRange.
                final monthEnd = DateTime(today.year, today.month + 1, 0);
                final initialRange = selectedQuery.isCustom
                    ? (selectedQuery.startDate!, selectedQuery.endDate!)
                    : (today.subtract(const Duration(days: 7)), today);
                final rangeController = FDateSelectionController.range(
                  initial: initialRange,
                );
                final picked = await showFDialog<(DateTime, DateTime)?>(
                  context: dialogContext,
                  builder: (calendarContext, style, animation) =>
                      AppDialogShell(
                        maxWidth: LayoutScaleResolver.dialogMaxWidth,
                        padding: const EdgeInsets.all(Spacing.level4),
                        builder: (_) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 360,
                              child: FCalendar.grid(
                                control: FGridCalendarControl(
                                  start: DateTime(2020),
                                  end: monthEnd,
                                ),
                                selectionControl:
                                    FDateSelectionControl.managedRange(
                                      controller: rangeController,
                                    ),
                              ),
                            ),
                            const SizedBox(height: Spacing.level4),
                            FButton(
                              onPress: () => Navigator.of(
                                calendarContext,
                              ).pop(rangeController.value),
                              child: Text(
                                MaterialLocalizations.of(context).okButtonLabel,
                              ),
                            ),
                          ],
                        ),
                      ),
                );
                rangeController.dispose();
                if (picked != null && dialogContext.mounted) {
                  // Clamp end date to today to prevent future selections.
                  final clampedEnd = picked.$2.isAfter(today)
                      ? today
                      : picked.$2;
                  Navigator.of(dialogContext).pop(
                    ReportDashboardQuery(
                      range: ReportDashboardRange.custom,
                      startDate: picked.$1,
                      endDate: clampedEnd,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

class _RangeOptionTile extends StatelessWidget {
  const _RangeOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return FTappable(
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(child: Text(label, style: typography.body.md)),
            if (selected)
              Icon(FLucideIcons.check, color: colors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
