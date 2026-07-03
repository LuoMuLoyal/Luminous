import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class DesktopTabs extends StatelessWidget {
  const DesktopTabs({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Row(
      children: [
        Row(
          children: [
            Icon(FLucideIcons.heartPulse, color: colors.primary, size: 18),
            const SizedBox(width: AppSpacingTokens.level3),
            Text(
              l10n.medicineSearchAssistantTitle,
              style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const Spacer(),
        FButton(
          variant: FButtonVariant.ghost,
          style: const .delta(
            contentStyle: .delta(
              padding: .value(
                EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.level4,
                  vertical: AppSpacingTokens.level2,
                ),
              ),
            ),
          ),
          onPress: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.medicineSearchPageTitle,
                style: typography.body.sm.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacingTokens.level2),
              Container(width: 42, height: 2, color: colors.primary),
            ],
          ),
        ),
        FButton(
          variant: FButtonVariant.ghost,
          style: const .delta(
            contentStyle: .delta(
              padding: .value(
                EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.level4,
                  vertical: AppSpacingTokens.level2,
                ),
              ),
            ),
          ),
          onPress: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.medicineSearchMyBoxTab,
                style: typography.body.sm.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacingTokens.level2),
              Container(width: 42, height: 2, color: Colors.transparent),
            ],
          ),
        ),
        const SizedBox(width: AppSpacingTokens.level5),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: 28,
            height: 28,
            child: Icon(
              FLucideIcons.userRound,
              size: 16,
              color: colors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
