import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

const mineGreen = Color(0xFF0F766E);

class MineSectionTitle extends StatelessWidget {
  const MineSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      title,
      style: textTheme.titleLarge?.copyWith(
        color: colors.foreground,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
