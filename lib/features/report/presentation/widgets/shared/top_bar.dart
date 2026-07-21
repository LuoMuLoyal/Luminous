import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/dialogs/range_picker_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Report 页面顶栏。
///
/// 注意：日期范围标签（subtitle）和操作按钮区（bottom）已从 Header 中拆分，
/// 放到页面内容区显示。使用 [FHeader.nested]，放在 [Column] 顶部而非
/// [ListView] 中以避免 tight width 约束崩溃（Forui 0.24.x 已知问题）。
class ReportTopBar extends StatelessWidget {
  const ReportTopBar({
    super.key,
    required this.selectedQuery,
    required this.onQueryChanged,
  });

  final ReportDashboardQuery selectedQuery;
  final ValueChanged<ReportDashboardQuery> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FHeader.nested(
      title: Text(l10n.tabReport),
      suffixes: [
        ReportPeriodPill(
          range: selectedQuery.range,
          onTap: () => _showRangePicker(context),
        ),
      ],
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

/// Report action bar with generate-AI-summary and sync buttons.
///
/// Extracted from [ReportTopBar.bottom] so it can be used independently
/// as [DesktopTabShell.bottom].
class ReportActionBar extends StatelessWidget {
  const ReportActionBar({
    super.key,
    required this.onGenerate,
    required this.onSync,
    this.isGenerating = false,
    this.isSyncing = false,
  });

  final VoidCallback onGenerate;
  final VoidCallback onSync;
  final bool isGenerating;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: FButton(
            key: const Key('report-top-generate-action'),
            onPress: isGenerating ? null : onGenerate,
            prefix: Icon(
              isGenerating ? FLucideIcons.loaderCircle : FLucideIcons.sparkles,
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
          tipBuilder: (context, controller) => Text(l10n.reportSyncAction),
          child: FButton(
            key: const Key('report-top-sync-action'),
            variant: FButtonVariant.secondary,
            onPress: isSyncing ? null : onSync,
            child: Icon(
              isSyncing ? FLucideIcons.loaderCircle : FLucideIcons.refreshCw,
              size: 16,
            ),
          ),
        ),
      ],
    );
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
