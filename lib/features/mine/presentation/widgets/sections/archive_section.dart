import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
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
    final colors = context.theme.colors;

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Row(
          children: [
            FAvatar.raw(
              size: Spacing.level8,
              child: Icon(
                FLucideIcons.clipboardList,
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
                    style: TypographyToken.level4
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    l10n.mineArchiveEmptyDescription,
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
                        ? SemanticColor.warning.solid(context)
                        : colors.mutedForeground,
                    fontWeight: FontWeight.w700,
                  ),
            ),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: () {
        unawaited(_handleTap(context, ref));
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
      } catch (_) {
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
                      style: TypographyToken.level6
                          .body(context)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(FLucideIcons.x, size: 20),
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
                    const Icon(FLucideIcons.plus, size: 16),
                    const SizedBox(width: Spacing.level2),
                    Text(l10n.mineArchiveAddNewAction),
                  ],
                ),
              ),
            ),
          ],
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
    final colors = context.theme.colors;
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
                    style: TypographyToken.level4
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: Spacing.level1),
                    Text(
                      subtitle!,
                      style: TypographyToken.level3
                          .body(context)
                          .copyWith(color: colors.mutedForeground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: Spacing.level2),
            Icon(
              FLucideIcons.chevronRight,
              size: 18,
              color: colors.mutedForeground,
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
    MineCopyKey.archiveBasicTitle => AppRoutes.mineProfileEdit,
    MineCopyKey.archiveAllergyTitle => AppRoutes.mineAllergyNew,
    MineCopyKey.archiveConditionTitle => AppRoutes.mineConditionNew,
    MineCopyKey.archiveMedicineTitle => AppRoutes.mineMedicineNew,
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
