import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// A single-select (or toggle) pill chip.
///
/// Selected state uses the `primary` semantic tone, unselected `neutral`; the
/// whole chip is a [FTappable] so it gets the app's press feedback, and
/// [Semantics] carries the selected flag for screen readers.
class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    required this.selected,
    this.onPress,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPress;

  @override
  Widget build(BuildContext context) {
    final tone = selected ? SemanticColor.primary : SemanticColor.neutral;
    return Semantics(
      selected: selected,
      button: true,
      child: FTappable(
        onPress: onPress,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tone.muted(context),
            borderRadius: context.theme.style.borderRadius.pill,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            child: Text(
              label,
              style: context.theme.typography.body.sm.copyWith(
                color: tone.solid(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
