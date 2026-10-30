import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/presentation/providers/surface.dart';
import 'package:luminous/features/medicine/presentation/routes.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medication_parts.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/workspace_parts.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Maximum drugbox rows rendered before collapsing the rest into the
/// "more" footer.
const _maxVisibleDrugboxItems = 3;

/// 药箱区块：当前在用药品列表 + 管理入口。
///
/// 数据自取（`medicineSurfaceStateProvider`），导航在组件内部完成——组件不带
/// 页面数据切片，也不收 `onXxx` 回调。
class DrugBoxSection extends ConsumerWidget {
  const DrugBoxSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(medicineSurfaceStateProvider).dataOrNull;
    if (workspace == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final items = workspace.plan.items
        .where((item) => item.currentMedicineId != null)
        .toList(growable: false);
    final typography = context.theme.typography;

    return Column(
      key: const Key('medicine-current-medications'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineDrugboxTitle,
          style: typography.display.xl.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          l10n.medicineDrugboxSubtitle,
          style: typography.body.xs.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
        const SizedBox(height: Spacing.md),
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DrugBoxHeader(
                  l10n: l10n,
                  hasMedicines: items.isNotEmpty,
                  count: items.length,
                ),
                const SizedBox(height: Spacing.lg),
                if (items.isEmpty)
                  _DrugBoxEmpty(l10n: l10n)
                else ...[
                  _DrugBoxContent(
                    items: items
                        .take(_maxVisibleDrugboxItems)
                        .toList(growable: false),
                    l10n: l10n,
                  ),
                  if (items.length > _maxVisibleDrugboxItems) ...[
                    const SizedBox(height: Spacing.sm),
                    TruncatedFooter(
                      label: l10n.medicineDrugboxMoreCount(
                        items.length - _maxVisibleDrugboxItems,
                      ),
                      onTap: () => pushAuthRequiredRoute(
                        context,
                        Routes.mineMedicineNew,
                      ),
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

class _DrugBoxHeader extends StatelessWidget {
  const _DrugBoxHeader({
    required this.l10n,
    required this.hasMedicines,
    required this.count,
  });

  final AppLocalizations l10n;
  final bool hasMedicines;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Row(
      children: [
        Container(
          width: Spacing.xl3,
          height: Spacing.xl3,
          decoration: BoxDecoration(
            color: SemanticColor.primary.muted(context),
            borderRadius: context.theme.style.borderRadius.md,
          ),
          child: Center(
            child: Icon(
              SemanticIcons.medicineKit,
              color: SemanticColor.primary.solid(context),
              size: IconSizeTokens.lg,
            ),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.medicineDrugboxTotal(count),
                style: typography.body.md.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                l10n.medicineDrugboxTotalPrefix,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.md),
        // 按钮是固有宽度:给宽度上限,左侧 Expanded 的统计文案才不会被挤到多行。
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: FButton(
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.xs,
            mainAxisSize: MainAxisSize.min,
            onPress: () => pushAuthRequiredRoute(
              context,
              hasMedicines ? Routes.mineMedicineNew : Routes.medicineSearch,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Forui 按钮内部 Row 给非 flex 子节点无界主轴约束,裸 Text 会按
                // 固有宽度排版并在窄屏溢出;Flexible 让它收缩并省略。
                Flexible(
                  child: Text(
                    hasMedicines
                        ? l10n.medicineManageMedicinesAction
                        : l10n.medicineQuickAddTitle,
                    style: TextStyle(
                      color: colors.foreground,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                Icon(
                  SemanticIcons.actionNext,
                  size: IconSizeTokens.lg,
                  color: colors.foreground,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DrugBoxContent extends StatelessWidget {
  const _DrugBoxContent({required this.items, required this.l10n});

  final List<MedicinePlanItem> items;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < items.length; index += 1) ...[
          _DrugBoxMedicationRow(item: items[index], l10n: l10n),
          if (index < items.length - 1) const AppDivider(),
        ],
      ],
    );
  }
}

class _DrugBoxEmpty extends StatelessWidget {
  const _DrugBoxEmpty({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          Icon(
            SemanticIcons.medicineBottle,
            color: SemanticColor.primary.solid(context),
            size: IconSizeTokens.lg,
          ),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.medicineNoMedicineTitle,
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

class _DrugBoxMedicationRow extends StatelessWidget {
  const _DrugBoxMedicationRow({required this.item, required this.l10n});

  final MedicinePlanItem item;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final name = itemName(l10n, item);
    final dosage = itemDosage(l10n, item);
    final schedule = itemSchedule(l10n, item);
    final state = itemState(l10n, item);
    final currentMedicineId = item.currentMedicineId;
    final source = item.source;
    final sourceRefId = item.sourceRefId;
    final typography = context.theme.typography;

    return FTappable(
      onPress: () {
        if (currentMedicineId == null) {
          unawaited(Toast.show(context, l10n.medicineOpenPlanItemToast));
          return;
        }
        // Default: open medicine detail page when source + sourceRefId are
        // available; otherwise fall back to the reminder detail page.
        if (source != null &&
            sourceRefId != null &&
            (source == 'cn' || source == 'drugbank')) {
          unawaited(
            MedicineDetailRoute(source: source, id: sourceRefId).push(context),
          );
          return;
        }
        unawaited(
          MedicineReminderDetailRoute(
            medicineId: currentMedicineId,
          ).push(context),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.md,
        ),
        child: Row(
          children: [
            MedicationAvatar(item: item, size: Spacing.xl3),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonText(
                    text: name,
                    style: typography.body.sm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widthFactor: 0.72,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SkeletonText(
                        text: '$dosage · ${compactRouteOrSchedule(schedule)}',
                        style: typography.body.xs.copyWith(
                          color: SemanticColor.neutral.solid(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        widthFactor: 0.66,
                      ),
                      SkeletonSlot(
                        skeleton: InlineSkeletonBlock(
                          height: 22,
                          width: 54,
                          radius:
                              context.theme.style.borderRadius.pill.topLeft.x,
                        ),
                        child: TintedStatusBadge(
                          color: item.stateColor,
                          label: state,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Icon(
              SemanticIcons.actionNext,
              color: SemanticColor.neutral.solid(context),
              size: IconSizeTokens.lg,
            ),
          ],
        ),
      ),
    );
  }
}
