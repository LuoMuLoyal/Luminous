import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/core/widgets/common/control/soft_icon.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/utils/archive_handlers.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/components.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ArchiveRow extends ConsumerWidget with FTileMixin {
  const ArchiveRow({
    super.key,
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

    final editRoute = entry.route ?? fallbackArchiveRoute(entry.titleKey);

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
    final route = entry.route ?? fallbackArchiveRoute(entry.titleKey);
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
                    return ArchiveRecordListTile(
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

  List<ArchiveRecordItem> _collectRecords(HealthContextSnapshot snapshot) {
    return switch (entry.titleKey) {
      MineCopyKey.archiveAllergyTitle =>
        snapshot.allergies
            .map(
              (a) => ArchiveRecordItem(
                title: a.label,
                subtitle: a.reaction,
                editRoute: '/mine/allergy/${a.id}/edit',
              ),
            )
            .toList(),
      MineCopyKey.archiveConditionTitle =>
        snapshot.conditions
            .map(
              (c) => ArchiveRecordItem(
                title: c.label,
                subtitle: c.note,
                editRoute: '/mine/condition/${c.id}/edit',
              ),
            )
            .toList(),
      MineCopyKey.archiveMedicineTitle =>
        snapshot.currentMedicines
            .map(
              (m) => ArchiveRecordItem(
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

class ArchiveRecordListTile extends StatelessWidget {
  const ArchiveRecordListTile({
    super.key,
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

class ArchiveRecordItem {
  const ArchiveRecordItem({
    required this.title,
    this.subtitle,
    required this.editRoute,
  });

  final String title;
  final String? subtitle;
  final String editRoute;
}
