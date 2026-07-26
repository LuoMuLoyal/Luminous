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

    return FTabs(
      key: const ValueKey('medicine-search-source-tabs'),
      control: FTabControl.lifted(
        index: sources.indexOf(selectedSource),
        onChange: (index) => onChanged(sources[index]),
      ),
      children: [
        for (final source in sources)
          FTabEntry(
            label: Text(sourceLabel(l10n, source)),
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
