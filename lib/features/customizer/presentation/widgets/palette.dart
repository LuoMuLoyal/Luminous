import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/customizer/domain/entities/edit.dart';
import 'package:luminous/features/customizer/presentation/providers/draft.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 组件展示名。
///
/// 组件 id 是稳定身份（`summary.metrics`），但在手机侧栏里只能显示成
/// `summa…`，用户认不出它是什么。展示名因此走 ARB：新增组件时补一条
/// `componentName*` 键，缺了就退回显示 id（不会崩，但不该出现在正式构建里）。
String componentDisplayName(AppLocalizations l10n, ComponentId id) {
  return switch (id.value) {
    'auth.preview_banner' => l10n.componentNameAuthPreviewBanner,
    'daily.greeting' => l10n.componentNameDailyGreeting,
    'suggestion.primary' => l10n.componentNameSuggestionPrimary,
    'suggestion.secondary' => l10n.componentNameSuggestionSecondary,
    'summary.metrics' => l10n.componentNameSummaryMetrics,
    'health_event.active' => l10n.componentNameHealthEventActive,
    'observation.metrics' => l10n.componentNameObservationMetrics,
    'quick_action.strip' => l10n.componentNameQuickActionStrip,
    'calendar.strip' => l10n.componentNameCalendarStrip,
    'quick_entry.daily' => l10n.componentNameQuickEntryDaily,
    'filter.types' => l10n.componentNameFilterTypes,
    'timeline.daily' => l10n.componentNameTimelineDaily,
    'drug_box.inventory' => l10n.componentNameDrugBoxInventory,
    'dose.records' => l10n.componentNameDoseRecords,
    'dose.safety_engine' => l10n.componentNameDoseSafetyEngine,
    'quick_action.medicine' => l10n.componentNameQuickActionMedicine,
    'period.switch' => l10n.componentNamePeriodSwitch,
    'coverage.strip' => l10n.componentNameCoverageStrip,
    'overview.noteworthy' => l10n.componentNameOverviewNoteworthy,
    'overview.record_guide' => l10n.componentNameOverviewRecordGuide,
    'event.header' => l10n.componentNameEventHeader,
    'event.what_happened' => l10n.componentNameEventWhatHappened,
    'overview.key_changes' => l10n.componentNameOverviewKeyChanges,
    'overview.completed_actions' => l10n.componentNameOverviewCompletedActions,
    'overview.next_step' => l10n.componentNameOverviewNextStep,
    'trend.single' => l10n.componentNameTrendSingle,
    'history.review' => l10n.componentNameHistoryReview,
    'ai_summary.event' => l10n.componentNameAiSummaryEvent,
    'preview.overview' => l10n.componentNamePreviewOverview,
    'preview.no_event_note' => l10n.componentNamePreviewNoEventNote,
    'status.stale_banner' => l10n.componentNameStatusStaleBanner,
    'sync.banner' => l10n.componentNameSyncBanner,
    'account.hero' => l10n.componentNameAccountHero,
    'profile.alerts' => l10n.componentNameProfileAlerts,
    'archive.summary' => l10n.componentNameArchiveSummary,
    'privacy.notice' => l10n.componentNamePrivacyNotice,
    'reminder.settings' => l10n.componentNameReminderSettings,
    'account.security' => l10n.componentNameAccountSecurity,
    'readiness.legacy' => l10n.componentNameReadinessLegacy,
    'findings.legacy' => l10n.componentNameFindingsLegacy,
    'ai_summary.legacy' => l10n.componentNameAiSummaryLegacy,
    'patterns.legacy' => l10n.componentNamePatternsLegacy,
    'history.suggestion_legacy' => l10n.componentNameSuggestionHistoryLegacy,
    _ => id.value,
  };
}
/// 组件面板：**所有** tab 里可用的组件，按来源 tab 分组。
///
/// 组件可以挂到别的 tab 上，所以这里列的不是「当前 tab 的列表」，而是
/// 全局目录减去已经挂在当前 tab 上的那些。分组让用户在跨 tab 取用组件时
/// 知道自己拿的是哪一页的东西。
class CustomizerPalette extends ConsumerWidget {
  const CustomizerPalette({
    super.key,
    required this.current,
    required this.catalog,
  });

