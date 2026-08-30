import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/common/sheet_drag_handle.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 回顾页右上角「更多」sheet。
///
/// 五项入口（Task 8：导出与就诊摘要迁入 More；Task 8 字段级隐私：分享管理）：
/// 1. 就诊摘要（Visit summary）—— 打开诊所摘要预览弹窗，文案口径为
///    「就诊时按需使用」，不暗示医生一定查看；
/// 2. 分享管理（Share management）—— 查看与撤销分享链接；
/// 3. PDF —— 月度 PDF 导出（旧「月度报告」导出卡同款 API 调用）；
/// 4. 打印/下载 —— 打印 PDF 导出（旧「打印预览」导出卡同款 API 调用）；
/// 5. 历史报告 —— 打开 legacy dashboard 兼容视图（`/review/legacy`）。
///
/// 本 sheet 只负责呈现与触发回调，导出/分享的 API 行为由调用方装配的
/// `handleReviewExportAction` 保持与旧 dashboard 完全一致。
Future<void> showReviewMoreActionsSheet(
  BuildContext context, {
  required Future<void> Function() onVisitSummary,
  required Future<void> Function() onShareManagement,
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
        builder: (_) => ReviewMoreActionsSheet(
          onVisitSummary: onVisitSummary,
          onShareManagement: onShareManagement,
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
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: context.theme.style.borderRadius.md.topLeft,
      ),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ReviewMoreActionsSheet(
          onVisitSummary: onVisitSummary,
          onShareManagement: onShareManagement,
          onPdf: onPdf,
          onPrint: onPrint,
          onLegacyReport: onLegacyReport,
        ),
      ),
    ),
  );
}

/// 五入口内容区；可直接渲染（测试）或经 [showReviewMoreActionsSheet] 弹出。
class ReviewMoreActionsSheet extends StatelessWidget {
  const ReviewMoreActionsSheet({
    super.key,
    required this.onVisitSummary,
    required this.onShareManagement,
    required this.onPdf,
    required this.onPrint,
    required this.onLegacyReport,
  });

  final Future<void> Function() onVisitSummary;
  final Future<void> Function() onShareManagement;
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
            l10n.reviewMoreTitle,
            style: context.theme.typography.body.lg.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Spacing.level3),
          _MoreActionTile(
            key: const Key('more-visit-summary'),
            icon: SemanticIcons.medicineKit,
            color: SemanticColor.primary,
            title: l10n.reviewMoreVisitSummaryTitle,
            subtitle: l10n.reviewMoreVisitSummarySubtitle,
            onTap: () => _run(context, onVisitSummary),
          ),
          const SizedBox(height: Spacing.level2),
          _MoreActionTile(
            key: const Key('more-share-management'),
            icon: SemanticIcons.actionShare,
            color: SemanticColor.warning,
            title: l10n.reviewMoreShareManagementTitle,
            subtitle: l10n.reviewMoreShareManagementSubtitle,
            onTap: () => _run(context, onShareManagement),
          ),
          const SizedBox(height: Spacing.level2),
          _MoreActionTile(
            key: const Key('more-pdf'),
            icon: SemanticIcons.recordNote,
            color: SemanticColor.info,
            title: l10n.reviewMorePdfTitle,
            subtitle: l10n.reviewMorePdfSubtitle,
            onTap: () => _run(context, onPdf),
          ),
          const SizedBox(height: Spacing.level2),
          _MoreActionTile(
            key: const Key('more-print'),
            icon: SemanticIcons.reportExport,
            color: SemanticColor.success,
            title: l10n.reviewMorePrintTitle,
            subtitle: l10n.reviewMorePrintSubtitle,
            onTap: () => _run(context, onPrint),
          ),
          const SizedBox(height: Spacing.level2),
          _MoreActionTile(
            key: const Key('more-legacy-report'),
            icon: SemanticIcons.reportHistory,
            color: SemanticColor.neutral,
            title: l10n.reviewMoreLegacyTitle,
            subtitle: l10n.reviewMoreLegacySubtitle,
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
    final typography = context.theme.typography;
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
                size: IconSizeTokens.level6,
                child: Icon(
                  icon,
                  color: color.solid(context),
                  size: IconSizeTokens.level3,
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
                      style: typography.body.md.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.level1),
                    Text(
                      subtitle,
                      style: typography.body.xs.copyWith(
                        color: SemanticColor.neutral.solid(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                SemanticIcons.actionNext,
                color: SemanticColor.neutral.solid(context),
                size: IconSizeTokens.level3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
