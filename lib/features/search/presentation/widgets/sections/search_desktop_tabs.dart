import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

class DesktopTabs extends StatelessWidget {
  const DesktopTabs({
    super.key,
    required this.l10n,
    required this.typography,
    required this.surface,
  });
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Row(
        children: [
          const Icon(Icons.favorite_rounded, color: AppColorTokens.link),
          const SizedBox(width: AppSpacingTokens.sm),
          Text(
            l10n.medicineSearchAssistantTitle,
            style: typography.bodyMdStrong,
          ),
        ],
      ),
      const Spacer(),
      _TopTab(label: l10n.medicineSearchPageTitle, active: true),
      _TopTab(label: l10n.medicineSearchMyBoxTab, active: false),
      const SizedBox(width: AppSpacingTokens.lg),
      const CircleAvatar(
        radius: 14,
        backgroundColor: AppColorTokens.linkSoft,
        child: Icon(Icons.person_outline_rounded, size: 16),
      ),
    ],
  );
}

class _TopTab extends StatelessWidget {
  const _TopTab({required this.label, required this.active});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(
      Theme.of(context).colorScheme.onSurface,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
      child: Column(
        children: [
          Text(
            label,
            style: typography.bodySmStrong.copyWith(
              color: active ? surface.link : surface.body,
            ),
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          Container(
            width: 42,
            height: 2,
            color: active ? surface.link : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
