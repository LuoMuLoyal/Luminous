import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
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
  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final prefs =
        ref.watch(quickEntryPreferencesProvider).asData?.value ??
        const QuickEntryPreferences();
    final metrics = _QuickRecordMetrics.resolve(context);

    final allActions = _applyPreferences(widget.actions, prefs);

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
        _PanelHeader(l10n: l10n),
        SizedBox(height: metrics.sectionGap),
        if (!prefs.collapsed)
          FCard(
            child: Column(
              children: [
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
// Panel header
// ---------------------------------------------------------------------------

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
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
        IconActionButton(
          key: const Key('record-quick-help-action'),
          tooltip: l10n.recordQuickHelpTooltip,
          icon: SemanticIcons.actionHelp,
          onTap: () {},
        ),
      ],
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
