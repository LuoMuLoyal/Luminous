import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
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
    this.summary = const RecordDaySummary(items: <RecordSummaryItem>[]),
    this.timeline = const <RecordTimelineEntry>[],
    this.onQuickAction,
    this.onQuickActionLongPress,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final RecordDaySummary summary;
  final List<RecordTimelineEntry> timeline;
  final ValueChanged<RecordQuickAction>? onQuickAction;

  /// Long-press is a shortcut to the type-specific "more/settings" surface
  /// (per the quick-entry UX spec), never the icon picker.
  final ValueChanged<RecordQuickAction>? onQuickActionLongPress;

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
                  badgeFor: (action) => _badgeFor(
                    action,
                    prefs,
                    l10n,
                    widget.summary,
                    widget.timeline,
                  ),
                  onTap: widget.onQuickAction,
                  onLongPress: widget.onQuickActionLongPress,
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
    final ordered = buildMobileQuickActions(actions, preferences: prefs);
    return ordered
        .map(
          (action) =>
              action.copyWith(icon: resolveQuickActionIcon(action, prefs)),
        )
        .toList(growable: false);
  }

  String? _badgeFor(
    RecordQuickAction action,
    QuickEntryPreferences prefs,
    AppLocalizations l10n,
    RecordDaySummary summary,
    List<RecordTimelineEntry> timeline,
  ) {
    return switch (action.type) {
      RecordEntryType.water => _waterBadge(prefs, l10n, summary, timeline),
      RecordEntryType.sleep => _sleepBadge(prefs, l10n, timeline),
      _ => null,
    };
  }

  String? _waterBadge(
    QuickEntryPreferences prefs,
    AppLocalizations l10n,
    RecordDaySummary summary,
    List<RecordTimelineEntry> timeline,
  ) {
    if (prefs.waterBadgeMode == QuickEntryWaterBadgeMode.hidden) return null;
    if (prefs.waterBadgeMode == QuickEntryWaterBadgeMode.dailyCount) {
      final count = timeline
          .where((entry) => entry.type == RecordEntryType.water)
          .length;
      return count > 0 ? count.toString() : null;
    }
    final waterSummary = summary.items
        .where((item) => item.type == RecordEntryType.water)
        .firstOrNull;
    if (waterSummary == null || waterSummary.value.trim().isEmpty) {
      return null;
    }
    final unit = waterSummary.unitKey == null
        ? ''
        : recordCopy(l10n, waterSummary.unitKey!);
    return '${waterSummary.value}$unit';
  }

  String? _sleepBadge(
    QuickEntryPreferences prefs,
    AppLocalizations l10n,
    List<RecordTimelineEntry> timeline,
  ) {
    if (!prefs.sleepInProgressBadgeEnabled) return null;
    final inProgress = timeline.any(
      (entry) =>
          entry.type == RecordEntryType.sleep &&
          entry.value == null &&
          entry.valueKey == null,
    );
    return inProgress ? l10n.recordQuickSleepInProgressBadge : null;
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
          onTap: () => _showQuickHelp(context, l10n),
        ),
      ],
    );
  }

  Future<void> _showQuickHelp(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    await showAppDialog<void>(
      context: context,
      maxWidth: 440,
      scrollable: false,
      builder: (dialogContext) => Column(
        key: const Key('record-quick-help-dialog'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recordQuickHelpTooltip,
            style: TypographyToken.level6.body(dialogContext),
          ),
          const SizedBox(height: Spacing.level4),
          _HelpLine(text: l10n.recordQuickSettingsMedicationRule),
          _HelpLine(text: l10n.recordQuickSettingsMealRule),
          _HelpLine(text: l10n.recordQuickSettingsSymptomRule),
          _HelpLine(text: l10n.recordQuickSettingsMoodRule),
          _HelpLine(text: l10n.recordQuickSettingsSleepRule),
          _HelpLine(text: l10n.recordQuickHelpLongPressRule),
          const SizedBox(height: Spacing.level5),
          Align(
            alignment: Alignment.centerRight,
            child: FButton(
              variant: FButtonVariant.ghost,
              onPress: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonConfirm),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpLine extends StatelessWidget {
  const _HelpLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.level2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(SemanticIcons.statusInfo, size: IconSizeTokens.level2),
          ),
          const SizedBox(width: Spacing.level2),
          Expanded(
            child: Text(text, style: TypographyToken.level4.body(context)),
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
    required this.badgeFor,
    this.onTap,
    this.onLongPress,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final _QuickRecordMetrics metrics;
  final String? Function(RecordQuickAction action) badgeFor;
  final ValueChanged<RecordQuickAction>? onTap;
  final ValueChanged<RecordQuickAction>? onLongPress;

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
                    badge: badgeFor(rows[rowIndex][index]),
                    onTap: onTap,
                    onLongPress: onLongPress,
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
    this.badge,
    this.onTap,
    this.onLongPress,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final _QuickRecordMetrics metrics;
  final String? badge;
  final ValueChanged<RecordQuickAction>? onTap;
  final ValueChanged<RecordQuickAction>? onLongPress;

  @override
  Widget build(BuildContext context) {
    final isLocked = action.locked;
    final displayLabel = recordCopy(l10n, action.titleKey);

    return FTappable(
      key: Key('record-quick-${action.type.name}'),
      onPress: (onTap == null || isLocked) ? null : () => onTap!(action),
      onLongPress: onLongPress == null ? null : () => onLongPress!(action),
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
                Stack(
                  clipBehavior: Clip.none,
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
                    if (badge != null)
                      Positioned(
                        top: -Spacing.level1,
                        right: -Spacing.level2,
                        child: _QuickBadge(text: badge!),
                      ),
                  ],
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

class _QuickBadge extends StatelessWidget {
  const _QuickBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.theme.colors.primary,
        borderRadius: BorderRadius.circular(RadiusTokens.levelFull),
        border: Border.all(color: context.theme.colors.background, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level2,
          vertical: 1,
        ),
        child: Text(
          text,
          style: TypographyToken.level1
              .body(context)
              .copyWith(
                color: context.theme.colors.primaryForeground,
                fontWeight: FontWeight.w700,
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
