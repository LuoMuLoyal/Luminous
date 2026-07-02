import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SourceSwitch extends StatelessWidget {
  const SourceSwitch({
    super.key,
    required this.selectedSource,
    required this.l10n,
    required this.onChanged,
  });

  final MedicineSearchSource selectedSource;
  final AppLocalizations l10n;
  final ValueChanged<MedicineSearchSource> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onChanged(source),
                    borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: source == selectedSource
                            ? colors.primary.withValues(alpha: 0.1)
                            : colors.background,
                        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                        border: Border.all(
                          color: source == selectedSource
                              ? colors.primary
                              : colors.border,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacingTokens.md,
                          vertical: AppSpacingTokens.sm,
                        ),
                        child: Text(
                          sourceLabel(l10n, source),
                          textAlign: TextAlign.center,
                          style: textTheme.labelLarge?.copyWith(
                            color: source == selectedSource
                                ? colors.primary
                                : colors.foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

String sourceLabel(AppLocalizations l10n, MedicineSearchSource source) =>
    switch (source) {
      MedicineSearchSource.cn => l10n.medicineSearchSourceCn,
      MedicineSearchSource.drugbank => l10n.medicineSearchSourceDrugbank,
    };
