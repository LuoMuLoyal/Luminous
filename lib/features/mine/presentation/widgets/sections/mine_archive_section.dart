import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/mine_components.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/mine_copy.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/mine_shared.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineArchiveSection extends StatelessWidget {
  const MineArchiveSection({super.key, required this.dashboard});

  final MineDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final meta = _profileMeta(l10n, dashboard.profile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MineSectionTitle(title: l10n.mineProfileTitle),
        const SizedBox(height: AppSpacingTokens.level3),
        FCard.raw(
          key: const Key('mine-archive-section'),
          child: Column(
            children: [
              for (
                var index = 0;
                index < dashboard.archiveEntries.length;
                index++
              )
                _ArchiveRow(
                  entry: dashboard.archiveEntries[index],
                  subtitleOverride:
                      dashboard.archiveEntries[index].titleKey ==
                          MineCopyKey.archiveBasicTitle
                      ? meta
                      : null,
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
  const _ArchiveRow({
    required this.entry,
    required this.showDivider,
    this.subtitleOverride,
  });

  final MineArchiveEntry entry;
  final bool showDivider;
  final String? subtitleOverride;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    final row = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final route = entry.route ?? _fallbackRouteFor(entry.titleKey);
          if (route == null) {
            showMineToast(context, mineCopy(l10n, entry.titleKey));
            return;
          }
          pushAuthRequiredRoute(context, route);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.level5,
            vertical: AppSpacingTokens.level4,
          ),
          child: Row(
            children: [
              _SoftIcon(icon: entry.icon, color: entry.accent),
              const SizedBox(width: AppSpacingTokens.level4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mineCopy(l10n, entry.titleKey),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacingTokens.level1),
                    AppSkeletonText(
                      text:
                          subtitleOverride ?? mineCopy(l10n, entry.subtitleKey),
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.mutedForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widthFactor: 0.74,
                    ),
                  ],
                ),
              ),
              if (entry.statusKey != null) ...[
                const SizedBox(width: AppSpacingTokens.level3),
                AppSkeletonSlot(
                  skeleton: const AppInlineSkeletonBlock(
                    height: 18,
                    width: 46,
                    radius: AppRadiusTokens.level2,
                  ),
                  child: Text(
                    mineCopy(l10n, entry.statusKey!),
                    style: textTheme.labelSmall?.copyWith(
                      color: entry.statusKey == MineCopyKey.archiveNeedsFill
                          ? Color(0xFFF59E0B)
                          : mineGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: AppSpacingTokens.level2),
              Icon(
                FLucideIcons.chevronRight,
                color: colors.mutedForeground,
                size: AppSpacingTokens.level5,
              ),
            ],
          ),
        ),
      ),
    );

    if (!showDivider) return row;

    return Column(
      children: [
        row,
        Divider(height: 1, color: colors.border),
      ],
    );
  }
}

class _SoftIcon extends StatelessWidget {
  const _SoftIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;
  static const _defaultSize = 44.0;
  static const _defaultIconSize = 22.0;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
      ),
      child: SizedBox.square(
        dimension: _defaultSize,
        child: Icon(icon, color: color, size: _defaultIconSize),
      ),
    );
  }
}

String? _fallbackRouteFor(MineCopyKey titleKey) {
  return switch (titleKey) {
    MineCopyKey.archiveBasicTitle => '/mine/profile/edit',
    MineCopyKey.archiveAllergyTitle => '/mine/allergy/new',
    MineCopyKey.archiveMedicineTitle => '/mine/medicine/new',
    MineCopyKey.archiveEmergencyTitle => '/settings',
    _ => null,
  };
}

String _profileMeta(AppLocalizations l10n, MineProfileSnapshot profile) {
  final parts = <String>[
    if (profile.age != null) l10n.mineProfileAgeYears(profile.age!),
    if (profile.heightCm != null)
      l10n.mineProfileHeightCm(profile.heightCm!.round()),
  ];
  if (parts.isEmpty) return l10n.mineArchiveBasicSubtitle;
  return parts.join(' · ');
}
