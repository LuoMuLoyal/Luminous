import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/components.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/shared.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';

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

    final row = FTappable(
      onPress: () {
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
          vertical: AppSpacingTokens.level3,
        ),
        child: Row(
          children: [
            SoftIcon(icon: entry.icon, color: entry.accent),
            const SizedBox(width: AppSpacingTokens.level4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mineCopy(l10n, entry.titleKey),
                    style: AppTypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacingTokens.level1),
                  AppSkeletonText(
                    text: subtitleOverride ?? mineCopy(l10n, entry.subtitleKey),
                    style: AppTypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
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
                  style: AppTypographyToken.level3
                      .body(context)
                      .copyWith(
                        color: entry.statusKey == MineCopyKey.archiveNeedsFill
                            ? context.theme.colors.primary
                            : context.theme.colors.primary,
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
    );

    if (!showDivider) return row;

    return Column(children: [row, const AppDivider()]);
  }
}

String? _fallbackRouteFor(MineCopyKey titleKey) {
  return switch (titleKey) {
    MineCopyKey.archiveBasicTitle => AppRoutes.mineProfileEdit,
    MineCopyKey.archiveAllergyTitle => AppRoutes.mineAllergyNew,
    MineCopyKey.archiveMedicineTitle => AppRoutes.mineMedicineNew,
    MineCopyKey.archiveEmergencyTitle => AppRoutes.settings,
    _ => null,
  };
}

String _profileMeta(AppLocalizations l10n, MineProfileSnapshot profile) {
  final parts = <String>[
    if (profile.age != null) l10n.mineProfileAgeYears(profile.age!),
    if (profile.heightCm != null)
      l10n.mineProfileHeightCm(profile.heightCm?.round() ?? 0),
  ];
  if (parts.isEmpty) return l10n.mineArchiveBasicSubtitle;
  return parts.join(' · ');
}
