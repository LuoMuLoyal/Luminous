import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class DesktopTabs extends StatelessWidget {
  const DesktopTabs({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    return Row(
      children: [
        Row(
          children: [
            Icon(
              SemanticIcons.profileCondition,
              color: SemanticColor.primary.solid(context),
              size: IconSizeTokens.md,
            ),
            const SizedBox(width: Spacing.md),
            Text(
              l10n.medicineSearchAssistantTitle,
              style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const Spacer(),
        const SizedBox(width: Spacing.xl),
        DecoratedBox(
          decoration: BoxDecoration(
            color: SemanticColor.primary.muted(context),
            shape: BoxShape.circle,
          ),
          child: const SizedBox(
            width: 28,
            height: 28,
            child: Icon(SemanticIcons.profileUser, size: IconSizeTokens.sm),
          ),
        ),
      ],
    );
  }
}
