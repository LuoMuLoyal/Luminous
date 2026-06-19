import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_components.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_copy.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_shared.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineArchiveSection extends StatelessWidget {
  const MineArchiveSection({super.key, required this.dashboard, required this.l10n, required this.typography, required this.surface});
  final MineDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final meta = _profileMeta(l10n, dashboard.profile);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MineSectionTitle(title: l10n.mineProfileTitle, typography: typography),
        const SizedBox(height: AppSpacingTokens.sm),
        MinePanel(
          surface: surface, padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < dashboard.archiveEntries.length; index += 1)
                _ArchiveRow(
                  entry: dashboard.archiveEntries[index],
                  subtitleOverride: dashboard.archiveEntries[index].titleKey == MineCopyKey.archiveBasicTitle ? meta : null,
                  l10n: l10n, typography: typography, surface: surface,
                  showDivider: index != dashboard.archiveEntries.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArchiveRow extends StatelessWidget {
  const _ArchiveRow({required this.entry, required this.l10n, required this.typography, required this.surface, required this.showDivider, this.subtitleOverride});
  final MineArchiveEntry entry;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool showDivider;
  final String? subtitleOverride;

  @override
  Widget build(BuildContext context) {
    final row = _TapRow(
      onTap: () {
        if (entry.route == null) { showMineToast(context, mineCopy(l10n, entry.titleKey)); return; }
        pushAuthRequiredRoute(context, entry.route!);
      },
      surface: surface,
      child: Row(
        children: [
          _SoftIcon(icon: entry.icon, color: entry.accent),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mineCopy(l10n, entry.titleKey), style: typography.bodyMdStrong.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppSpacingTokens.xxs),
                AppSkeletonText(text: subtitleOverride ?? mineCopy(l10n, entry.subtitleKey), style: typography.bodySm.copyWith(color: surface.body, letterSpacing: 0), maxLines: 1, overflow: TextOverflow.ellipsis, widthFactor: 0.74),
              ],
            ),
          ),
          if (entry.statusKey != null) ...[
            const SizedBox(width: AppSpacingTokens.sm),
            AppSkeletonSlot(
              skeleton: const AppInlineSkeletonBlock(height: 18, width: 46, radius: AppRadiusTokens.sm),
              child: Text(mineCopy(l10n, entry.statusKey!), style: typography.bodySmStrong.copyWith(color: entry.statusKey == MineCopyKey.archiveNeedsFill ? AppColorTokens.warning : mineGreen, letterSpacing: 0)),
            ),
          ],
          const SizedBox(width: AppSpacingTokens.xs),
          Icon(Icons.chevron_right_rounded, color: surface.body, size: AppSpacingTokens.lg),
        ],
      ),
    );
    if (!showDivider) return row;
    return Column(children: [row, Divider(height: 1, color: surface.hairline)]);
  }
}

class _TapRow extends StatelessWidget {
  const _TapRow({required this.child, required this.onTap, required this.surface});
  final Widget child;
  final VoidCallback onTap;
  final AppThemeSurface surface;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.lg, vertical: AppSpacingTokens.md), child: child),
    ),
  );
}

class _SoftIcon extends StatelessWidget {
  const _SoftIcon({required this.icon, required this.color});
  final IconData icon;
  final Color color;
  static const _defaultSize = 44.0;
  static const _defaultIconSize = 22.0;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadiusTokens.lg)),
    child: SizedBox.square(dimension: _defaultSize, child: Icon(icon, color: color, size: _defaultIconSize)),
  );
}

String _profileMeta(AppLocalizations l10n, MineProfileSnapshot profile) {
  final parts = <String>[
    if (profile.age != null) l10n.mineProfileAgeYears(profile.age!),
    if (profile.heightCm != null) l10n.mineProfileHeightCm(profile.heightCm!.round()),
  ];
  if (parts.isEmpty) return l10n.mineArchiveBasicSubtitle;
  return parts.join(' · ');
}
