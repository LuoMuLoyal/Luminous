import 'package:luminous/core/design/design.dart';
import 'package:material_ui/material_ui.dart';

/// The checkmark of a selected row in a single-choice list, or an empty slot
/// for the unselected ones.
///
/// Keeps its slot when unselected ([Opacity] rather than a conditional) so the
/// surrounding rows do not shift as the selection moves.
class SelectedMark extends StatelessWidget {
  const SelectedMark({super.key, required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isSelected ? 1 : 0,
      child: Icon(
        SemanticIcons.statusDone,
        size: IconSizeTokens.md,
        color: SemanticColor.primary.solid(context),
      ),
    );
  }
}
