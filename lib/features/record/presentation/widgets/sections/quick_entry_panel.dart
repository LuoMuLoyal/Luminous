import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/widgets/common/icon_action_button.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/record/presentation/widgets/shared/dashboard_tokens.dart';
import 'package:luminous/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Quick record panel
// ---------------------------------------------------------------------------

class RecordQuickEntryPanel extends ConsumerStatefulWidget {
  const RecordQuickEntryPanel({
    super.key,
    required this.actions,
    required this.l10n,
    this.onQuickAction,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final ValueChanged<RecordQuickAction>? onQuickAction;

  @override
  ConsumerState<RecordQuickEntryPanel> createState() =>
      _RecordQuickEntryPanelState();
}

class _RecordQuickEntryPanelState extends ConsumerState<RecordQuickEntryPanel> {
  bool _reorderMode = false;
  List<RecordQuickAction> _reorderActions = const [];

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final prefs =
        ref.watch(quickEntryPreferencesProvider).asData?.value ??
        const QuickEntryPreferences();
    final metrics = _QuickRecordMetrics.resolve(context);

    // When not in reorder mode, sort actions according to preferences.
    final allActions = _reorderMode
        ? _reorderActions
        : _applyPreferences(widget.actions, prefs);

    final noteAction = allActions
        .where((action) => action.type == RecordEntryType.note)
        .firstOrNull;
    final gridActions = allActions
        .where((action) => action.type != RecordEntryType.note)
        .take(6)
        .toList(growable: false);

    return Column(
      key: const Key('record-quick-actions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PanelHeader(
          l10n: l10n,
          prefs: prefs,
          reorderMode: _reorderMode,
          onToggleDynamicSort: (value) {
            ref
                .read(quickEntryPreferencesProvider.notifier)
                .setDynamicSortEnabled(value);
          },
          onEditTap: () {
            if (prefs.dynamicSortEnabled) {
              Toast.show(context, l10n.recordQuickSortDisableDynamicFirst);
              return;
            }
            setState(() {
              _reorderMode = true;
              _reorderActions = List.from(gridActions);
            });
          },
          onReorderDone: () {
            final order = _reorderActions
                .where((a) => a.type != RecordEntryType.note)
                .map((a) => a.type.name)
                .toList();
            ref
                .read(quickEntryPreferencesProvider.notifier)
                .setCustomOrder(order);
            setState(() {
              _reorderMode = false;
              _reorderActions = const [];
            });
          },
          onReorderCancel: () {
            setState(() {
              _reorderMode = false;
              _reorderActions = const [];
            });
          },
        ),
        SizedBox(height: metrics.sectionGap),
        if (!prefs.collapsed || _reorderMode)
          FCard(
            child: Column(
              children: [
                if (_reorderMode)
                  _ReorderableGrid(
                    actions: _reorderActions,
                    l10n: l10n,
                    metrics: metrics,
                    onReordered: (reordered) {
                      setState(() => _reorderActions = reordered);
                    },
                  )
                else ...[
                  _QuickRecordGrid(
                    actions: gridActions,
                    l10n: l10n,
                    metrics: metrics,
                    onTap: widget.onQuickAction,
                  ),
                  if (noteAction != null) ...[
                    const AppDivider(),
                    _QuickRecordNoteButton(
                      action: noteAction,
                      l10n: l10n,
                      metrics: metrics,
                      onTap: widget.onQuickAction,
                    ),
                  ],
                ],
              ],
            ),
          ),
      ],
    );
  }

  List<RecordQuickAction> _applyPreferences(
    List<RecordQuickAction> actions,
    QuickEntryPreferences prefs,
  ) {
    return buildMobileQuickActions(actions, preferences: prefs);
  }
}

