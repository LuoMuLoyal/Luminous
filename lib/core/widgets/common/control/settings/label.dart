import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:material_ui/material_ui.dart';

/// Group heading above a run of tiles.
///
/// Domain-neutral: owns only the typography/padding decision, so any feature
/// may label a section with it.
class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
      child: Text(
        label,
        style: context.theme.typography.body.xs.copyWith(
          color: SemanticColor.neutral.solid(context),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
