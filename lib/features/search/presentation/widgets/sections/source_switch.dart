import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
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

    return Row(
      children: MedicineSearchSource.values
          .map(
            (source) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: source == MedicineSearchSource.values.last
                      ? 0
                      : Spacing.level3,
                ),
                child: FButton.raw(
                  onPress: () => onChanged(source),
                  variant: FButtonVariant.outline,
                  style: .delta(
                    decoration: .delta([
                      .all(
                        .shapeDelta(
                          color: source == selectedSource
                              ? colors.primary.withValues(alpha: 0.1)
                              : colors.background,
                          shape: RoundedSuperellipseBorder(
                            side: BorderSide(
                              color: source == selectedSource
                                  ? colors.primary
                                  : colors.border,
                            ),
                          ),
                        ),
                      ),
                    ]),
                    contentStyle: const .delta(
                      padding: .value(
                        EdgeInsets.symmetric(
                          horizontal: Spacing.level4,
                          vertical: Spacing.level3,
                        ),
                      ),
                    ),
                  ),
                  child: Text(
                    sourceLabel(l10n, source),
                    textAlign: TextAlign.center,
                    style: TypographyToken.level5
                        .body(context)
                        .copyWith(
                          color: source == selectedSource
                              ? colors.primary
                              : colors.foreground,
                          fontWeight: FontWeight.w700,
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
