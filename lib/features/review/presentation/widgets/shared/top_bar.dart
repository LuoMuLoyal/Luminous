// ═══════════════════════════════════════════════════════════════════════════
// LEGACY — 兼容期保留，已不再装配到主路径。
//
// 旧 dashboard 的顶栏与 7/30 天范围切换（ReviewTopBar / ReviewRangeMenu /
// ReviewPeriodPill）。Task 6 起 `/review` 主路径改用 page.dart 内部的
// `_ReviewTopBar`（仅标题，无范围切换），本文件仅被 legacy widgets
// `dashboard_view.dart` 与 `sections/trend.dart` 消费，不属于 Review
// 主路径。Task 8 把导出迁入 More 后评估删除。
// ═══════════════════════════════════════════════════════════════════════════
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/dialogs/range_picker_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// A popover-based range selector for the report page.
///
/// Replaces the previous bottom-sheet/dialog approach with a Forui
/// [FPopoverMenu] anchored to the top-right of the trigger pill.
/// Preset ranges (近7天 / 近30天) switch immediately; the "custom" option
/// closes the popover and opens the calendar picker.

/// Report page top bar.
///
/// Note: the date range label (subtitle) and action button area (bottom) have been
/// extracted from the Header and moved to the page content area. Uses [FHeader.nested],
/// placed at the top of a [Column] rather than inside a [ListView] to avoid tight
/// width constraint crash (Forui 0.24.x known issue).
class ReviewTopBar extends StatelessWidget {
  const ReviewTopBar({
    super.key,
    required this.selectedQuery,
    required this.onQueryChanged,
  });

  final ReviewDashboardQuery selectedQuery;
  final ValueChanged<ReviewDashboardQuery> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FHeader.nested(
      title: Text(l10n.tabReview),
      suffixes: [
        ReviewRangeMenu(
          selectedQuery: selectedQuery,
          onQueryChanged: onQueryChanged,
        ),
      ],
    );
  }
}

/// Forui [FPopoverMenu]-based range selector.
///
/// The trigger is a compact pill showing the current range label.
/// Tapping it opens a popover anchored to the bottom-right of the pill,
/// listing the three range options. The currently selected option is
/// marked with a check icon via [FItem.selected].
class ReviewRangeMenu extends StatelessWidget {
  const ReviewRangeMenu({
    super.key,
    required this.selectedQuery,
    required this.onQueryChanged,
  });

  final ReviewDashboardQuery selectedQuery;
  final ValueChanged<ReviewDashboardQuery> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FPopoverMenu(
      menuAnchor: Alignment.topRight,
      childAnchor: Alignment.bottomRight,
      menuBuilder: (context, controller, _) => [
        FItemGroupMixin.group(
          children: [
            FItemMixin.item(
              title: Text(l10n.reviewRangeLast7Days),
              selected: selectedQuery.range == ReviewDashboardRange.last7Days,
              onPress: () {
                unawaited(controller.hide());
                onQueryChanged(
                  const ReviewDashboardQuery(
                    range: ReviewDashboardRange.last7Days,
                  ),
                );
              },
            ),
            FItemMixin.item(
              title: Text(l10n.reviewRangeLast30Days),
              selected: selectedQuery.range == ReviewDashboardRange.last30Days,
              onPress: () {
                unawaited(controller.hide());
                onQueryChanged(
                  const ReviewDashboardQuery(
                    range: ReviewDashboardRange.last30Days,
                  ),
                );
              },
            ),
            FItemMixin.item(
              title: Text(l10n.reviewRangeCustom),
              selected: selectedQuery.range == ReviewDashboardRange.custom,
              onPress: () async {
                await controller.hide();
                if (!context.mounted) return;
                final picked = await showReviewCalendarPicker(
                  context,
                  selectedQuery: selectedQuery,
                );
                if (picked != null && picked != selectedQuery) {
                  onQueryChanged(picked);
                }
              },
            ),
          ],
        ),
      ],
      builder: (_, controller, _) => ReviewPeriodPill(
        range: selectedQuery.range,
        onTap: controller.toggle,
      ),
    );
  }
}

/// Report action bar with generate-AI-summary and sync buttons.
///
/// Extracted from [ReviewTopBar.bottom] so it can be used independently
/// as [DesktopTabShell.bottom].
class ReviewActionBar extends StatelessWidget {
  const ReviewActionBar({
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
              isGenerating ? SemanticIcons.aiAnalyzing : SemanticIcons.aiEntry,
              size: 16,
            ),
            child: Text(
              l10n.reviewGenerateAction,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: Spacing.level3),
        FTooltip(
          tipBuilder: (context, controller) => Text(l10n.reviewSyncAction),
          child: FButton(
            key: const Key('report-top-sync-action'),
            variant: FButtonVariant.secondary,
            onPress: isSyncing ? null : onSync,
            child: Icon(
              isSyncing
                  ? SemanticIcons.aiAnalyzing
                  : SemanticIcons.actionRefresh,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class ReviewPeriodPill extends StatelessWidget {
  const ReviewPeriodPill({super.key, required this.range, required this.onTap});

  final ReviewDashboardRange range;
  final VoidCallback onTap;

  String _label(AppLocalizations l10n) => switch (range) {
    ReviewDashboardRange.last7Days => l10n.reviewRangeLast7Days,
    ReviewDashboardRange.last30Days => l10n.reviewRangeLast30Days,
    ReviewDashboardRange.custom => l10n.reviewRangeCustom,
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
            SemanticIcons.actionExpand,
            size: 16,
            color: colors.mutedForeground,
          ),
        ],
      ),
    );
  }
}
