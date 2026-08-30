import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/design.dart';

/// Emotional tone for empty-state / message views.
///
/// The current theme only provides `primary` and `destructive` semantic colors, so:
/// - [neutral] and [success] use the primary color;
/// - [warning] and [danger] use the destructive color (red family).
///
/// Update this when the design system adds success/warning semantic colors.
enum StateTone { neutral, success, warning, danger }

/// Card view for displaying empty states, error messages, or action prompts.
///
/// Wrapped in [FCard] by default, with icon, title, and description vertically
/// centered, and an optional outline button.
/// Use [maxWidth] to constrain the card width, commonly used for centered popup-style prompts.
class StateMessageView extends StatelessWidget {
  const StateMessageView({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.actionKey,
    this.tone = StateTone.neutral,
    this.padding = const EdgeInsets.all(Spacing.level5),
    this.maxWidth,
  });

  final String title;
  final String? description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Key? actionKey;
  final StateTone tone;
  final EdgeInsetsGeometry padding;

  /// 若提供，则在外层套 [Center] + [ConstrainedBox] 限制最大宽度。
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final accent = switch (tone) {
      StateTone.neutral => SemanticColor.primary,
      StateTone.success => SemanticColor.primary,
      StateTone.warning => SemanticColor.destructive,
      StateTone.danger => SemanticColor.destructive,
    };

    Widget message = FCard(
      child: Padding(
        padding: padding,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accent.muted(context),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.level4),
                  child: Icon(icon, color: accent.solid(context), size: 28),
                ),
              ),
              const SizedBox(height: Spacing.level4),
              Text(
                title,
                style: context.theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (description != null) ...[
                const SizedBox(height: Spacing.level2),
                Text(
                  description!,
                  style: context.theme.typography.body.sm.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: Spacing.level5),
                FButton(
                  key: actionKey,
                  onPress: onAction,
                  variant: FButtonVariant.outline,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (maxWidth != null) {
      message = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          child: message,
        ),
      );
    }

    return message;
  }
}

/// Full-page error view, extends [StateMessageView] with centering and max-width constraints.
///
/// Used for page-level error states (e.g. request failure, skeleton timeout).
class StateErrorView extends StatelessWidget {
  const StateErrorView({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.tone = StateTone.neutral,
    this.compact = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final StateTone tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final message = StateMessageView(
      title: title,
      description: description,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
      tone: tone,
      padding: compact
          ? const EdgeInsets.all(Spacing.level4)
          : const EdgeInsets.all(Spacing.level5),
    );

    if (compact) {
      return message;
    }

    // Use LayoutBuilder so the view works both in finite-height parents
    // (e.g. the body of a non-scrollable Scaffold) and inside scrollables
    // where the incoming max height is unbounded.
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 320.0;
        return SizedBox(
          height: height,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.level4),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: message,
              ),
            ),
          ),
        );
      },
    );
  }
}
