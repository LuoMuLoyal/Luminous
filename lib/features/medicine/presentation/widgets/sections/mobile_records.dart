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
          style: TypographyToken.level7
              .display(context)
              .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
        ),
        const SizedBox(height: Spacing.level3),
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.level4),
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
                const SizedBox(height: Spacing.level4),
                const AppDivider(),
                const SizedBox(height: Spacing.level4),
                if (items.isEmpty)
                  _TodayPlanEmpty(l10n: l10n)
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
      padding: const EdgeInsets.symmetric(vertical: Spacing.level3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MedicationAvatar(item: item, size: Spacing.level8),
              const SizedBox(width: Spacing.level3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _itemName(l10n, item),
                      style: TypographyToken.level4
                          .body(context)
                          .copyWith(fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.level1),
                    Text(
                      _itemPlanDetail(),
                      style: TypographyToken.level3
                          .body(context)
                          .copyWith(color: colors.mutedForeground),
                    ),
                    const SizedBox(height: Spacing.level2),
                    Wrap(
                      spacing: Spacing.level2,
                      runSpacing: Spacing.level2,
                      children: [
                        TintedStatusBadge(
                          color: item.stateColor,
                          label: _itemState(l10n, item),
                        ),
                        if (_slotSummary().isNotEmpty)
                          FBadge(
                            style: .delta(
                              decoration: .shapeDelta(
                                color: SemanticColor.neutral.muted(context),
                                shape: RoundedSuperellipseBorder(
                                  borderRadius: BorderRadius.circular(
                                    RadiusTokens.level2,
                                  ),
                                  side: BorderSide(color: colors.border),
                                ),
                              ),
                            ),
                            child: Text(
                              _slotSummary(),
                              style: TypographyToken.level3
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
            const SizedBox(height: Spacing.level3),
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
                const SizedBox(width: Spacing.level3),
                Expanded(
                  child: _DoseActionButton(
                    key: const Key('medicine-plan-dose-action-skipped'),
                    label: l10n.medicineDoseActionSkipped,
                    icon: FLucideIcons.ban,
                    color: SemanticColor.neutral,
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

class _TodayPlanEmpty extends StatelessWidget {
  const _TodayPlanEmpty({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
      child: Row(
        children: [
          FAvatar.raw(
            size: Spacing.level8,
            child: Icon(
              FLucideIcons.calendarCheck,
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
                  l10n.medicineTodayPlanEmpty,
                  style: TypographyToken.level4
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  l10n.medicineNoMedicineBody,
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
