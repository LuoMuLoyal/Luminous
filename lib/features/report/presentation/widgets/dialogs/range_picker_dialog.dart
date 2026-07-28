import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Shows the calendar date-range picker.
///
/// On mobile this opens as a bottom sheet; on desktop as a centered dialog.
/// Used by [ReportRangeMenu] when the user selects the "custom" option.
Future<ReportDashboardQuery?> showReportCalendarPicker(
  BuildContext context, {
  required ReportDashboardQuery selectedQuery,
}) {
  final isDesktop = MediaQuery.sizeOf(context).width >= Breakpoints.desktop;
  final l10n = AppLocalizations.of(context)!;
  return isDesktop
      ? _showCalendarDialog(context, l10n, selectedQuery)
      : _showCalendarBottomSheet(context, l10n, selectedQuery);
}

Future<ReportDashboardQuery?> showReportRangePickerDialog(
  BuildContext context, {
  required ReportDashboardQuery selectedQuery,
}) {
  final l10n = AppLocalizations.of(context)!;
  final isDesktop = MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

  // On mobile use a bottom sheet to avoid dialog-in-dialog; on desktop keep
  // the centered FDialog.
  if (!isDesktop) {
    return _showMobileRangePicker(context, l10n, selectedQuery);
  }

  return showAppDialog<ReportDashboardQuery>(
    context: context,
    scrollable: false,
    builder: (dialogContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportRangePickerTitle,
          style: dialogContext.theme.dialogStyle.titleTextStyle,
        ),
        const SizedBox(height: Spacing.level4),
        Column(
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
                final picked = await _showCalendarDialog(
                  dialogContext,
                  l10n,
                  selectedQuery,
                );
                if (picked != null && dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(picked);
                }
              },
            ),
          ],
        ),
      ],
    ),
  );
}

Future<ReportDashboardQuery?> _showMobileRangePicker(
  BuildContext context,
  AppLocalizations l10n,
  ReportDashboardQuery selectedQuery,
) async {
  return showModalBottomSheet<ReportDashboardQuery>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(RadiusTokens.level4),
      ),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.level4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.reportRangePickerTitle,
                      style: TypographyToken.level5
                          .body(context)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      SemanticIcons.actionClose,
                      size: IconSizeTokens.level3,
                    ),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _RangeOptionTile(
              label: l10n.reportRangeLast7Days,
              selected: selectedQuery.range == ReportDashboardRange.last7Days,
              onTap: () => Navigator.of(sheetContext).pop(
                const ReportDashboardQuery(
                  range: ReportDashboardRange.last7Days,
                ),
              ),
            ),
            _RangeOptionTile(
              label: l10n.reportRangeLast30Days,
              selected: selectedQuery.range == ReportDashboardRange.last30Days,
              onTap: () => Navigator.of(sheetContext).pop(
                const ReportDashboardQuery(
                  range: ReportDashboardRange.last30Days,
                ),
              ),
            ),
            _RangeOptionTile(
              label: l10n.reportRangeCustom,
              selected: selectedQuery.range == ReportDashboardRange.custom,
              onTap: () async {
                final picked = await _showCalendarBottomSheet(
                  sheetContext,
                  l10n,
                  selectedQuery,
                );
                if (picked != null && sheetContext.mounted) {
                  Navigator.of(sheetContext).pop(picked);
                }
              },
            ),
            const SizedBox(height: Spacing.level4),
          ],
        ),
      );
    },
  );
}

/// Calendar picker shown as a bottom sheet on mobile (avoids dialog-in-dialog).
Future<ReportDashboardQuery?> _showCalendarBottomSheet(
  BuildContext context,
  AppLocalizations l10n,
  ReportDashboardQuery selectedQuery,
) async {
  final now = clock.now();
  final today = DateTime(now.year, now.month, now.day);
  final monthEnd = DateTime(today.year, today.month + 1, 0);
  final initialRange = selectedQuery.isCustom
      ? (selectedQuery.startDate!, selectedQuery.endDate!)
      : (today.subtract(const Duration(days: 7)), today);
  final rangeController = FDateSelectionController.range(initial: initialRange);

  final picked = await showModalBottomSheet<(DateTime, DateTime)?>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(RadiusTokens.level4),
      ),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.level4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 360,
                child: FCalendar.grid(
                  control: FGridCalendarControl(
                    start: DateTime(2020),
                    end: monthEnd,
                  ),
                  selectionControl: FDateSelectionControl.managedRange(
                    controller: rangeController,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.level4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FButton(
                    variant: FButtonVariant.ghost,
                    onPress: () => Navigator.of(sheetContext).pop(null),
                    child: Text(l10n.commonCancel),
                  ),
                  const SizedBox(width: Spacing.level3),
                  FButton(
                    onPress: () =>
                        Navigator.of(sheetContext).pop(rangeController.value),
                    child: Text(l10n.commonConfirm),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  rangeController.dispose();

  if (picked == null) return null;
  final clampedEnd = picked.$2.isAfter(today) ? today : picked.$2;
  return ReportDashboardQuery(
    range: ReportDashboardRange.custom,
    startDate: picked.$1,
    endDate: clampedEnd,
  );
}

/// Calendar picker shown as a dialog on desktop.
Future<ReportDashboardQuery?> _showCalendarDialog(
  BuildContext context,
  AppLocalizations l10n,
  ReportDashboardQuery selectedQuery,
) async {
  final now = clock.now();
  final today = DateTime(now.year, now.month, now.day);
  final monthEnd = DateTime(today.year, today.month + 1, 0);
  final initialRange = selectedQuery.isCustom
      ? (selectedQuery.startDate!, selectedQuery.endDate!)
      : (today.subtract(const Duration(days: 7)), today);
  final rangeController = FDateSelectionController.range(initial: initialRange);

  final picked = await showFDialog<(DateTime, DateTime)?>(
    context: context,
    builder: (calendarContext, style, animation) => DialogShell(
      maxWidth: LayoutScaleResolver.dialogMaxWidthFor(
        MediaQuery.sizeOf(context).width,
      ),
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
              selectionControl: FDateSelectionControl.managedRange(
                controller: rangeController,
              ),
            ),
          ),
          const SizedBox(height: Spacing.level4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FButton(
                variant: FButtonVariant.ghost,
                onPress: () => Navigator.of(calendarContext).pop(null),
                child: Text(l10n.commonCancel),
              ),
              const SizedBox(width: Spacing.level3),
              FButton(
                onPress: () =>
                    Navigator.of(calendarContext).pop(rangeController.value),
                child: Text(l10n.commonConfirm),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  rangeController.dispose();

  if (picked == null) return null;
  final clampedEnd = picked.$2.isAfter(today) ? today : picked.$2;
  return ReportDashboardQuery(
    range: ReportDashboardRange.custom,
    startDate: picked.$1,
    endDate: clampedEnd,
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
              Icon(
                SemanticIcons.statusDone,
                color: colors.primary,
                size: IconSizeTokens.level3,
              ),
          ],
        ),
      ),
    );
  }
}
