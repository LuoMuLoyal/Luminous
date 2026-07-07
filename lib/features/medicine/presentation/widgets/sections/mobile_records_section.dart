part of '../views/mobile_dashboard_view.dart';

class _MedicineRecordsSection extends ConsumerWidget {
  const _MedicineRecordsSection({
    required this.items,
    required this.l10n,
    required this.onMarkDose,
  });

  final List<MedicinePlanItem> items;
  final AppLocalizations l10n;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;

    final rows = _recordRowsFor(l10n, items).take(4).toList(growable: false);

    return FCard.raw(
      key: const Key('medicine-today-plan'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.medicineRecordsTitle,
                    style: AppTypographyToken.level7
                        .display(context)
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.level3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FilterText(label: l10n.medicineAllMedicinesFilter),
                    const SizedBox(width: AppSpacingTokens.level3),
                    _FilterText(label: l10n.medicineLastSevenDaysFilter),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.level4),
            if (rows.isEmpty)
              _DrugBoxEmpty(l10n: l10n)
            else
              Column(
                children: [
                  for (var index = 0; index < rows.length; index += 1) ...[
                    _MedicineRecordRow(
                      row: rows[index],
                      isLast: index == rows.length - 1,
                      l10n: l10n,
                      onMarkDose: onMarkDose,
                    ),
                    if (index < rows.length - 1) const AppDivider(),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacingTokens.level4,
                    ),
                    child: Center(
                      child: FButton(
                        variant: FButtonVariant.ghost,
                        size: FButtonSizeVariant.xs,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () => context.go(AppRoutes.record),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.medicineViewMoreRecordsAction,
                              style: TextStyle(
                                color: AppColors.primary.resolve(colors),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: AppSpacingTokens.level1),
                            Icon(
                              FLucideIcons.chevronRight,
                              size: AppSpacingTokens.level4,
                              color: AppColors.primary.resolve(colors),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MedicineRecordRow extends StatelessWidget {
  const _MedicineRecordRow({
    required this.row,
    required this.isLast,
    required this.l10n,
    required this.onMarkDose,
  });

  final _RecordRow row;
  final bool isLast;
  final AppLocalizations l10n;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final canMark =
        row.item.currentMedicineId != null &&
        onMarkDose != null &&
        row.item.todayStatus == MedicineDoseStatus.pending;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.level4,
        vertical: AppSpacingTokens.level3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSpacingTokens.level8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonText(
                  text: row.date,
                  style: AppTypographyToken.level3.body(context),
                  width: 34,
                ),
                const SizedBox(height: AppSpacingTokens.level1),
                AppSkeletonText(
                  text: row.time,
                  style: AppTypographyToken.level3.body(context),
                  width: 32,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.level2),
          SizedBox(
            width: AppSpacingTokens.level5,
            child: Column(
              children: [
                FAvatar.raw(
                  size: AppSpacingTokens.level5,
                  child: Icon(
                    row.statusIcon,
                    color: row.statusColor.resolve(colors),
                    size: AppSpacingTokens.level4,
                  ),
                ),
                if (!isLast)
                  const SizedBox(
                    height: AppSpacingTokens.level9,
                    child: AppDivider(axis: Axis.vertical),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.level3),
          _MedicationAvatar(item: row.item, size: AppSpacingTokens.level8),
          const SizedBox(width: AppSpacingTokens.level4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonText(
                  text: row.name,
                  style: AppTypographyToken.level4
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  widthFactor: 0.66,
                ),
                const SizedBox(height: AppSpacingTokens.level1),
                Wrap(
                  spacing: AppSpacingTokens.level2,
                  runSpacing: AppSpacingTokens.level1,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppSkeletonText(
                      text: row.detail,
                      style: AppTypographyToken.level3
                          .body(context)
                          .copyWith(color: colors.mutedForeground),
                      width: 94,
                    ),
                    AppSkeletonSlot(
                      skeleton: const AppInlineSkeletonBlock(
                        height: 22,
                        width: 44,
                        radius: AppRadiusTokens.levelFull,
                      ),
                      child: FBadge.raw(
                        builder: (context, style) {
                          final resolvedColor = row.statusColor.resolve(colors);
                          final foreground = 0.12 > 0.5
                              ? colors.primaryForeground
                              : resolvedColor;
                          return DecoratedBox(
                            decoration: ShapeDecoration(
                              color: resolvedColor.withValues(alpha: 0.12),
                              shape: RoundedSuperellipseBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadiusTokens.level2,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacingTokens.level2,
                                vertical: AppSpacingTokens.level1,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    row.statusLabel,
                                    style: AppTypographyToken.level3
                                        .body(context)
                                        .copyWith(
                                          color: foreground,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                if (canMark) ...[
                  const SizedBox(height: AppSpacingTokens.level3),
                  Row(
                    children: [
                      Expanded(
                        child: _DoseActionButton(
                          key: const Key('medicine-record-dose-action-taken'),
                          label: l10n.medicineDoseActionTaken,
                          icon: FLucideIcons.check,
                          color: AppColors.primary,
                          filled: true,
                          onTap: () => onMarkDose!(
                            row.item.currentMedicineId!,
                            MedicineDoseAction.taken,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacingTokens.level3),
                      Expanded(
                        child: _DoseActionButton(
                          key: const Key('medicine-record-dose-action-skipped'),
                          label: l10n.medicineDoseActionSkipped,
                          icon: FLucideIcons.ban,
                          color: AppColors.primary,
                          onTap: () => onMarkDose!(
                            row.item.currentMedicineId!,
                            MedicineDoseAction.skipped,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.level2),
          Icon(
            FLucideIcons.notebookText,
            color: colors.mutedForeground,
            size: AppSpacingTokens.level5,
          ),
        ],
      ),
    );
  }
}
