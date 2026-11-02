import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/presentation/providers/surface.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/dose_marking.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medication_parts.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/workspace_parts.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 今日用药计划：下一剂提醒 + 待服用剂次列表 + 折叠。
///
/// 数据自取；打卡动作走 [MedicineDoseMarkRequest]，由页面级 handler 消费。
class MedicineRecordsSection extends ConsumerStatefulWidget {
  const MedicineRecordsSection({super.key});

  @override
  ConsumerState<MedicineRecordsSection> createState() =>
      _MedicineRecordsSectionState();
}

class _MedicineRecordsSectionState
    extends ConsumerState<MedicineRecordsSection> {
  static const _collapsedLimit = 4;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(medicineSurfaceStateProvider).dataOrNull;
    if (workspace == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final allItems = workspace.plan.items;
    final isTruncated = allItems.length > _collapsedLimit;
    final items = (_expanded || !isTruncated)
        ? allItems
        : allItems.take(_collapsedLimit).toList(growable: false);

    return Column(
      key: const Key('medicine-today-plan'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineTodayPlanTitle,
          style: context.theme.typography.display.xl.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: Spacing.md),
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DrugBoxReminderStrip(
                  key: const Key('medicine-next-reminder'),
                  workspace: workspace,
                  nextDose: nextDoseFor(workspace),
                  l10n: l10n,
                ),
                const SizedBox(height: Spacing.lg),
                const AppDivider(),
                const SizedBox(height: Spacing.lg),
                if (items.isEmpty)
                  _TodayPlanEmpty(l10n: l10n)
                else ...[
                  Column(
                    children: [
                      for (var index = 0; index < items.length; index += 1) ...[
                        _TodayPlanRow(item: items[index], l10n: l10n),
                        if (index < items.length - 1) const AppDivider(),
                      ],
                    ],
                  ),
                  if (isTruncated) ...[
                    const SizedBox(height: Spacing.sm),
                    TruncatedFooter(
                      label: _expanded
                          ? l10n.medicineTodayPlanCollapse
                          : l10n.medicineTodayPlanShowAll(allItems.length),
                      onTap: () => setState(() => _expanded = !_expanded),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DrugBoxReminderStrip extends StatelessWidget {
  const _DrugBoxReminderStrip({
    super.key,
    required this.workspace,
    required this.nextDose,
    required this.l10n,
  });

  final MedicineWorkspace workspace;
  final NextDose? nextDose;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final dose = nextDose;
    final item = dose?.item;
    final hasAnyMedicine = workspace.plan.items.isNotEmpty;
    final slot = dose?.slot;
    final value = item == null
        ? (hasAnyMedicine
              ? l10n.medicineNoPendingDose
              : l10n.medicineScheduleNotSet)
        : slot == null
        ? l10n.medicineScheduleNotSet
        : l10n.medicineNextDoseTodayTime(slotTimeLabel(l10n, slot));
    final detail = item == null
        ? (hasAnyMedicine
              ? l10n.medicineNoPendingDoseDetail
              : l10n.medicineNoMedicineBody)
        : doseSummary(l10n, item);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _DrugBoxMetricItem(
            icon: SemanticIcons.doseNext,
            color: SemanticColor.primary,
            label: l10n.medicineNextDoseReminderTitle,
            value: value,
            detail: detail,
          ),
        ),
        const _MetricDivider(),
        Expanded(
          child: _DrugBoxMetricItem(
            icon: SemanticIcons.reportAdherence,
            color: SemanticColor.primary,
            label: l10n.medicineHeroMetricAdherenceLabel,
            value: workspace.hero.metricAdherence,
            detail: l10n.medicineAdherenceDetail,
          ),
        ),
      ],
    );
  }
}

class _DrugBoxMetricItem extends StatelessWidget {
  const _DrugBoxMetricItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final SemanticColor color;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color.solid(context).withValues(alpha: 0.78),
                size: IconSizeTokens.lg,
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          SkeletonText(
            text: value,
            style: typography.body.md.copyWith(
              color: color.fillStrong(context),
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            widthFactor: 0.76,
          ),
          const SizedBox(height: Spacing.xs),
          SkeletonText(
            text: detail,
            style: typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            widthFactor: 0.88,
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: Spacing.xl5,
      child: AppDivider(axis: Axis.vertical),
    );
  }
}

class _TodayPlanRow extends StatelessWidget {
  const _TodayPlanRow({required this.item, required this.l10n});

  final MedicinePlanItem item;
  final AppLocalizations l10n;

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
    final canMark = takenRequest != null && skippedRequest != null;
    final hasReminder = item.currentMedicineId != null;
    // Take/Skip are dose actions against a *scheduled* slot: without a reminder
    // there is nothing to confirm, so an unscheduled medicine must not offer
    // them. `buildMedicineDoseMarkRequest` alone is not enough — a medicine
    // with no reminders derives `todayStatus == pending` from the absent dose
    // log, which would otherwise render the buttons for every drugbox item.
    // The two conditions cover different cases and both are required: `canMark`
    // drops the buttons once the slot is already taken/skipped, while
    // `hasScheduledSlots` drops them for medicines that have no schedule at all.
    final hasScheduledSlots = item.slots.isNotEmpty;
    final showDoseActions = canMark && hasScheduledSlots;
    final typography = context.theme.typography;

    final rowContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MedicationAvatar(item: item, size: Spacing.xl4),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName(l10n, item),
                      style: typography.body.sm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      _itemPlanDetail(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.xs.copyWith(
                        color: SemanticColor.neutral.solid(context),
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Wrap(
                      spacing: Spacing.sm,
                      runSpacing: Spacing.sm,
                      children: [
                        TintedStatusBadge(
                          color: item.stateColor,
                          label: itemState(l10n, item),
                        ),
                        if (_slotSummary().isNotEmpty)
                          FBadge(
                            style: .delta(
                              decoration: .shapeDelta(
                                color: SemanticColor.neutral.muted(context),
                                shape: RoundedSuperellipseBorder(
                                  borderRadius:
                                      context.theme.style.borderRadius.xs,
                                  side: BorderSide(
                                    color: SemanticColor.neutral.border(
                                      context,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            child: Text(
                              _slotSummary(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: typography.body.xs.copyWith(
                                color: colors.foreground,
                                fontWeight: FontWeight.w700,
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
          if (showDoseActions) ...[
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(
                  child: _DoseMarkAction(
                    key: const Key('medicine-plan-dose-action-taken'),
                    label: l10n.medicineDoseActionTaken,
                    icon: SemanticIcons.statusDone,
                    filled: true,
                    request: takenRequest,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: _DoseMarkAction(
                    key: const Key('medicine-plan-dose-action-skipped'),
                    label: l10n.medicineDoseActionSkipped,
                    icon: SemanticIcons.statusSkipped,
                    color: SemanticColor.neutral,
                    request: skippedRequest,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (!hasReminder) {
      return rowContent;
    }

    final currentMedicineId = item.currentMedicineId;
    return FContextMenu.tiles(
      // ignore: sort_child_properties_last
      child: rowContent,
      menu: [
        FTileGroup(
          children: [
            FTile(
              title: Text(l10n.medicineReminderDetailTitle),
              onPress: () => pushAuthRequiredRoute(
                context,
                '/medicine/reminders/$currentMedicineId',
              ),
            ),
            FTile(
              title: Text(l10n.medicineReminderEditTitle),
              onPress: () => pushAuthRequiredRoute(
                context,
                '/medicine/reminders/$currentMedicineId/edit',
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _itemPlanDetail() {
    final values = [
      itemDosage(l10n, item),
      compactRouteOrSchedule(itemSchedule(l10n, item)),
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
        .map((slot) => slotTimeLabel(l10n, slot))
        .where((value) => value.trim().isNotEmpty)
        .join(' · ');
  }
}

/// 打卡按钮：请求为 null 时不渲染（该药没有可确认的排程槽位）。
class _DoseMarkAction extends ConsumerWidget {
  const _DoseMarkAction({
    super.key,
    required this.label,
    required this.icon,
    required this.request,
    this.color = SemanticColor.primary,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final MedicineDoseMarkRequest? request;
  final SemanticColor color;
  final bool filled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markRequest = request;
    if (markRequest == null) return const SizedBox.shrink();
    return DoseActionButton(
      label: label,
      icon: icon,
      color: color,
      filled: filled,
      onTap: () => markMedicineDose(context, ref, markRequest),
    );
  }
}

class _TodayPlanEmpty extends StatelessWidget {
  const _TodayPlanEmpty({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          Icon(
            SemanticIcons.doseCalendarCheck,
            color: SemanticColor.primary.solid(context),
            size: IconSizeTokens.lg,
          ),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.medicineTodayPlanEmpty,
                  style: typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  l10n.medicineNoMedicineBody,
                  style: typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
