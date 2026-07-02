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
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Row(
          children: [
            Icon(FLucideIcons.heartPulse, color: colors.primary, size: 18),
            const SizedBox(width: AppSpacingTokens.level3),
            Text(
              l10n.medicineSearchAssistantTitle,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Spacer(),
        _TopTab(label: l10n.medicineSearchPageTitle, active: true),
        _TopTab(label: l10n.medicineSearchMyBoxTab, active: false),
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

class _TopTab extends StatelessWidget {
  const _TopTab({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.level4),
      child: Column(
        children: [
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: active ? colors.primary : colors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacingTokens.level2),
          Container(
            width: 42,
            height: 2,
            color: active ? colors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
