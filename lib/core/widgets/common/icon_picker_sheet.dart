import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/design/lucide_icon_bridge.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Opens a lightweight icon picker sheet using Forui components.
///
/// Returns the selected icon as [IconData] (resolved from [FLucideIcons]
/// via [LucideIconBridge]), or null if the user dismissed the sheet.
///
/// Shows a curated set of ~50 icons grouped by category, with an
/// optional search field to filter by name. The [currentIcon] parameter
/// highlights the currently selected icon.
///
/// Pass [categories] to override the default curated icon set — this
/// allows callers to inject a domain-specific or remotely-configured
/// icon collection without an app update.
Future<IconData?> showAppIconPicker(
  BuildContext context, {
  IconData? currentIcon,
  Map<IconPickerCategory, List<IconData>>? categories,
}) async {
  return showFSheet(
    context: context,
    side: FLayout.btt,
    builder: (context) => _IconPickerSheet(
      currentIcon: currentIcon,
      categories: categories ?? defaultIconPickerCategories,
    ),
  );
}

/// Category of curated icons for the health-record domain.
///
/// The order here determines the display order in the picker.
enum IconPickerCategory {
  food,
  health,
  status,
  body,
  general;

  /// Returns the localized label for this category.
  String label(AppLocalizations l10n) => switch (this) {
    food => l10n.iconPickerCategoryFood,
    health => l10n.iconPickerCategoryHealth,
    status => l10n.iconPickerCategoryStatus,
    body => l10n.iconPickerCategoryBody,
    general => l10n.iconPickerCategoryGeneral,
  };
}

/// Default curated icon categories for the health-record domain.
///
/// Callers can pass a custom [Map] to [showAppIconPicker.categories] to
/// override this set — e.g. from a remote config or a feature-flagged
/// expanded icon set.
const defaultIconPickerCategories = <IconPickerCategory, List<IconData>>{
  IconPickerCategory.food: [
    FLucideIcons.droplets,
    FLucideIcons.utensils,
    FLucideIcons.coffee,
    FLucideIcons.wine,
    FLucideIcons.cupSoda,
    FLucideIcons.apple,
    FLucideIcons.carrot,
    FLucideIcons.iceCream,
    FLucideIcons.cake,
    FLucideIcons.milk,
  ],
  IconPickerCategory.health: [
    FLucideIcons.activity,
    FLucideIcons.heartPulse,
    FLucideIcons.thermometer,
    FLucideIcons.stethoscope,
    FLucideIcons.pill,
    FLucideIcons.pillBottle,
    FLucideIcons.briefcaseMedical,
    FLucideIcons.syringe,
    FLucideIcons.bandage,
    FLucideIcons.brain,
  ],
  IconPickerCategory.status: [
    FLucideIcons.smile,
    FLucideIcons.frown,
    FLucideIcons.meh,
    FLucideIcons.moon,
    FLucideIcons.moonStar,
    FLucideIcons.sun,
    FLucideIcons.alarmClock,
    FLucideIcons.clock,
    FLucideIcons.timer,
    FLucideIcons.bell,
  ],
  IconPickerCategory.body: [
    FLucideIcons.footprints,
    FLucideIcons.bike,
    FLucideIcons.dumbbell,
    FLucideIcons.scale,
    FLucideIcons.heart,
    FLucideIcons.eye,
    FLucideIcons.hand,
  ],
  IconPickerCategory.general: [
    FLucideIcons.fileText,
    FLucideIcons.clipboardList,
    FLucideIcons.notebookPen,
    FLucideIcons.pencil,
    FLucideIcons.bookmark,
    FLucideIcons.star,
    FLucideIcons.camera,
    FLucideIcons.image,
    FLucideIcons.search,
    FLucideIcons.settings,
  ],
};

class _IconPickerSheet extends StatefulWidget {
  const _IconPickerSheet({required this.categories, this.currentIcon});

  final IconData? currentIcon;
  final Map<IconPickerCategory, List<IconData>> categories;

  @override
  State<_IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<_IconPickerSheet> {
  String _query = '';

  List<MapEntry<IconPickerCategory, List<IconData>>> get _filtered {
    if (_query.isEmpty) return widget.categories.entries.toList();
    final q = _query.toLowerCase();
    return widget.categories.entries
        .map(
          (e) => MapEntry(
            e.key,
            e.value.where((icon) {
              final name = LucideIconBridge.nameOf(icon) ?? '';
              return name.contains(q);
            }).toList(),
          ),
        )
        .where((e) => e.value.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;
    final filtered = _filtered;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: Spacing.level7,
              height: Spacing.level1,
              decoration: BoxDecoration(
                color: colors.mutedForeground,
                borderRadius: context.theme.style.borderRadius.pill,
              ),
            ),
            const SizedBox(height: Spacing.level4),
            // Search field
            FTextField(
              control: FTextFieldControl.managed(
                onChange: (value) => setState(() => _query = value.text),
              ),
              hint: l10n.iconPickerSearchHint,
              prefixBuilder: (context, style, variants) =>
                  FTextField.prefixIconBuilder(
                    context,
                    style,
                    variants,
                    Icon(
                      SemanticIcons.actionSearch,
                      color: colors.mutedForeground,
                    ),
                  ),
            ),
            const SizedBox(height: Spacing.level4),
            // Icon grid
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(Spacing.level6),
                      child: Text(
                        l10n.iconPickerEmpty,
                        style: context.theme.typography.body.xs.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: Spacing.level4),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final entry = filtered[index];
                        return _CategorySection(
                          label: entry.key.label(l10n),
                          icons: entry.value,
                          currentIcon: widget.currentIcon,
                          onSelected: (icon) => Navigator.of(context).pop(icon),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.label,
    required this.icons,
    required this.currentIcon,
    required this.onSelected,
  });

  final String label;
  final List<IconData> icons;
  final IconData? currentIcon;
  final ValueChanged<IconData> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: Spacing.level4,
            bottom: Spacing.level2,
          ),
          child: Text(
            label,
            style: context.theme.typography.body.xs2.copyWith(
              color: colors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: Spacing.level2,
          runSpacing: Spacing.level2,
          children: [
            for (final icon in icons)
              _IconChip(
                icon: icon,
                selected: icon == currentIcon,
                onTap: () => onSelected(icon),
              ),
          ],
        ),
      ],
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Spacing.level8,
        height: Spacing.level8,
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.secondary,
          borderRadius: context.theme.style.borderRadius.sm,
        ),
        child: Icon(
          icon,
          size: IconSizeTokens.level3,
          color: selected ? colors.primaryForeground : colors.mutedForeground,
        ),
      ),
    );
  }
}
