import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';

const mineGreen = AppColorTokens.cyanDeep;

class MineSectionTitle extends StatelessWidget {
  const MineSectionTitle({
    super.key,
    required this.title,
    required this.typography,
  });

  final String title;
  final AppTypographyScale typography;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: typography.displaySm.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    );
  }
}
