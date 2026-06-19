import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SearchTopBar extends StatelessWidget {
  const SearchTopBar({super.key, required this.l10n, required this.typography, required this.surface});
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  @override
  Widget build(BuildContext context) => Row(children: [BackButton(onPressed: () => context.pop()), Expanded(child: Text(l10n.medicineSearchPageTitle, textAlign: TextAlign.center, style: typography.displaySm))]);
}

class DesktopTabs extends StatelessWidget {
  const DesktopTabs({super.key, required this.l10n, required this.typography, required this.surface});
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  @override
  Widget build(BuildContext context) => Row(children: [Row(children: [const Icon(Icons.favorite_rounded, color: AppColorTokens.link), const SizedBox(width: AppSpacingTokens.sm), Text(l10n.medicineSearchAssistantTitle, style: typography.bodyMdStrong)]), const Spacer(), _TopTab(label: l10n.medicineSearchPageTitle, active: true), _TopTab(label: l10n.medicineSearchMyBoxTab, active: false), const SizedBox(width: AppSpacingTokens.lg), const CircleAvatar(radius: 14, backgroundColor: AppColorTokens.linkSoft, child: Icon(Icons.person_outline_rounded, size: 16))]);
}

class _TopTab extends StatelessWidget {
  const _TopTab({required this.label, required this.active});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(Theme.of(context).colorScheme.onSurface);
    return Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md), child: Column(children: [Text(label, style: typography.bodySmStrong.copyWith(color: active ? surface.link : surface.body)), const SizedBox(height: AppSpacingTokens.xs), Container(width: 42, height: 2, color: active ? surface.link : Colors.transparent)]));
  }
}

class SearchInput extends StatefulWidget {
  const SearchInput({super.key, required this.l10n, required this.typography, required this.surface, required this.query, required this.onChanged});
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final String query;
  final ValueChanged<String> onChanged;
  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late final TextEditingController _controller;
  @override
  void initState() { super.initState(); _controller = TextEditingController(text: widget.query); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  void didUpdateWidget(covariant SearchInput oldWidget) { super.didUpdateWidget(oldWidget); if (oldWidget.query != widget.query && widget.query != _controller.text) { _controller.text = widget.query; } }
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: widget.surface.canvas, borderRadius: BorderRadius.circular(AppRadiusTokens.lg), border: Border.all(color: widget.surface.hairlineStrong.withValues(alpha: 0.28))),
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md, vertical: AppSpacingTokens.sm), child: Row(children: [
      Icon(Icons.search_rounded, color: widget.surface.mute), const SizedBox(width: AppSpacingTokens.sm),
      Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: widget.l10n.medicineSearchFieldHint, hintStyle: widget.typography.bodySm.copyWith(color: widget.surface.mute), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero), style: widget.typography.bodySm, onChanged: widget.onChanged, textInputAction: TextInputAction.search, onSubmitted: widget.onChanged)),
      if (_controller.text.isNotEmpty) GestureDetector(onTap: () { _controller.clear(); widget.onChanged(''); }, child: Icon(Icons.cancel_rounded, color: widget.surface.mute, size: 18)),
    ])),
  );
}

class SourceSwitch extends StatelessWidget {
  const SourceSwitch({super.key, required this.selectedSource, required this.l10n, required this.typography, required this.surface, required this.onChanged});
  final MedicineSearchSource selectedSource;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<MedicineSearchSource> onChanged;
  @override
  Widget build(BuildContext context) => Row(children: MedicineSearchSource.values.map((source) => Expanded(child: Padding(padding: EdgeInsets.only(right: source == MedicineSearchSource.values.last ? 0 : AppSpacingTokens.sm), child: _SourceChip(label: sourceLabel(l10n, source), active: source == selectedSource, typography: typography, surface: surface, onTap: () => onChanged(source))))).toList());
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.label, required this.active, required this.typography, required this.surface, required this.onTap});
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md, vertical: AppSpacingTokens.sm),
            child: Text(label, textAlign: TextAlign.center, style: typography.bodySmStrong.copyWith(color: active ? surface.link : surface.body)),
          ),
        ),
      ),
    );
  }
}

