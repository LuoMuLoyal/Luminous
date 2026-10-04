import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
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
    const sources = MedicineSearchSource.values;

    // FTabs gives each tab an equal share of the width (`tabAlignment.fill`)
    // and grows the tab to fit its label, so at the large text tier both
    // source labels used to wrap — the selected one onto three lines — and the
    // lifted indicator turned into a tall card that ate a quarter of the
    // screen. A single ellipsized line keeps the control's height driven by
    // `FTabsStyle.minHeight` only, and the filled (non-scrollable) alignment
    // keeps the label inside a bounded width so it cannot overflow at 320dp.
    return FTabs(
      key: const ValueKey('medicine-search-source-tabs'),
      control: FTabControl.lifted(
        index: sources.indexOf(selectedSource),
        onChange: (index) => onChanged(sources[index]),
      ),
      children: [
        for (final source in sources)
          FTabEntry(
            label: Text(
              sourceLabel(l10n, source),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            child: const SizedBox.shrink(),
          ),
      ],
    );
  }
}

String sourceLabel(AppLocalizations l10n, MedicineSearchSource source) =>
    switch (source) {
      MedicineSearchSource.cn => l10n.medicineSearchSourceCn,
      MedicineSearchSource.drugbank => l10n.medicineSearchSourceDrugbank,
    };
