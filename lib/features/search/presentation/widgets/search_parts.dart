part of 'search_view.dart';

// go_router is available via search_view.dart's imports

class _SearchTopBar extends StatelessWidget {
  const _SearchTopBar({
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        Expanded(
          child: Text(
            l10n.medicineSearchPageTitle,
            textAlign: TextAlign.center,
            style: typography.displaySm,
          ),
        ),
        // No scan action — unsupported feature
      ],
    );
  }
}

class _DesktopTabs extends StatelessWidget {
  const _DesktopTabs({
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            const Icon(Icons.favorite_rounded, color: AppColorTokens.link),
            const SizedBox(width: AppSpacingTokens.sm),
            Text(
              l10n.medicineSearchAssistantTitle,
              style: typography.bodyMdStrong,
            ),
          ],
        ),
        const Spacer(),
        _TopTab(label: l10n.medicineSearchPageTitle, active: true),
        _TopTab(label: l10n.medicineSearchMyBoxTab, active: false),
        const SizedBox(width: AppSpacingTokens.lg),
        const CircleAvatar(
          radius: 14,
          backgroundColor: AppColorTokens.linkSoft,
          child: Icon(Icons.person_outline_rounded, size: 16),
        ),
      ],
    );
  }
}

class _TopTab extends StatelessWidget {
  const _TopTab({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(
      Theme.of(context).colorScheme.onSurface,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
      child: Column(
        children: [
          Text(
            label,
            style: typography.bodySmStrong.copyWith(
              color: active ? surface.link : surface.body,
            ),
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          Container(
            width: 42,
            height: 2,
            color: active ? surface.link : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _SearchInput extends StatefulWidget {
  const _SearchInput({
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.query,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final String query;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<_SearchInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query && widget.query != _controller.text) {
      _controller.text = widget.query;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(
          color: widget.surface.hairlineStrong.withValues(alpha: 0.28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.md,
          vertical: AppSpacingTokens.sm,
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: widget.surface.mute),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.l10n.medicineSearchFieldHint,
                  hintStyle: widget.typography.bodySm.copyWith(
                    color: widget.surface.mute,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: widget.typography.bodySm,
                onChanged: widget.onChanged,
                textInputAction: TextInputAction.search,
                onSubmitted: widget.onChanged,
              ),
            ),
            if (_controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onChanged('');
                },
                child: Icon(
                  Icons.cancel_rounded,
                  color: widget.surface.mute,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SourceSwitch extends StatelessWidget {
  const _SourceSwitch({
    required this.selectedSource,
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.onChanged,
  });

  final MedicineSearchSource selectedSource;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<MedicineSearchSource> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: MedicineSearchSource.values
          .map(
            (source) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: source == MedicineSearchSource.values.last
                      ? 0
                      : AppSpacingTokens.sm,
                ),
                child: _SourceChip(
                  label: _sourceLabel(l10n, source),
                  active: source == selectedSource,
                  typography: typography,
                  surface: surface,
                  onTap: () => onChanged(source),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({
    required this.label,
    required this.active,
    required this.typography,
    required this.surface,
    required this.onTap,
  });

  final String label;
  final bool active;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: active ? surface.linkSoft : surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: active ? surface.link : surface.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.md,
              vertical: AppSpacingTokens.sm,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: typography.bodySmStrong.copyWith(
                color: active ? surface.link : surface.body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({
    required this.keywords,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<String> keywords;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.medicineSearchRecentTitle,
              style: typography.bodyMdStrong,
            ),
            const Spacer(),
            Text(
              l10n.medicineSearchClearAction,
              style: typography.bodySmStrong.copyWith(color: surface.link),
            ),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        Wrap(
          spacing: AppSpacingTokens.sm,
          runSpacing: AppSpacingTokens.sm,
          children: keywords
              .map(
                (keyword) => ActionChip(
                  label: Text(keyword),
                  onPressed: () => AppToast.show(context, keyword),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.actions,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<MedicineSearchQuickAction> actions;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
      ),
      child: Row(
        children: actions
            .map(
              (action) => Expanded(
                child: _QuickActionButton(
                  action: action,
                  l10n: l10n,
                  typography: typography,
                  surface: surface,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.action,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final MedicineSearchQuickAction action;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AppToast.show(context, _actionToast(l10n, action.type)),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, color: action.accent),
              const SizedBox(width: AppSpacingTokens.sm),
              Text(
                _actionLabel(l10n, action.type),
                style: typography.bodySmStrong,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories({
    required this.categories,
    required this.l10n,
    required this.typography,
  });

  final List<MedicineSearchCategory> categories;
  final AppLocalizations l10n;
  final AppTypographyScale typography;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.medicineSearchCategoryTitle, style: typography.bodyMdStrong),
        const SizedBox(height: AppSpacingTokens.md),
        Row(
          children: categories
              .map(
                (category) => Expanded(
                  child: _CategoryItem(
                    category: category,
                    l10n: l10n,
                    typography: typography,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.l10n,
    required this.typography,
  });

  final MedicineSearchCategory category;
  final AppLocalizations l10n;
  final AppTypographyScale typography;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            AppToast.show(context, _categoryLabel(l10n, category.type)),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.xs),
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: category.softColor.withValues(alpha: 0.74),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.sm),
                  child: Icon(category.icon, color: category.accent),
                ),
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              Text(
                _categoryLabel(l10n, category.type),
                style: typography.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.result,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.expandedAction = false,
    this.onTap,
    this.onAddToCurrentMedicines,
  });

  final MedicineSearchResult result;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool expandedAction;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCurrentMedicines;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: surface.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(result.name, style: typography.displaySm),
                    ),
                    _SourceBadge(source: result.source, l10n: l10n),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.xs),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        result.subtitle,
                        style: typography.bodySm.copyWith(color: surface.body),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  _sourceRefLabel(l10n, result.source, result.id),
                  style: typography.caption.copyWith(color: surface.mute),
                ),
                const SizedBox(height: AppSpacingTokens.md),
                Text(
                  result.summary,
                  style: typography.bodySm.copyWith(color: surface.body),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacingTokens.md),
                Wrap(
                  spacing: AppSpacingTokens.sm,
                  runSpacing: AppSpacingTokens.sm,
                  children: [
                    ...result.tags.map(
                      (tag) => _TagPill(label: tag, surface: surface),
                    ),
                    _TagPill(
                      label:
                          '${l10n.medicineSearchMatchedBy}：${_matchTypeLabel(l10n, result.matchType)}',
                      surface: surface,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.md),
                Align(
                  alignment: expandedAction
                      ? Alignment.center
                      : Alignment.centerRight,
                  child: SizedBox(
                    width: expandedAction ? double.infinity : null,
                    child: FilledButton(
                      onPressed: onAddToCurrentMedicines,
                      child: Text(l10n.medicineSearchAddToBoxAction),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
    final isCn = source == MedicineSearchSource.cn;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isCn ? const Color(0xFFE7F8EF) : AppColorTokens.linkSoft,
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.sm,
          vertical: AppSpacingTokens.xs,
        ),
        child: Text(
          _sourceLabel(l10n, source),
          style: AppTypographyTokens.mobile(
            isCn ? const Color(0xFF0E9F6E) : AppColorTokens.linkDeep,
          ).caption,
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, required this.surface});

  final String label;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.linkSoft.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.sm,
          vertical: AppSpacingTokens.xs,
        ),
        child: Text(
          label,
          style: AppTypographyTokens.mobile(surface.link).caption,
        ),
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.state,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final MedicineSearchState state;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final preview = state.detailPreview;
    return DecoratedBox(
      decoration: _panelDecoration(surface),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.xl),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.medicineSearchPreviewTitle,
                style: typography.bodySmStrong,
              ),
              if (preview != null) ...[
                const SizedBox(height: AppSpacingTokens.lg),
                Text(preview.title, style: typography.bodyMdStrong),
                const SizedBox(height: AppSpacingTokens.md),
                if (preview.conditions.isNotEmpty) ...[
                  Text(
                    l10n.medicineSearchPreviewClinical,
                    style: typography.bodySmStrong.copyWith(
                      color: surface.mute,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  ...preview.conditions.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.xxs,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(Icons.circle, size: 4),
                          ),
                          const SizedBox(width: AppSpacingTokens.sm),
                          Expanded(
                            child: Text(
                              c,
                              style: typography.bodySm.copyWith(
                                color: surface.body.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacingTokens.md),
                if (preview.checklist.isNotEmpty) ...[
                  Text(
                    l10n.medicineSearchPreviewSafety,
                    style: typography.bodySmStrong.copyWith(
                      color: surface.mute,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  ...preview.checklist.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.xxs,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: surface.link,
                          ),
                          const SizedBox(width: AppSpacingTokens.sm),
                          Expanded(
                            child: Text(
                              item,
                              style: typography.bodySm.copyWith(
                                color: surface.body,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
              if (preview == null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacingTokens.lg),
                  child: Text(
                    l10n.medicineSearchPreviewEmpty,
                    style: typography.bodySm.copyWith(color: surface.mute),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoResultTools extends StatelessWidget {
  const _NoResultTools({
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final actions = <(IconData, String)>[
      (Icons.manage_search_rounded, l10n.medicineSearchNoResultKeyword),
      (Icons.swap_horiz_rounded, l10n.medicineSearchNoResultSwitch),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
        child: Column(
          children: [
            Text(
              l10n.medicineSearchNoResultTitle,
              style: typography.bodyMdStrong,
            ),
            const SizedBox(height: AppSpacingTokens.md),
            Row(
              children: actions
                  .map(
                    (item) => Expanded(
                      child: _NoResultAction(
                        icon: item.$1,
                        label: item.$2,
                        typography: typography,
                        surface: surface,
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
  const _NoResultAction({
    required this.icon,
    required this.label,
    required this.typography,
    required this.surface,
  });

  final IconData icon;
  final String label;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AppToast.show(context, label),
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.sm),
          child: Column(
            children: [
              Icon(icon, color: surface.link),
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                style: typography.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _panelDecoration(AppThemeSurface surface) {
  return BoxDecoration(
    color: surface.canvas,
    borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
    border: Border.all(color: surface.hairline),
    boxShadow: AppShadowTokens.level1,
  );
}

String _sourceLabel(AppLocalizations l10n, MedicineSearchSource source) {
  return switch (source) {
    MedicineSearchSource.cn => l10n.medicineSearchSourceCn,
    MedicineSearchSource.drugbank => l10n.medicineSearchSourceDrugbank,
  };
}

String _actionLabel(AppLocalizations l10n, MedicineSearchActionType type) {
  return switch (type) {
    MedicineSearchActionType.photo => l10n.medicineSearchPhotoAction,
    MedicineSearchActionType.barcode => l10n.medicineSearchBarcodeAction,
    MedicineSearchActionType.keyword => l10n.medicineSearchNoResultKeyword,
    MedicineSearchActionType.switchSource => l10n.medicineSearchNoResultSwitch,
  };
}

String _actionToast(AppLocalizations l10n, MedicineSearchActionType type) {
  return switch (type) {
    MedicineSearchActionType.photo => l10n.medicineSearchPhotoToast,
    MedicineSearchActionType.barcode => l10n.medicineSearchBarcodeToast,
    MedicineSearchActionType.keyword => l10n.medicineSearchNoResultKeyword,
    MedicineSearchActionType.switchSource => l10n.medicineSearchNoResultSwitch,
  };
}

String _categoryLabel(AppLocalizations l10n, MedicineSearchCategoryType type) {
  return switch (type) {
    MedicineSearchCategoryType.painFever =>
      l10n.medicineSearchCategoryPainFever,
    MedicineSearchCategoryType.coldCough =>
      l10n.medicineSearchCategoryColdCough,
    MedicineSearchCategoryType.stomach => l10n.medicineSearchCategoryStomach,
    MedicineSearchCategoryType.supplement =>
      l10n.medicineSearchCategorySupplement,
    MedicineSearchCategoryType.chronic => l10n.medicineSearchCategoryChronic,
  };
}

String _matchTypeLabel(AppLocalizations l10n, MedicineSearchMatchType type) {
  return switch (type) {
    MedicineSearchMatchType.ingredient => l10n.medicineSearchMatchIngredient,
    MedicineSearchMatchType.name => l10n.medicineSearchMatchName,
  };
}

String _sourceRefLabel(
  AppLocalizations l10n,
  MedicineSearchSource source,
  String id,
) {
  return switch (source) {
    MedicineSearchSource.cn => l10n.medicineSearchSourceRefCn(id),
    MedicineSearchSource.drugbank => l10n.medicineSearchSourceRefDrugbank(id),
  };
}