  final SurfaceId current;
  final SurfaceCatalog catalog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(editSessionProvider.notifier);

    // **必须 watch 草稿本身**，不能接收调用方传来的快照。
    //
    // 窄屏面板长在 `showModalBottomSheet` 里，那个 builder 不在页面的重建范围
    // 内：把打开时的 `draft` 传进来，加的组件进了草稿、面板却还按旧快照渲染，
    // 表现为"点了没反应"（其实已经加上了，只是列表没变）。
    final draft = ref.watch(editSessionProvider);
    if (draft == null) return const SizedBox.shrink();

    // 已挂在当前 surface 上的（含隐藏的）不再列出：它们已经在左侧列表里。
    final placements = draft.layoutOf(current).placements;
    final mountedCount = placements.length;
    final mounted = placements.map((placement) => placement.id).toSet();

    // 每个 surface 可挂、当前还没挂上的组件——这就是跨 tab 的候选集。
    final groups = <SurfaceId, List<ComponentId>>{};
    for (final definition in catalog.definitions) {
      if (definition.surface == SurfaceId.tabChrome) continue;
      final ids = [
        for (final id in definition.owned)
          if (!mounted.contains(id)) id,
      ];
      if (ids.isNotEmpty) groups[definition.surface] = ids;
    }

    if (groups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Text(
          l10n.customizerAllAdded,
          style: context.theme.typography.body.sm.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.lg),
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: Spacing.md, bottom: Spacing.sm),
            child: Text(
              surfaceTitle(l10n, entry.key),
              style: context.theme.typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          for (final id in entry.value)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xs),
              // 点击必须包在**外层**：`LongPressDraggable` 会把长按识别器注册
              // 到自己的手势竞技场，内层 `GestureDetector` 的 tap 会被它抢走
              // （表现为"点加号没反应"）。把 `onTap` 放在拖拽外面，单击与长按
              // 各走各的识别器；面板是滚动列表，长按才拖也避免和滚动冲突。
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _add(notifier, id, mountedCount),
                child: LongPressDraggable<ComponentId>(
                  data: id,
                  feedback: _PaletteDragFeedback(
                    label: componentDisplayName(l10n, id),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: _PaletteTile(label: componentDisplayName(l10n, id)),
                  ),
                  child: _PaletteTile(label: componentDisplayName(l10n, id)),
                ),
              ),
            ),
        ],
      ],
    );
  }

  void _add(EditSessionNotifier notifier, ComponentId id, int currentCount) {
    notifier.applyEdit(
      LayoutEdit.add(
        surface: current,
        id: id,
        toIndex: currentCount,
      ),
    );
  }
}

/// Tab / surface 的展示名，复用 tab 的 ARB 名称。
String surfaceTitle(AppLocalizations l10n, SurfaceId surface) {
  return switch (surface) {
    SurfaceId.today => l10n.tabToday,
    SurfaceId.record => l10n.tabRecord,
    SurfaceId.medicine => l10n.tabMedicine,
    SurfaceId.review => l10n.tabReview,
    SurfaceId.mine => l10n.tabMine,
    SurfaceId.tabChrome => l10n.customizerTitle,
  };
}

/// 面板里的一行：组件名。
///
/// 纯展示：点击由外层 `GestureDetector` 处理，这样手势归属只有一处，
/// 不会和内部识别器抢。
class _PaletteTile extends StatelessWidget {
  const _PaletteTile({required this.label});

  final String label;

  /// 行高。默认内边距在手机上只有 ~40dp，抬到接近 Material 的 48dp 触控目标。
  static const double _rowHeight = 52;

  @override
  Widget build(BuildContext context) {
    return FCard(
      child: SizedBox(
        height: _rowHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Row(
            children: [
              // 只保留一个「＋」：它既是操作提示也是点击目标，右侧那个是多余的。
              Icon(
                SemanticIcons.actionAdd,
                size: IconSizeTokens.md,
                color: SemanticColor.neutral.solid(context),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.typography.body.md,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaletteDragFeedback extends StatelessWidget {
  const _PaletteDragFeedback({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 180,
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Text(label, style: context.theme.typography.body.sm),
          ),
        ),
      ),
    );
  }
}
