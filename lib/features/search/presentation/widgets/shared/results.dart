import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/presentation/widgets/sections/source_switch.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SearchResultTile extends StatefulWidget {
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
  State<SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<SearchResultTile> {
  /// DrugBank names can be a full systematic chemical name — up to ~226 chars.
  /// The title is clamped to two lines so card height never depends on name
  /// length, but a clamped name is unreadable with no way out, so tapping it
  /// expands in place. The toggle is only offered when the name actually
  /// overflows, so ordinary short names stay a plain label.
  bool _nameExpanded = false;
  bool _nameOverflows = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final l10n = widget.l10n;
    final result = widget.result;

    final card = FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 徽章是 FBadge(内部 IntrinsicWidth):放进 Row 会先占满固有宽度,
            // 把药品名挤成多行。Wrap 放不下时让徽章换到下一行。
            // DrugBank 的 name 可能是完整的系统命名(如
            // "1,1,1-TRIFLUORO-3-ACETAMIDO-4-PHENYL-BUTAN-2-ONE"),不设上限会
            // 换行到七八行;标题固定最多两行 + 省略号,卡片高度不再由名称长度决定。
            //
            // 溢出检测必须发生在**受约束**的宽度上:Wrap 给子节点的是无界约束,
            // 在其内部测量拿不到真实可用宽度,故由这一层 LayoutBuilder 承担
            // (Column 的 maxWidth 即卡片内容宽度)。
            LayoutBuilder(
              builder: (context, constraints) {
                final nameStyle = typography.body.lg.copyWith(
                  fontWeight: FontWeight.w700,
                );
                final overflows = _measureOverflow(
                  context,
                  name: result.name,
                  style: nameStyle,
                  maxWidth: constraints.maxWidth,
                );

                if (overflows != _nameOverflows) {
                  // Layout callback: defer so we never setState during build.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _nameOverflows = overflows);
                  });
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: Spacing.md,
                      runSpacing: Spacing.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          result.name,
                          style: nameStyle,
                          maxLines: _nameExpanded ? null : _collapsedNameLines,
                          overflow: _nameExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                        _SourceBadge(source: result.source, l10n: l10n),
                      ],
                    ),
                    if (overflows) ...[
                      const SizedBox(height: Spacing.xs),
                      _NameToggle(
                        expanded: _nameExpanded,
                        l10n: l10n,
                        onPress: () =>
                            setState(() => _nameExpanded = !_nameExpanded),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              result.subtitle,
              style: typography.body.sm.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              sourceRefLabel(l10n, result.source, result.id),
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              result.summary,
              style: typography.body.md.copyWith(color: colors.foreground),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Spacing.lg),
            Wrap(
              spacing: Spacing.md,
              runSpacing: Spacing.md,
              children: [
                ...result.tags.map((tag) => _TagPill(label: tag)),
                _TagPill(
                  label: l10n.medicineSearchMatchedByType(
                    matchTypeLabel(l10n, result.matchType),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Align(
              alignment: widget.expandedAction
                  ? Alignment.center
                  : Alignment.centerRight,
              child: SizedBox(
                width: widget.expandedAction ? double.infinity : null,
                child: widget.alreadyAdded
                    ? FButton(
                        onPress: null,
                        variant: FButtonVariant.outline,
                        // FButton 内部是 Row,给非 flex 子节点无界主轴约束:
                        // Flexible 必须包在内容外,否则图标 + 标签按固有宽度溢出。
                        child: Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                SemanticIcons.statusDone,
                                size: IconSizeTokens.sm,
                                color: SemanticColor.primary.solid(context),
                              ),
                              const SizedBox(width: Spacing.sm),
                              Flexible(
                                child: Text(
                                  l10n.medicineSearchAlreadyAddedLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : FButton(
                        onPress: widget.onAddToCurrentMedicines,
                        child: Flexible(
                          child: Text(
                            l10n.medicineSearchAddToBoxAction,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
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
    return widget.onTap != null
        ? FTappable(onPress: widget.onTap, child: card)
        : card;
  }
}

/// Lines the result title is clamped to while collapsed.
const int _collapsedNameLines = 2;

/// Whether [name] would be clamped at [_collapsedNameLines] within [maxWidth].
///
/// The badge shares the row, so the title may also be pushed onto its own line;
/// measuring the full [maxWidth] is therefore the conservative (worst-case)
/// test: if the name fits there it fits anywhere, and if it does not we offer
/// the expand control rather than hiding text silently.
bool _measureOverflow(
  BuildContext context, {
  required String name,
  required TextStyle style,
  required double maxWidth,
}) {
  final painter = TextPainter(
    text: TextSpan(text: name, style: style),
    maxLines: _collapsedNameLines,
    textDirection: Directionality.of(context),
  )..layout(maxWidth: maxWidth);
  return painter.didExceedMaxLines;
}

/// Expand/collapse affordance, shown only when the title actually overflows.
///
/// A name that fits stays a plain label: no control, no hit target with no
/// visible cue.
class _NameToggle extends StatelessWidget {
  const _NameToggle({
    required this.expanded,
    required this.l10n,
    required this.onPress,
  });

  final bool expanded;
  final AppLocalizations l10n;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return FTappable(
      onPress: onPress,
      child: Text(
        expanded
            ? l10n.medicineSearchCollapseNameAction
            : l10n.medicineSearchExpandNameAction,
        style: context.theme.typography.body.xs.copyWith(
          color: SemanticColor.primary.solid(context),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
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
      child: Text(
        sourceLabel(l10n, source),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
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
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

/// 桌面端搜索右侧的详情由 shell 的 `DesktopDetailPane` 承载。
///
/// 这里原来有一张「选中项预览」卡：F-11 去掉了把后端 subtitle 拆成假临床提示的
/// 映射之后，它只剩一个药名，桌面端选中结果后右栏几乎空白。桌面端的详情呈现
/// 应当是**详情页本身并排展开**（与用药页药盒一致），而不是一份精简预览，
/// 所以该面板已删除，改由 `_DesktopSearchLayout` 打开 `detailPaneProvider`。

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
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          children: [
            Text(
              l10n.medicineSearchNoResultTitle,
              style: typography.body.md.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Spacing.lg),
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
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                children: [
                  Icon(icon, color: SemanticColor.primary.solid(context)),
                  const SizedBox(height: Spacing.sm),
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
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              children: [
                Icon(icon, color: SemanticColor.neutral.solid(context)),
                const SizedBox(height: Spacing.sm),
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
