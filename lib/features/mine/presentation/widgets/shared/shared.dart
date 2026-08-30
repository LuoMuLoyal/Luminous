import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class MineSectionTitle extends StatelessWidget {
  const MineSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Text(
      title,
      style: context.theme.typography.body.lg.copyWith(
        color: colors.foreground,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
