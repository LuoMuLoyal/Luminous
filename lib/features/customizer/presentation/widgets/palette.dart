import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/customizer/domain/entities/draft.dart';
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
    required this.draft,
  });

  final SurfaceId current;
  final SurfaceCatalog catalog;
  final LayoutDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(editSessionProvider.notifier);

    // 已挂在当前 surface 上的（含隐藏的）不再列出：它们已经在左侧列表里。
    final mounted = draft
        .layoutOf(current)
        .placements
        .map((placement) => placement.id)
        .toSet();

    // 每个 surface 可挂、当前还没挂上的组件——这就是跨 tab 的候选集。
    final groups = <SurfaceId, List<ComponentId>>{};
    for (final definition in catalog.definitions) {
      if (definition.surface == SurfaceId.tabChrome) continue;
      final ids = [
        for (final id in definition.available)
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
              child: Draggable<ComponentId>(
                data: id,
                feedback: _PaletteDragFeedback(
                  label: componentDisplayName(l10n, id),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.4,
                  child: _PaletteTile(
                    label: componentDisplayName(l10n, id),
                    onTap: () => _add(notifier, id),
                  ),
                ),
                child: _PaletteTile(
                  label: componentDisplayName(l10n, id),
                  onTap: () => _add(notifier, id),
                ),
              ),
            ),
        ],
      ],
    );
  }

  void _add(EditSessionNotifier notifier, ComponentId id) {
    notifier.applyEdit(
      LayoutEdit.add(
        surface: current,
        id: id,
        toIndex: draft.layoutOf(current).placements.length,
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

class _PaletteTile extends StatelessWidget {
  const _PaletteTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                SemanticIcons.actionAddCard,
                size: IconSizeTokens.sm,
                color: SemanticColor.neutral.solid(context),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.typography.body.sm,
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
