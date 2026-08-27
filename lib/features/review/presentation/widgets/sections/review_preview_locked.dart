import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// A lightweight preview-locked card used on the Review page when the user is
/// signed out or has no active observation. It keeps the section visible as a
/// teaser while explicitly telling the user that the real content becomes
/// available after starting an observation or signing in.
class ReviewPreviewLockedSection extends StatelessWidget {
  const ReviewPreviewLockedSection({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: colors.primary, size: Spacing.level5),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    body,
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
