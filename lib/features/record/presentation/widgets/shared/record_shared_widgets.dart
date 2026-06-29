import 'package:flutter/material.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

class RecordIndentedDivider extends StatelessWidget {
  const RecordIndentedDivider({
    super.key,
    required this.surface,
    required this.indent,
    this.endIndent = 0,
  });

  final AppThemeSurface surface;
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: indent,
      endIndent: endIndent,
      color: surface.hairline,
    );
  }
}

class RecordShortVerticalDivider extends StatelessWidget {
  const RecordShortVerticalDivider({
    super.key,
    required this.surface,
    required this.height,
  });

  final AppThemeSurface surface;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: height,
        child: VerticalDivider(width: 1, thickness: 1, color: surface.hairline),
      ),
    );
  }
}
