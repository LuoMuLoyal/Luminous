import 'package:flutter/material.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';

Future<ReportDashboardQuery?> showReportRangePickerDialog(
  BuildContext context, {
  required ReportDashboardQuery selectedQuery,
}) {
  final l10n = AppLocalizations.of(context)!;

  return showDialog<ReportDashboardQuery>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.reportRangePickerTitle),
        content: Column(
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
                final now = DateTime.now();
                final initialDateRange = selectedQuery.isCustom
                    ? DateTimeRange(
                        start: selectedQuery.startDate!,
                        end: selectedQuery.endDate!,
                      )
                    : DateTimeRange(
                        start: now.subtract(const Duration(days: 7)),
                        end: now,
                      );
                final picked = await showDateRangePicker(
                  context: dialogContext,
                  firstDate: DateTime(2020),
                  lastDate: now,
                  initialDateRange: initialDateRange,
                );
                if (picked != null && dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(
                    ReportDashboardQuery(
                      range: ReportDashboardRange.custom,
                      startDate: picked.start,
                      endDate: picked.end,
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
    return ListTile(
      title: Text(label),
      trailing: selected ? const Icon(Icons.check_rounded) : null,
      onTap: onTap,
    );
  }
}
