import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// A tappable tile for the medicine scan method picker (OCR / AI).
class MethodTile extends StatelessWidget {
  const MethodTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return FCard(
      style: .delta(
        decoration: .shapeDelta(
          color: colors.background,
          shape: RoundedSuperellipseBorder(
            side: BorderSide(color: SemanticColor.neutral.border(context)),
            borderRadius: context.theme.style.borderRadius.lg,
          ),
        ),
      ),
      child: FTile(
        onPress: onTap,
        prefix: Icon(
          icon,
          color: SemanticColor.primary.solid(context),
          size: IconSizeTokens.level6,
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: typography.body.sm.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
        suffix: Icon(
          SemanticIcons.actionNext,
          color: SemanticColor.neutral.solid(context),
        ),
      ),
    );
  }
}