class RecentSearches extends StatelessWidget {
  const RecentSearches({super.key, required this.keywords, required this.l10n, required this.typography, required this.surface});
  final List<String> keywords; final AppLocalizations l10n; final AppTypographyScale typography; final AppThemeSurface surface;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(l10n.medicineSearchRecentTitle, style: typography.bodyMdStrong), const Spacer(), Text(l10n.medicineSearchClearAction, style: typography.bodySmStrong.copyWith(color: surface.link))]), const SizedBox(height: AppSpacingTokens.sm), Wrap(spacing: AppSpacingTokens.sm, runSpacing: AppSpacingTokens.sm, children: keywords.map((keyword) => ActionChip(label: Text(keyword), onPressed: () => AppToast.show(context, keyword))).toList())]);
}

class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.actions, required this.l10n, required this.typography, required this.surface});
  final List<MedicineSearchQuickAction> actions; final AppLocalizations l10n; final AppTypographyScale typography; final AppThemeSurface surface;
  @override
  Widget build(BuildContext context) => DecoratedBox(decoration: BoxDecoration(color: surface.canvas, borderRadius: BorderRadius.circular(AppRadiusTokens.lg), border: Border.all(color: surface.hairline)), child: Row(children: actions.map((action) => Expanded(child: _QuickActionButton(action: action, l10n: l10n, typography: typography, surface: surface))).toList()));
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.action, required this.l10n, required this.typography, required this.surface});
  final MedicineSearchQuickAction action; final AppLocalizations l10n; final AppTypographyScale typography; final AppThemeSurface surface;
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: () => AppToast.show(context, actionToast(l10n, action.type)), borderRadius: BorderRadius.circular(AppRadiusTokens.lg), child: Padding(padding: const EdgeInsets.all(AppSpacingTokens.md), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(action.icon, color: action.accent), const SizedBox(width: AppSpacingTokens.sm), Text(actionLabel(l10n, action.type), style: typography.bodySmStrong)]))));
}

class Categories extends StatelessWidget {
  const Categories({super.key, required this.categories, required this.l10n, required this.typography});
  final List<MedicineSearchCategory> categories; final AppLocalizations l10n; final AppTypographyScale typography;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.medicineSearchCategoryTitle, style: typography.bodyMdStrong), const SizedBox(height: AppSpacingTokens.md), Row(children: categories.map((category) => Expanded(child: _CategoryItem(category: category, l10n: l10n, typography: typography))).toList())]);
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.category, required this.l10n, required this.typography});
  final MedicineSearchCategory category; final AppLocalizations l10n; final AppTypographyScale typography;
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: () => AppToast.show(context, categoryLabel(l10n, category.type)), borderRadius: BorderRadius.circular(AppRadiusTokens.lg), child: Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.xs), child: Column(children: [DecoratedBox(decoration: BoxDecoration(color: category.softColor.withValues(alpha: 0.74), shape: BoxShape.circle), child: Padding(padding: const EdgeInsets.all(AppSpacingTokens.sm), child: Icon(category.icon, color: category.accent))), const SizedBox(height: AppSpacingTokens.sm), Text(categoryLabel(l10n, category.type), style: typography.caption, textAlign: TextAlign.center)]))));
}

String sourceLabel(AppLocalizations l10n, MedicineSearchSource source) => switch (source) { MedicineSearchSource.cn => l10n.medicineSearchSourceCn, MedicineSearchSource.drugbank => l10n.medicineSearchSourceDrugbank };
String actionLabel(AppLocalizations l10n, MedicineSearchActionType type) => switch (type) { MedicineSearchActionType.photo => l10n.medicineSearchPhotoAction, MedicineSearchActionType.barcode => l10n.medicineSearchBarcodeAction, MedicineSearchActionType.keyword => l10n.medicineSearchNoResultKeyword, MedicineSearchActionType.switchSource => l10n.medicineSearchNoResultSwitch };
String actionToast(AppLocalizations l10n, MedicineSearchActionType type) => switch (type) { MedicineSearchActionType.photo => l10n.medicineSearchPhotoToast, MedicineSearchActionType.barcode => l10n.medicineSearchBarcodeToast, MedicineSearchActionType.keyword => l10n.medicineSearchNoResultKeyword, MedicineSearchActionType.switchSource => l10n.medicineSearchNoResultSwitch };
String categoryLabel(AppLocalizations l10n, MedicineSearchCategoryType type) => switch (type) { MedicineSearchCategoryType.painFever => l10n.medicineSearchCategoryPainFever, MedicineSearchCategoryType.coldCough => l10n.medicineSearchCategoryColdCough, MedicineSearchCategoryType.stomach => l10n.medicineSearchCategoryStomach, MedicineSearchCategoryType.supplement => l10n.medicineSearchCategorySupplement, MedicineSearchCategoryType.chronic => l10n.medicineSearchCategoryChronic };
