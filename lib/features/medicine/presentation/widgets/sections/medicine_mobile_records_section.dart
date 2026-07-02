part of '../views/medicine_mobile_dashboard_view.dart';

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
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: l10n.medicineRecordsTitle,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FilterText(label: l10n.medicineAllMedicinesFilter),
                  const SizedBox(width: AppSpacingTokens.sm),
                  _FilterText(label: l10n.medicineLastSevenDaysFilter),
                ],
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),
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
                    if (index < rows.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: AppSpacingTokens.x6l + AppSpacingTokens.sm,
                        color: colors.border,
                      ),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacingTokens.md,
                    ),
                    child: Center(
                      child: AppTextAction(
                        label: l10n.medicineViewMoreRecordsAction,
                        color: Color(0xFF16A34A),
                        onTap: () => context.go('/record'),
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
    final textTheme = Theme.of(context).textTheme;
    final canMark =
        row.item.currentMedicineId != null &&
        onMarkDose != null &&
        row.item.todayStatus == MedicineDoseStatus.pending;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSpacingTokens.x3l,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonText(
                  text: row.date,
                  style: textTheme.bodySmall,
                  width: 34,
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                AppSkeletonText(
                  text: row.time,
                  style: textTheme.bodySmall,
                  width: 32,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.xs),
          SizedBox(
            width: AppSpacingTokens.lg,
            child: Column(
              children: [
                AppIconBadge(
                  icon: row.statusIcon,
                  color: row.statusColor,
                  backgroundColor: row.statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  size: AppSpacingTokens.lg,
                  iconSize: AppSpacingTokens.md,
                ),
                if (!isLast)
                  SizedBox(
                    height: AppSpacingTokens.x4l,
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: colors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          _MedicationAvatar(item: row.item, size: AppSpacingTokens.x3l),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonText(
                  text: row.name,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  widthFactor: 0.66,
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Wrap(
                  spacing: AppSpacingTokens.xs,
                  runSpacing: AppSpacingTokens.xxs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppSkeletonText(
                      text: row.detail,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.mutedForeground,
                      ),
                      width: 94,
                    ),
                    AppSkeletonSlot(
                      skeleton: const AppInlineSkeletonBlock(
                        height: 22,
                        width: 44,
                        radius: AppRadiusTokens.pill,
                      ),
                      child: AppStatusPill(
                        label: row.statusLabel,
                        color: row.statusColor,
                      ),
                    ),
                  ],
                ),
                if (canMark) ...[
                  const SizedBox(height: AppSpacingTokens.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _DoseActionButton(
                          key: const Key('medicine-record-dose-action-taken'),
                          label: l10n.medicineDoseActionTaken,
                          icon: FLucideIcons.check,
                          color: Color(0xFF0F766E),
                          filled: true,
                          onTap: () => onMarkDose!(
                            row.item.currentMedicineId!,
                            MedicineDoseAction.taken,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      Expanded(
                        child: _DoseActionButton(
                          key: const Key('medicine-record-dose-action-skipped'),
                          label: l10n.medicineDoseActionSkipped,
                          icon: FLucideIcons.ban,
                          color: Color(0xFFB45309),
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
          const SizedBox(width: AppSpacingTokens.xs),
          Icon(
            FLucideIcons.notebookText,
            color: colors.mutedForeground,
            size: AppSpacingTokens.lg,
          ),
        ],
      ),
    );
  }
}
