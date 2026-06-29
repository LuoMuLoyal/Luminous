import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SourceSwitch extends StatelessWidget {
  const SourceSwitch({
    super.key,
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
  Widget build(BuildContext context) => Row(
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
                label: sourceLabel(l10n, source),
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

String sourceLabel(AppLocalizations l10n, MedicineSearchSource source) =>
    switch (source) {
      MedicineSearchSource.cn => l10n.medicineSearchSourceCn,
      MedicineSearchSource.drugbank => l10n.medicineSearchSourceDrugbank,
    };