// ---------------------------------------------------------------------------
// Panel header — title + dynamic sort switch + edit button
// ---------------------------------------------------------------------------

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.l10n,
    required this.prefs,
    required this.reorderMode,
    required this.onToggleDynamicSort,
    required this.onEditTap,
    required this.onReorderDone,
    required this.onReorderCancel,
  });

  final AppLocalizations l10n;
  final QuickEntryPreferences prefs;
  final bool reorderMode;
  final ValueChanged<bool> onToggleDynamicSort;
  final VoidCallback onEditTap;
  final VoidCallback onReorderDone;
  final VoidCallback onReorderCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    if (reorderMode) {
      return Row(
        children: [
          Expanded(
            child: Text(
              l10n.recordQuickReorderTitle,
              style: TypographyToken.level6
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          FButton(
            key: const Key('record-quick-reorder-cancel'),
            variant: FButtonVariant.ghost,
            onPress: onReorderCancel,
            child: Text(l10n.recordQuickReorderCancel),
          ),
          const SizedBox(width: Spacing.level2),
          FButton(
            key: const Key('record-quick-reorder-done'),
            onPress: onReorderDone,
            child: Text(l10n.recordQuickReorderDone),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.recordQuickSectionTitle,
            style: TypographyToken.level7
                .display(context)
                .copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        // Dynamic sort label + switch
        Text(
          l10n.recordQuickDynamicSortLabel,
          style: TypographyToken.level3
              .body(context)
              .copyWith(color: colors.mutedForeground),
        ),
        const SizedBox(width: Spacing.level1),
        // Info tooltip for dynamic sort
        FTooltip(
          tipBuilder: (context, controller) =>
              Text(l10n.recordQuickDynamicSortTooltip),
          child: Icon(
            SemanticIcons.actionHelp,
            size: 16,
            color: colors.mutedForeground,
          ),
        ),
        const SizedBox(width: Spacing.level2),
        // Dynamic sort switch
        FSwitch(
          key: const Key('record-quick-dynamic-sort'),
          value: prefs.dynamicSortEnabled,
          onChange: onToggleDynamicSort,
        ),
        const SizedBox(width: Spacing.level3),
        // Edit button — properly disabled when dynamic sort is on
        IconActionButton(
          tooltip: prefs.dynamicSortEnabled
              ? l10n.recordQuickSortDisableDynamicFirst
              : l10n.recordQuickEditOrder,
          icon: SemanticIcons.actionEdit,
          onTap: prefs.dynamicSortEnabled ? null : onEditTap,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reorderable grid for custom ordering
// ---------------------------------------------------------------------------

class _ReorderableGrid extends StatelessWidget {
  const _ReorderableGrid({
    required this.actions,
    required this.l10n,
    required this.metrics,
    required this.onReordered,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final _QuickRecordMetrics metrics;
  final ValueChanged<List<RecordQuickAction>> onReordered;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.level4,
            vertical: Spacing.level2,
          ),
          child: Row(
            children: [
              Icon(
                SemanticIcons.actionMore,
                size: 14,
                color: colors.mutedForeground,
              ),
              const SizedBox(width: Spacing.level2),
              Text(
                l10n.recordQuickReorderHint,
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
              ),
            ],
          ),
        ),
        ReorderableListView(
          key: const Key('record-quick-reorder-list'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: (oldIndex, newIndex) {
            final items = List<RecordQuickAction>.from(actions);
            final item = items.removeAt(oldIndex);
            items.insert(newIndex, item);
            onReordered(items);
          },
          children: [
            for (var index = 0; index < actions.length; index++)
              ReorderableDragStartListener(
                key: ValueKey('reorder-${actions[index].type.name}'),
                index: index,
                child: _ReorderableTile(
                  action: actions[index],
                  l10n: l10n,
                  metrics: metrics,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ReorderableTile extends StatelessWidget {
  const _ReorderableTile({
    required this.action,
    required this.l10n,
    required this.metrics,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final _QuickRecordMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final label = recordCopy(l10n, action.titleKey);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.level4,
        vertical: metrics.tileVerticalPadding,
      ),
      child: Row(
        children: [
          Icon(
            SemanticIcons.actionMore,
            size: 20,
            color: colors.mutedForeground,
          ),
          const SizedBox(width: Spacing.level4),
          FAvatar.raw(
            size: metrics.avatarSize,
            style: .delta(backgroundColor: action.softColor.subtle(context)),
            child: Icon(
              action.icon,
              color: action.accent.solid(context),
              size: Spacing.level5,
            ),
          ),
          const SizedBox(width: Spacing.level4),
          Text(
            label,
            style: TypographyToken.level5
                .body(context)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Metrics
// ---------------------------------------------------------------------------

class _QuickRecordMetrics {
  const _QuickRecordMetrics({
    required this.sectionGap,
    required this.tileVerticalPadding,
    required this.avatarSize,
    required this.notePadding,
    required this.dividerHeight,
  });

  factory _QuickRecordMetrics.resolve(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final shortEdge = math.min(size.width, size.height);
    final scale = ((shortEdge - 600) / 280).clamp(0.0, 1.0);
    return _QuickRecordMetrics(
      sectionGap: _lerpDouble(Spacing.level2, Spacing.level3, scale),
      tileVerticalPadding: _lerpDouble(Spacing.level2, Spacing.level4, scale),
      avatarSize: _lerpDouble(Spacing.level6, Spacing.level7, scale),
      notePadding: _lerpDouble(Spacing.level2, Spacing.level4, scale),
      dividerHeight: _lerpDouble(Spacing.level6, Spacing.level8, scale),
    );
  }

  final double sectionGap;
  final double tileVerticalPadding;
  final double avatarSize;
  final double notePadding;
  final double dividerHeight;
}

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

// ---------------------------------------------------------------------------
// Quick record grid (non-reorder mode)
// ---------------------------------------------------------------------------

class _QuickRecordGrid extends StatelessWidget {
  const _QuickRecordGrid({
    required this.actions,
    required this.l10n,
    required this.metrics,
    this.onTap,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final _QuickRecordMetrics metrics;
  final ValueChanged<RecordQuickAction>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final rows = <List<RecordQuickAction>>[];
    for (var index = 0; index < actions.length; index += 3) {
      rows.add(actions.skip(index).take(3).toList(growable: false));
    }

    return Column(
      children: [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex += 1) ...[
          Row(
            children: [
              for (
                var index = 0;
                index < rows[rowIndex].length;
                index += 1
              ) ...[
                Expanded(
                  child: _QuickRecordTile(
                    action: rows[rowIndex][index],
                    l10n: l10n,
                    metrics: metrics,
                    onTap: onTap,
                  ),
                ),
                if (index < rows[rowIndex].length - 1)
                  SizedBox(
                    height: metrics.dividerHeight,
                    child: AppDivider(
                      axis: Axis.vertical,
                      color: colors.border,
                    ),
                  ),
              ],
              for (var filler = rows[rowIndex].length; filler < 3; filler += 1)
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
          if (rowIndex < rows.length - 1) const AppDivider(),
        ],
      ],
    );
  }
}

class _QuickRecordTile extends StatelessWidget {
  const _QuickRecordTile({
    required this.action,
    required this.l10n,
    required this.metrics,
    this.onTap,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final _QuickRecordMetrics metrics;
  final ValueChanged<RecordQuickAction>? onTap;

  @override
  Widget build(BuildContext context) {
    final isLocked = action.locked;
    final displayLabel = recordCopy(l10n, action.titleKey);

    return FTappable(
      key: Key('record-quick-${action.type.name}'),
      onPress: (onTap == null || isLocked) ? null : () => onTap!(action),
      child: Semantics(
        button: true,
        label: isLocked
            ? '$displayLabel ${l10n.recordNotEnabledLabel}'
            : displayLabel,
        child: Opacity(
          opacity: isLocked ? 0.76 : 1,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: metrics.tileVerticalPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FAvatar.raw(
                  size: metrics.avatarSize,
                  style: .delta(
                    backgroundColor: action.softColor.subtle(context),
                  ),
                  child: Icon(
                    isLocked ? SemanticIcons.statusBlocked : action.icon,
                    color: action.accent.solid(context),
                    size: Spacing.level5,
                  ),
                ),
                const SizedBox(height: Spacing.level2),
                Text(
                  displayLabel,
                  style: TypographyToken.level5
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickRecordNoteButton extends StatelessWidget {
  const _QuickRecordNoteButton({
    required this.action,
    required this.l10n,
    required this.metrics,
    this.onTap,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final _QuickRecordMetrics metrics;
  final ValueChanged<RecordQuickAction>? onTap;

  @override
  Widget build(BuildContext context) {
    final isLocked = action.locked;
    final label = recordCopy(l10n, action.titleKey);

    return FTappable(
      key: const Key('record-quick-note'),
      onPress: (onTap == null || isLocked) ? null : () => onTap!(action),
      child: Semantics(
        button: true,
        label: isLocked ? '$label ${l10n.recordNotEnabledLabel}' : label,
        child: Opacity(
          opacity: isLocked ? 0.76 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.level4,
              vertical: Spacing.level2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FAvatar.raw(
                  size: metrics.avatarSize,
                  style: .delta(
                    backgroundColor: action.softColor.subtle(context),
                  ),
                  child: Icon(
                    isLocked ? SemanticIcons.statusBlocked : action.icon,
                    color: action.accent.solid(context),
                    size: Spacing.level5,
                  ),
                ),
                const SizedBox(width: Spacing.level3),
                Text(
                  label,
                  style: TypographyToken.level5
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
