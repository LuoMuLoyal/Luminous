part of '../views/mobile_dashboard_view.dart';

class _MedicineRecordsSection extends StatelessWidget {
  const _MedicineRecordsSection({
    required this.workspace,
    required this.nextDose,
    required this.l10n,
    required this.onMarkDose,
  });

  final MedicineWorkspace workspace;
  final _NextDose? nextDose;
  final AppLocalizations l10n;
  final void Function(MedicineDoseMarkRequest request)? onMarkDose;

  @override
  Widget build(BuildContext context) {
    final items = workspace.plan.items.take(4).toList(growable: false);

    return Column(
      key: const Key('medicine-today-plan'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineTodayPlanTitle,
          style: AppTypographyToken.level7
              .display(context)
              .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        FCard.raw(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.level4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DrugBoxReminderStrip(
                  key: const Key('medicine-next-reminder'),
                  workspace: workspace,
                  nextDose: nextDose,
                  l10n: l10n,
                  onMarkDose: onMarkDose,
                ),
                const SizedBox(height: AppSpacingTokens.level4),
                const AppDivider(),
                const SizedBox(height: AppSpacingTokens.level4),
                if (items.isEmpty)
                  _DrugBoxEmpty(l10n: l10n)
                else
                  Column(
                    children: [
                      for (var index = 0; index < items.length; index += 1) ...[
                        _TodayPlanRow(
                          item: items[index],
                          l10n: l10n,
                          onMarkDose: onMarkDose,
                        ),
                        if (index < items.length - 1) const AppDivider(),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TodayPlanRow extends StatelessWidget {
  const _TodayPlanRow({
    required this.item,
    required this.l10n,
    required this.onMarkDose,
  });

  final MedicinePlanItem item;
  final AppLocalizations l10n;
  final void Function(MedicineDoseMarkRequest request)? onMarkDose;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final takenRequest = buildMedicineDoseMarkRequest(
      item: item,
      action: MedicineDoseAction.taken,
    );
    final skippedRequest = buildMedicineDoseMarkRequest(
      item: item,
      action: MedicineDoseAction.skipped,
    );
    final canMark =
        onMarkDose != null && takenRequest != null && skippedRequest != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.level3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MedicationAvatar(item: item, size: AppSpacingTokens.level8),
              const SizedBox(width: AppSpacingTokens.level3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _itemName(l10n, item),
                      style: AppTypographyToken.level4
                          .body(context)
                          .copyWith(fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacingTokens.level1),
                    Text(
                      _itemPlanDetail(),
                      style: AppTypographyToken.level3
                          .body(context)
                          .copyWith(color: colors.mutedForeground),
                    ),
                    const SizedBox(height: AppSpacingTokens.level2),
                    Wrap(
                      spacing: AppSpacingTokens.level2,
                      runSpacing: AppSpacingTokens.level2,
                      children: [
                        TintedStatusBadge(
                          color: item.stateColor,
                          label: _itemState(l10n, item),
                        ),
                        if (_slotSummary().isNotEmpty)
                          FBadge(
                            style: .delta(
                              decoration: .shapeDelta(
                                color: colors.secondary.withValues(alpha: 0.08),
                                shape: RoundedSuperellipseBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadiusTokens.level2,
                                  ),
                                  side: BorderSide(color: colors.border),
                                ),
                              ),
                            ),
                            child: Text(
                              _slotSummary(),
                              style: AppTypographyToken.level3
                                  .body(context)
                                  .copyWith(
                                    color: colors.foreground,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ],
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
                    key: const Key('medicine-plan-dose-action-taken'),
                    label: l10n.medicineDoseActionTaken,
                    icon: FLucideIcons.check,
                    filled: true,
                    onTap: () => onMarkDose!(takenRequest),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.level3),
                Expanded(
                  child: _DoseActionButton(
                    key: const Key('medicine-plan-dose-action-skipped'),
                    label: l10n.medicineDoseActionSkipped,
                    icon: FLucideIcons.ban,
                    onTap: () => onMarkDose!(skippedRequest),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _itemPlanDetail() {
    final values = [
      _itemDosage(l10n, item),
      _compactRouteOrSchedule(_itemSchedule(l10n, item)),
    ].where((value) => value.trim().isNotEmpty && value.trim() != '—').toList();

    if (values.isEmpty) {
      return l10n.medicineScheduleNotSet;
    }

    return values.join(' · ');
  }

  String _slotSummary() {
    if (item.slots.isEmpty) {
      return '';
    }

    return item.slots
        .take(3)
        .map((slot) => _slotTimeLabel(l10n, slot))
        .where((value) => value.trim().isNotEmpty)
        .join(' · ');
  }
}
