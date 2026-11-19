import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:material_ui/material_ui.dart';

class DetailSurface extends StatelessWidget {
  const DetailSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FCard(
      child: Padding(padding: const EdgeInsets.all(Spacing.xl), child: child),
    );
  }
}
