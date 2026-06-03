import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';
import 'package:luminous/features/search/presentation/providers/search_provider.dart';
import 'package:luminous/features/search/presentation/widgets/search_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(medicineSearchNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: MedicineSearchView(
        state: searchState,
        onQueryChanged: (q) =>
            ref.read(medicineSearchNotifierProvider.notifier).updateQuery(q),
        onSourceSwitched: (s) =>
            ref.read(medicineSearchNotifierProvider.notifier).switchSource(s),
        onResultSelected: (id) =>
            ref.read(medicineSearchNotifierProvider.notifier).selectResult(id),
        onRetry: () =>
            ref.read(medicineSearchNotifierProvider.notifier).retry(),
        onAddToCurrentMedicines: (result) =>
            _addToCurrentMedicines(ref, context, l10n, result),
      ),
    );
  }

  Future<void> _addToCurrentMedicines(
    WidgetRef ref,
    BuildContext context,
    AppLocalizations l10n,
    MedicineSearchResult result,
  ) async {
    final repository = ref.read(healthContextRepositoryProvider);

    final medicineSource = result.source == MedicineSearchSource.drugbank
        ? MedicineSource.drugbank
        : MedicineSource.cn;

    final dto = CreateCurrentMedicineDto(
      source_: medicineSource,
      sourceRefId: result.id,
      displayName: result.name,
    );

    try {
      await repository.createCurrentMedicine(dto);
      ref.invalidate(healthContextSnapshotProvider);

      if (context.mounted) {
        AppToast.show(context, l10n.mineEditSavedToast);
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.show(context, '${l10n.settingsSyncFailed}: $e');
      }
    }
  }
}
