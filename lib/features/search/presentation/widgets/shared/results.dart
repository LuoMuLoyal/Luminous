import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/presentation/providers/medicine_search.dart';
import 'package:luminous/features/search/presentation/widgets/sections/source_switch.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.result,
    required this.l10n,
    this.expandedAction = false,
    this.onTap,
    this.onAddToCurrentMedicines,
    this.alreadyAdded = false,
  });

  final MedicineSearchResult result;
  final AppLocalizations l10n;
  final bool expandedAction;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCurrentMedicines;
  final bool alreadyAdded;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    final card = FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    result.name,
                    style: typography.body.lg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _SourceBadge(source: result.source, l10n: l10n),
              ],
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              result.subtitle,
              style: typography.body.sm.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            const SizedBox(height: Spacing.level1),
            Text(
              sourceRefLabel(l10n, result.source, result.id),
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            const SizedBox(height: Spacing.level4),
            Text(
              result.summary,
              style: typography.body.md.copyWith(color: colors.foreground),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Spacing.level4),
            Wrap(
              spacing: Spacing.level3,
              runSpacing: Spacing.level3,
              children: [
                ...result.tags.map((tag) => _TagPill(label: tag)),
                _TagPill(
                  label: l10n.medicineSearchMatchedByType(
                    matchTypeLabel(l10n, result.matchType),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level4),
            Align(
              alignment: expandedAction
                  ? Alignment.center
                  : Alignment.centerRight,
              child: SizedBox(
                width: expandedAction ? double.infinity : null,
                child: alreadyAdded
                    ? FButton(
                        onPress: null,
                        variant: FButtonVariant.outline,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              SemanticIcons.statusDone,
                              size: IconSizeTokens.level2,
                              color: SemanticColor.primary.solid(context),
                            ),
                            const SizedBox(width: Spacing.level2),
                            Text(l10n.medicineSearchAlreadyAddedLabel),
                          ],
                        ),
                      )
                    : FButton(
                        onPress: onAddToCurrentMedicines,
                        child: Text(l10n.medicineSearchAddToBoxAction),
                      ),
              ),
            ),
          ],
        ),
      ),
    );

    // Only wrap in FTappable when an onTap callback is provided (desktop preview).
    // On mobile, the card is not tappable — the "Add to box" button is the
    // primary action, and tapping the card body has no visible result.
    return onTap != null ? FTappable(onPress: onTap, child: card) : card;
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source, required this.l10n});

  final MedicineSearchSource source;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return FBadge(
      variant: FBadgeVariant.primary,
      style: .delta(
        decoration: .boxDelta(
          borderRadius: context.theme.style.borderRadius.xs,
        ),
      ),
      child: Text(sourceLabel(l10n, source)),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return FBadge(
      variant: FBadgeVariant.primary,
      style: .delta(
        decoration: .boxDelta(
          color: SemanticColor.primary.muted(context),
          borderRadius: context.theme.style.borderRadius.xs,
        ),
        labelTextStyle: .delta(color: SemanticColor.primary.solid(context)),
      ),
      child: Text(label),
    );
  }
}

/// 桌面端搜索右侧预览面板（桌面冻结能力，F-11）。
///
/// 旧实现把后端单行「规格 / 厂商」subtitle 按 `\n` split 后渲染在「临床提示」
/// 标题下，并以恒空 checklist 暗示存在「安全确认」区块——包装信息伪装成临床
/// 提示。F-11 已移除该造假映射与恒空清单暗示：本面板仅展示所选药品标题与
/// 空态。本面板**不接入主路径**，避免造假模式被复制到移动端；移动端真实
/// 临床/安全内容走药品详情页（`/medicine/detail/:source/:id`）。
class PreviewPanel extends StatelessWidget {
  const PreviewPanel({super.key, required this.state, required this.l10n});

  final MedicineSearchState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final preview = state.detailPreview;
    final typography = context.theme.typography;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level6),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.medicineSearchPreviewTitle,
                style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
              ),
              if (preview != null) ...[
                const SizedBox(height: Spacing.level5),
                Text(
                  preview.title,
                  style: typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              if (preview == null)
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.level6),
                  child: Column(
                    children: [
                      Icon(
                        SemanticIcons.actionSearch,
                        size: IconSizeTokens.level7,
                        color: SemanticColor.neutral.solid(context),
                      ),
                      const SizedBox(height: Spacing.level4),
                      Text(
                        l10n.medicineSearchPreviewEmpty,
                        style: typography.body.md.copyWith(
                          color: SemanticColor.neutral.solid(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoResultTools extends StatelessWidget {
  const NoResultTools({
    super.key,
    required this.l10n,
    this.onClearQuery,
    this.onSwitchSource,
  });

  final AppLocalizations l10n;
  final VoidCallback? onClearQuery;
  final VoidCallback? onSwitchSource;

  @override
  Widget build(BuildContext context) {
    final actions = <(IconData, String, VoidCallback?)>[
      (
        SemanticIcons.actionSearch,
        l10n.medicineSearchNoResultKeyword,
        onClearQuery,
      ),
      (
        SemanticIcons.safetyInteraction,
        l10n.medicineSearchNoResultSwitch,
        onSwitchSource,
      ),
    ];
    final typography = context.theme.typography;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          children: [
            Text(
              l10n.medicineSearchNoResultTitle,
              style: typography.body.md.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Spacing.level4),
            Row(
              children: actions
                  .map(
                    (item) => Expanded(
                      child: _NoResultAction(
                        icon: item.$1,
                        label: item.$2,
                        onTap: item.$3,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultAction extends StatelessWidget {
  const _NoResultAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    return onTap != null
        ? FTappable(
            onPress: onTap,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.level3),
              child: Column(
                children: [
                  Icon(icon, color: SemanticColor.primary.solid(context)),
                  const SizedBox(height: Spacing.level2),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: typography.body.xs,
                  ),
                ],
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(Spacing.level3),
            child: Column(
              children: [
                Icon(icon, color: SemanticColor.neutral.solid(context)),
                const SizedBox(height: Spacing.level2),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ],
            ),
          );
  }
}

String matchTypeLabel(AppLocalizations l10n, MedicineSearchMatchType type) =>
    switch (type) {
      MedicineSearchMatchType.ingredient => l10n.medicineSearchMatchIngredient,
      MedicineSearchMatchType.name => l10n.medicineSearchMatchName,
    };

String sourceRefLabel(
  AppLocalizations l10n,
  MedicineSearchSource source,
  String id,
) => switch (source) {
  MedicineSearchSource.cn => l10n.medicineSearchSourceRefCn(id),
  MedicineSearchSource.drugbank => l10n.medicineSearchSourceRefDrugbank(id),
};
