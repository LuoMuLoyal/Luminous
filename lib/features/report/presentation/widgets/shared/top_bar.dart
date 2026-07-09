import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/top_bar.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/dialogs/range_picker_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportTopBar extends StatelessWidget {
  const ReportTopBar({
    super.key,
    required this.dateRangeLabel,
    required this.selectedQuery,
    required this.onQueryChanged,
    required this.onGenerate,
    required this.onSync,
    this.isGenerating = false,
    this.isSyncing = false,
    this.showActionBar = true,
  });

  final String dateRangeLabel;
  final ReportDashboardQuery selectedQuery;
  final ValueChanged<ReportDashboardQuery> onQueryChanged;
  final VoidCallback onGenerate;
  final VoidCallback onSync;
  final bool isGenerating;
  final bool isSyncing;
  final bool showActionBar;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTopBar(
      title: l10n.tabReport,
      subtitle: Text(dateRangeLabel),
      trailing: [
        ReportPeriodPill(
          range: selectedQuery.range,
          onTap: () => _showRangePicker(context),
        ),
      ],
      bottom: showActionBar
          ? Row(
              children: [
                Expanded(
                  child: FButton(
                    key: const Key('report-top-generate-action'),
                    onPress: isGenerating ? null : onGenerate,
                    prefix: Icon(
                      isGenerating
                          ? FLucideIcons.loaderCircle
                          : FLucideIcons.sparkles,
                      size: 16,
                    ),
                    child: Text(
                      l10n.reportGenerateAction,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.level3),
                FTooltip(
                  tipBuilder: (context, controller) =>
                      Text(l10n.reportSyncAction),
                  child: FButton(
                    key: const Key('report-top-sync-action'),
                    variant: FButtonVariant.secondary,
                    onPress: isSyncing ? null : onSync,
                    child: Icon(
                      isSyncing
                          ? FLucideIcons.loaderCircle
                          : FLucideIcons.refreshCw,
                      size: 16,
                    ),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Future<void> _showRangePicker(BuildContext context) async {
    final selected = await showReportRangePickerDialog(
      context,
      selectedQuery: selectedQuery,
    );
    if (selected != null && selected != selectedQuery) {
      onQueryChanged(selected);
    }
  }
}

class ReportPeriodPill extends StatelessWidget {
  const ReportPeriodPill({super.key, required this.range, required this.onTap});

  final ReportDashboardRange range;
  final VoidCallback onTap;

  String _label(AppLocalizations l10n) => switch (range) {
    ReportDashboardRange.last7Days => l10n.reportRangeLast7Days,
    ReportDashboardRange.last30Days => l10n.reportRangeLast30Days,
    ReportDashboardRange.custom => l10n.reportRangeCustom,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return FButton(
      onPress: onTap,
      variant: FButtonVariant.outline,
      mainAxisSize: MainAxisSize.min,
      style: const .delta(
        contentStyle: .delta(
          padding: .value(
            EdgeInsets.symmetric(
              horizontal: Spacing.level4,
              vertical: Spacing.level3,
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _label(l10n),
            style: TypographyToken.level4
                .body(context)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: Spacing.level1),
          Icon(
            FLucideIcons.chevronDown,
            size: 16,
            color: colors.mutedForeground,
          ),
        ],
      ),
    );
  }
}
