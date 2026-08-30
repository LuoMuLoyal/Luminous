import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordNewEntryPanel extends StatelessWidget {
  const RecordNewEntryPanel({
    super.key,
    required this.actions,
    required this.l10n,
    this.onNewEntry,
    this.onQuickAction,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final VoidCallback? onNewEntry;
  final ValueChanged<RecordQuickAction>? onQuickAction;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    if (isDesktop) {
      return _buildDesktop(context);
    }
    return _buildMobile(context);
  }

  // ---------------------------------------------------------------------------
  // Desktop layout — vertical list with circular icon buttons.
  // ---------------------------------------------------------------------------
  Widget _buildDesktop(BuildContext context) {
    return FCard(
      key: const Key('record-new-entry-panel'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recordNewEntrySectionTitle,
              style: context.theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.level4),
            Column(
              children: actions
                  .take(7)
                  .map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.level2),
                      child: _DesktopEntryButton(
                        action: action,
                        l10n: l10n,
                        onTap: onQuickAction,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile layout — Wrap chips (unchanged from original).
  // ---------------------------------------------------------------------------
  Widget _buildMobile(BuildContext context) {
    final colors = context.theme.colors;

    return FCard(
      key: const Key('record-new-entry-panel'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recordNewEntrySectionTitle,
              style: context.theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.level4),
            Wrap(
              spacing: Spacing.level3,
              runSpacing: Spacing.level3,
              children: actions
                  .take(7)
                  .map(
                    (action) => _NewEntryChip(
                      action: action,
                      l10n: l10n,
                      onTap: onQuickAction,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: Spacing.level4),
            FButton(
              onPress: onNewEntry,
              variant: FButtonVariant.ghost,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              style: .delta(
                decoration: .delta([
                  .all(
                    .shapeDelta(
                      color: SemanticColor.neutral.subtle(context),
                      shape: RoundedSuperellipseBorder(
                        side: BorderSide(color: colors.border),
                        borderRadius: context.theme.style.borderRadius.sm,
                      ),
                    ),
                  ),
                ]),
                contentStyle: const .delta(
                  padding: .value(EdgeInsets.all(Spacing.level4)),
                ),
              ),
              prefix: Icon(
                SemanticIcons.actionAdd,
                color: context.theme.colors.primary,
                size: 20,
              ),
              child: Flexible(
                child: Text(
                  l10n.recordNewEntrySectionTitle,
                  style: context.theme.typography.body.md.copyWith(
                    color: context.theme.colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop-only vertical entry button with a 32px circular icon and full-width
/// label. Hover state uses [SemanticColor.neutral.subtle] background.
class _DesktopEntryButton extends StatefulWidget {
  const _DesktopEntryButton({
    required this.action,
    required this.l10n,
    this.onTap,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final ValueChanged<RecordQuickAction>? onTap;

  @override
  State<_DesktopEntryButton> createState() => _DesktopEntryButtonState();
}

class _DesktopEntryButtonState extends State<_DesktopEntryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final label = recordCopy(widget.l10n, widget.action.titleKey);
    final colors = context.theme.colors;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap == null ? null : () => widget.onTap!(widget.action),
        child: AnimatedContainer(
          duration: DurationTokens.widgetQuick,
          curve: MotionTokens.snappy,
          decoration: BoxDecoration(
            color: _isHovered
                ? SemanticColor.neutral.subtle(context)
                : Colors.transparent,
            borderRadius: context.theme.style.borderRadius.sm,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.level2,
              vertical: Spacing.level2,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.action.softColor.subtle(context),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      widget.action.icon,
                      color: widget.action.accent.solid(context),
                      size: IconSizeTokens.level3,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.level3),
                Expanded(
                  child: Text(
                    label,
                    style: context.theme.typography.body.sm.copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewEntryChip extends StatelessWidget {
  const _NewEntryChip({required this.action, required this.l10n, this.onTap});

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final ValueChanged<RecordQuickAction>? onTap;

  @override
  Widget build(BuildContext context) {
    final label = recordCopy(l10n, action.titleKey);

    return FButton.raw(
      onPress: onTap == null ? null : () => onTap!(action),
      variant: FButtonVariant.ghost,
      style: .delta(
        decoration: .delta([
          .all(
            .shapeDelta(
              color: action.softColor.fillStrong(context),
              shape: const RoundedSuperellipseBorder(),
            ),
          ),
        ]),
        contentStyle: const .delta(
          padding: .value(
            EdgeInsets.symmetric(
              horizontal: Spacing.level3,
              vertical: Spacing.level3,
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(action.icon, color: action.accent.solid(context), size: 16),
          const SizedBox(width: Spacing.level2),
          Text(
            label,
            style: context.theme.typography.body.xs.copyWith(
              color: action.accent.solid(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
