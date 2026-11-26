import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/safety_tip.dart';
import 'package:material_ui/material_ui.dart';

/// One reviewed medication safety tip.
///
/// HIG inset grouped card: system surface fill (secondarySystemBackground in
/// dark), 12pt continuous corner radius, no border, 16pt padding. The tip text
/// is the whole card — no title row, no icon, no secondary label. Category and
/// provenance stay off screen; the server already localises [MedicineSafetyTip.text].
class SafetyTipCard extends StatelessWidget {
  const SafetyTipCard({super.key, required this.tip});

  final MedicineSafetyTip tip;

  @override
  Widget build(BuildContext context) {
    return FCard(
      key: Key('medicine-safety-tip-${tip.id}'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Text(
          tip.text,
          style: context.theme.typography.body.md.copyWith(height: 1.29),
        ),
      ),
    );
  }
}
