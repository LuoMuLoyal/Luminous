import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

class DetailSurface extends StatelessWidget {
  const DetailSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: child,
      ),
    );
  }
}
