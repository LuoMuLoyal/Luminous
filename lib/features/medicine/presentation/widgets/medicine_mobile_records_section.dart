part of 'medicine_mobile_dashboard_view.dart';

class _MedicineRecordsSection extends ConsumerWidget {
  const _MedicineRecordsSection({
    required this.items,
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.onMarkDose,
  });

  final List<MedicinePlanItem> items;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = _recordRowsFor(
      l10n,
      items,
      surface,
    ).take(4).toList(growable: false);

    return AppSectionSurface(
      key: const Key('medicine-today-plan'),
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
            _DrugBoxEmpty(l10n: l10n, typography: typography, surface: surface)
          else
            Column(
              children: [
                for (var index = 0; index < rows.length; index += 1) ...[
                  _MedicineRecordRow(
                    row: rows[index],
                    isLast: index == rows.length - 1,
                    typography: typography,
                    surface: surface,
                    l10n: l10n,
                    onMarkDose: onMarkDose,
                  ),
                  if (index < rows.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: AppSpacingTokens.x6l + AppSpacingTokens.sm,
                      color: surface.hairline,
                    ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacingTokens.md,
                  ),
                  child: Center(
                    child: AppTextAction(
                      label: l10n.medicineViewMoreRecordsAction,
                      color: surface.link,
                      onTap: () =>
                          ref.read(shellProvider.notifier).selectTab(1),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MedicineRecordRow extends StatelessWidget {
  const _MedicineRecordRow({
    required this.row,
    required this.isLast,
    required this.typography,
    required this.surface,
    required this.l10n,
    required this.onMarkDose,
  });

  final _RecordRow row;
  final bool isLast;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;

  @override
  Widget build(BuildContext context) {
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
                  style: typography.bodySm.copyWith(letterSpacing: 0),
                  width: 34,
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                AppSkeletonText(
                  text: row.time,
                  style: typography.bodySm.copyWith(letterSpacing: 0),
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
                      color: surface.hairline,
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
                  style: typography.bodyMdStrong.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
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
                      style: typography.bodySm.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
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
                          icon: Icons.check_rounded,
                          color: surface.teal,
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
                          icon: Icons.remove_done_rounded,
                          color: surface.warningDeep,
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
            Icons.event_note_outlined,
            color: surface.body,
            size: AppSpacingTokens.lg,
          ),
        ],
      ),
    );
  }
}
