import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/components.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/shared.dart';
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
        const SizedBox(height: Spacing.level3),
        FTileGroup(
          key: const Key('mine-archive-section'),
          divider: FItemDivider.full,
          children: [
            for (final entry in dashboard.archiveEntries)
              _ArchiveRow(
                entry: entry,
                dashboard: dashboard,
                subtitleOverride:
                    entry.titleKey == MineCopyKey.archiveBasicTitle
                    ? meta
                    : null,
              ),
          ],
        ),
      ],
    );
  }
}

class _ArchiveRow extends StatelessWidget with FTileMixin {
  const _ArchiveRow({
    required this.entry,
    required this.dashboard,
    this.subtitleOverride,
  });

  final MineArchiveEntry entry;
  final MineDashboard dashboard;
  final String? subtitleOverride;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final statusKey = entry.statusKey ?? _derivedStatusKey();

    return FTile(
      prefix: SoftIcon(icon: entry.icon, color: entry.accent),
      title: Text(
        mineCopy(l10n, entry.titleKey),
        style: TypographyToken.level5
            .body(context)
            .copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitleOverride ?? mineCopy(l10n, entry.subtitleKey),
        style: TypographyToken.level3
            .body(context)
            .copyWith(color: colors.mutedForeground),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      details: statusKey == null
          ? null
          : Text(
              mineCopy(l10n, statusKey),
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(
                    color: statusKey == MineCopyKey.archiveNeedsFill
                        ? colors.destructive
                        : colors.mutedForeground,
                    fontWeight: FontWeight.w700,
                  ),
            ),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: () {
        final route = entry.route ?? _fallbackRouteFor(entry.titleKey);
        if (route == null) {
          showMineToast(context, mineCopy(l10n, entry.titleKey));
          return;
        }
        pushAuthRequiredRoute(context, route);
      },
    );
  }

  MineCopyKey? _derivedStatusKey() {
    return switch (entry.titleKey) {
      MineCopyKey.archiveMedicineTitle =>
        dashboard.profile.currentMedicineCount > 0
            ? MineCopyKey.archiveCompleted
            : MineCopyKey.archiveNeedsFill,
      _ => null,
    };
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
