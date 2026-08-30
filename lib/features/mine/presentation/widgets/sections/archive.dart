import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/widgets/common/soft_icon.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/services/unit_conversion.dart';
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
      key: const Key('mine-archive-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MineSectionTitle(title: l10n.mineProfileTitle),
        const SizedBox(height: Spacing.level3),
        if (dashboard.archiveEntries.isEmpty)
          const _ArchiveEmpty()
        else
          FTileGroup(
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

class _ArchiveEmpty extends StatelessWidget {
  const _ArchiveEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Row(
          children: [
            FAvatar.raw(
              size: Spacing.level8,
              child: Icon(
                SemanticIcons.recordClipboard,
                color: SemanticColor.primary.solid(context),
                size: Spacing.level5,
              ),
            ),
            const SizedBox(width: Spacing.level4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.mineArchiveEmptyTitle,
                    style: typography.body.sm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    l10n.mineArchiveEmptyDescription,
                    style: typography.body.xs.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
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

class _ArchiveRow extends ConsumerWidget with FTileMixin {
  const _ArchiveRow({
    required this.entry,
    required this.dashboard,
    this.subtitleOverride,
  });

  final MineArchiveEntry entry;
  final MineDashboard dashboard;
  final String? subtitleOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statusKey = entry.statusKey ?? _derivedStatusKey();
    final typography = context.theme.typography;

    final tile = FTile(
      prefix: SoftIcon(icon: entry.icon, color: entry.accent),
      title: Text(
        mineCopy(l10n, entry.titleKey),
        style: typography.body.md.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitleOverride ?? mineCopy(l10n, entry.subtitleKey),
        style: typography.body.xs.copyWith(
          color: SemanticColor.neutral.solid(context),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      details: statusKey == null
          ? null
          : Text(
              mineCopy(l10n, statusKey),
              style: typography.body.xs.copyWith(
                color: statusKey == MineCopyKey.archiveNeedsFill
                    ? SemanticColor.warning.solid(context)
                    : SemanticColor.neutral.solid(context),
                fontWeight: FontWeight.w700,
              ),
            ),
      suffix: const Icon(SemanticIcons.actionNext),
      onPress: () {
        unawaited(_handleTap(context, ref));
      },
    );

    final editRoute = entry.route ?? _fallbackRouteFor(entry.titleKey);

    return FContextMenu.tiles(
      // ignore: sort_child_properties_last
      child: tile,
      menu: [
        FTileGroup(
          children: [
            FTile(
              title: Text(l10n.mineArchiveViewDetailAction),
              onPress: () => unawaited(_handleTap(context, ref)),
            ),
            if (editRoute != null)
              FTile(
                title: Text(l10n.mineArchiveEditAction),
                onPress: () =>
                    unawaited(pushAuthRequiredRoute(context, editRoute)),
              ),
          ],
        ),
      ],
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

  int _recordCount() {
    return switch (entry.titleKey) {
      MineCopyKey.archiveAllergyTitle => dashboard.profile.allergyCount,
      MineCopyKey.archiveConditionTitle => dashboard.profile.conditionCount,
      MineCopyKey.archiveMedicineTitle =>
        dashboard.profile.currentMedicineCount,
      _ => 0,
    };
  }

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    final route = entry.route ?? _fallbackRouteFor(entry.titleKey);
    if (route == null) {
      final l10n = AppLocalizations.of(context)!;
      showMineToast(context, mineCopy(l10n, entry.titleKey));
      return;
    }

    // When there are existing records, show a list bottom sheet first.
    if (_recordCount() > 0) {
      final l10n = AppLocalizations.of(context)!;
      HealthContextSnapshot? snapshot;
      try {
        snapshot = await ref.read(healthContextSnapshotProvider.future);
      } catch (e) {
        appTalker.warning('MineArchive: healthContextSnapshot load failed: $e');
        // If snapshot fails to load, fall through to direct navigation.
      }
      if (snapshot != null && _hasRecords(snapshot) && context.mounted) {
        _showRecordListSheet(context, route, snapshot, l10n);
        return;
      }
    }

    if (context.mounted) {
      unawaited(pushAuthRequiredRoute(context, route));
    }
  }

  bool _hasRecords(HealthContextSnapshot snapshot) {
    return switch (entry.titleKey) {
      MineCopyKey.archiveAllergyTitle => snapshot.allergies.isNotEmpty,
      MineCopyKey.archiveConditionTitle => snapshot.conditions.isNotEmpty,
      MineCopyKey.archiveMedicineTitle => snapshot.currentMedicines.isNotEmpty,
      _ => false,
    };
  }

  void _showRecordListSheet(
    BuildContext context,
    String newRoute,
    HealthContextSnapshot snapshot,
    AppLocalizations l10n,
  ) {
    final records = _collectRecords(snapshot);

    unawaited(
      showFSheet<void>(
        context: context,
        side: FLayout.btt,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.level4,
                  Spacing.level4,
                  Spacing.level4,
                  Spacing.level2,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        mineCopy(l10n, entry.titleKey),
                        style: context.theme.typography.body.lg.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(SemanticIcons.actionClose, size: 20),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
              ),
              const AppDivider(),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.level4,
                    vertical: Spacing.level2,
                  ),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const AppDivider(),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return _RecordListTile(
                      title: record.title,
                      subtitle: record.subtitle,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        unawaited(
                          pushAuthRequiredRoute(context, record.editRoute),
                        );
                      },
                    );
                  },
                ),
              ),
              const AppDivider(),
              Padding(
                padding: const EdgeInsets.all(Spacing.level4),
                child: FButton(
                  variant: FButtonVariant.outline,
                  onPress: () {
                    Navigator.of(sheetContext).pop();
                    unawaited(pushAuthRequiredRoute(context, newRoute));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(SemanticIcons.actionAdd, size: 16),
                      const SizedBox(width: Spacing.level2),
                      Text(l10n.mineArchiveAddNewAction),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_RecordItem> _collectRecords(HealthContextSnapshot snapshot) {
    return switch (entry.titleKey) {
      MineCopyKey.archiveAllergyTitle =>
        snapshot.allergies
            .map(
              (a) => _RecordItem(
                title: a.label,
                subtitle: a.reaction,
                editRoute: '/mine/allergy/${a.id}/edit',
              ),
            )
            .toList(),
      MineCopyKey.archiveConditionTitle =>
        snapshot.conditions
            .map(
              (c) => _RecordItem(
                title: c.label,
                subtitle: c.note,
                editRoute: '/mine/condition/${c.id}/edit',
              ),
            )
            .toList(),
      MineCopyKey.archiveMedicineTitle =>
        snapshot.currentMedicines
            .map(
              (m) => _RecordItem(
                title: m.displayName,
                subtitle: m.strengthText ?? m.doseText,
                editRoute: '/mine/medicine/${m.id}/edit',
              ),
            )
            .toList(),
      _ => const [],
    };
  }
}

class _RecordListTile extends StatelessWidget {
  const _RecordListTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return FTappable(
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.level3,
          horizontal: Spacing.level1,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: Spacing.level1),
                    Text(
                      subtitle!,
                      style: typography.body.xs.copyWith(
                        color: SemanticColor.neutral.solid(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: Spacing.level2),
            Icon(
              SemanticIcons.actionNext,
              size: 18,
              color: SemanticColor.neutral.solid(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordItem {
  const _RecordItem({
    required this.title,
    this.subtitle,
    required this.editRoute,
  });

  final String title;
  final String? subtitle;
  final String editRoute;
}

String? _fallbackRouteFor(MineCopyKey titleKey) {
  return switch (titleKey) {
    MineCopyKey.archiveBasicTitle => Routes.mineProfileEdit,
    MineCopyKey.archiveAllergyTitle => Routes.mineAllergyNew,
    MineCopyKey.archiveConditionTitle => Routes.mineConditionNew,
    MineCopyKey.archiveMedicineTitle => Routes.mineMedicineNew,
    _ => null,
  };
}

String _profileMeta(AppLocalizations l10n, MineProfileSnapshot profile) {
  final parts = <String>[
    if (profile.age != null) l10n.mineProfileAgeYears(profile.age!),
    if (profile.heightCm != null)
      l10n.mineProfileHeightCm(profile.heightCm?.round() ?? 0),
    if (profile.weightKg != null)
      isImperialUnitSystem(profile.unitSystem)
          ? l10n.mineProfileWeightLb(weightInLb(profile.weightKg)?.round() ?? 0)
          : l10n.mineProfileWeightKg(profile.weightKg?.round() ?? 0),
  ];
  if (parts.isEmpty) return l10n.mineArchiveBasicSubtitle;
  return parts.join(' · ');
}
