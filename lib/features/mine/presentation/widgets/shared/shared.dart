import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/design.dart';

class MineSectionTitle extends StatelessWidget {
  const MineSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Text(
      title,
      style: TypographyToken.level6
          .body(context)
          .copyWith(color: colors.foreground, fontWeight: FontWeight.w600),
    );
  }
}
