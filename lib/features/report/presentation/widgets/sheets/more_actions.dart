import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/common/sheet_drag_handle.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 回顾页右上角「更多」sheet。
///
/// 四项入口（Task 8：导出与就诊摘要迁入 More）：
/// 1. 就诊摘要（Visit summary）—— 打开诊所摘要预览弹窗，文案口径为
///    「就诊时按需使用」，不暗示医生一定查看；
/// 2. PDF —— 月度 PDF 导出（旧「月度报告」导出卡同款 API 调用）；
/// 3. 打印/下载 —— 打印 PDF 导出（旧「打印预览」导出卡同款 API 调用）；
/// 4. 历史报告 —— 打开 legacy dashboard 兼容视图（`/report/legacy`）。
///
/// 本 sheet 只负责呈现与触发回调，导出/分享的 API 行为由调用方装配的
/// `handleReportExportAction` 保持与旧 dashboard 完全一致。
Future<void> showReportMoreActionsSheet(
  BuildContext context, {
  required Future<void> Function() onVisitSummary,
  required Future<void> Function() onPdf,
  required Future<void> Function() onPrint,
  required Future<void> Function() onLegacyReport,
}) {
  final isDesktop = MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

  if (isDesktop) {
    return showFDialog<void>(
      context: context,
      builder: (dialogContext, _, __) => DialogShell(
        maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
        builder: (_) => ReportMoreActionsSheet(
          onVisitSummary: onVisitSummary,
          onPdf: onPdf,
          onPrint: onPrint,
          onLegacyReport: onLegacyReport,
        ),
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(RadiusTokens.level4),
      ),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ReportMoreActionsSheet(
          onVisitSummary: onVisitSummary,
          onPdf: onPdf,
          onPrint: onPrint,
          onLegacyReport: onLegacyReport,
        ),
      ),
    ),
  );
}

/// 四入口内容区；可直接渲染（测试）或经 [showReportMoreActionsSheet] 弹出。
class ReportMoreActionsSheet extends StatelessWidget {
  const ReportMoreActionsSheet({
    super.key,
    required this.onVisitSummary,
    required this.onPdf,
    required this.onPrint,
    required this.onLegacyReport,
  });

  final Future<void> Function() onVisitSummary;
  final Future<void> Function() onPdf;
  final Future<void> Function() onPrint;
  final Future<void> Function() onLegacyReport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.level5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (MediaQuery.sizeOf(context).width < Breakpoints.desktop)
            const Center(child: SheetDragHandle()),
          Text(
            l10n.reportMoreTitle,
            style: TypographyToken.level6
                .body(context)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Spacing.level3),
          _MoreActionTile(
            key: const Key('more-visit-summary'),
            icon: SemanticIcons.medicineKit,
            color: SemanticColor.primary,
            title: l10n.reportMoreVisitSummaryTitle,
            subtitle: l10n.reportMoreVisitSummarySubtitle,
            onTap: () => _run(context, onVisitSummary),
          ),
          const SizedBox(height: Spacing.level2),
          _MoreActionTile(
            key: const Key('more-pdf'),
            icon: SemanticIcons.recordNote,
            color: SemanticColor.info,
            title: l10n.reportMorePdfTitle,
            subtitle: l10n.reportMorePdfSubtitle,
            onTap: () => _run(context, onPdf),
          ),
          const SizedBox(height: Spacing.level2),
          _MoreActionTile(
            key: const Key('more-print'),
            icon: SemanticIcons.reportExport,
            color: SemanticColor.success,
            title: l10n.reportMorePrintTitle,
            subtitle: l10n.reportMorePrintSubtitle,
            onTap: () => _run(context, onPrint),
          ),
          const SizedBox(height: Spacing.level2),
          _MoreActionTile(
            key: const Key('more-legacy-report'),
            icon: SemanticIcons.reportHistory,
            color: SemanticColor.neutral,
            title: l10n.reportMoreLegacyTitle,
            subtitle: l10n.reportMoreLegacySubtitle,
            onTap: () => _run(context, onLegacyReport),
          ),
        ],
      ),
    );
  }

  /// 若当前在 sheet/dialog 路由内则先关闭，再触发对应流程。
  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    await Navigator.of(context).maybePop();
    await action();
  }
}

class _MoreActionTile extends StatelessWidget {
  const _MoreActionTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final SemanticColor color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FButton.raw(
      onPress: onTap,
      variant: FButtonVariant.ghost,
      style: const .delta(
        contentStyle: .delta(padding: .value(EdgeInsets.zero)),
      ),
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.level4),
          child: Row(
            children: [
              FAvatar.raw(
                size: Spacing.level8,
                child: Icon(
                  icon,
                  color: color.solid(context),
                  size: Spacing.level5,
                ),
              ),
              const SizedBox(width: Spacing.level4),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TypographyToken.level5
                          .body(context)
                          .copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.level1),
                    Text(
                      subtitle,
                      style: TypographyToken.level3
                          .body(context)
                          .copyWith(color: colors.mutedForeground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                SemanticIcons.actionNext,
                color: colors.mutedForeground,
                size: IconSizeTokens.level3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
