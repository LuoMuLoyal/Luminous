import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/presentation/providers/medicine_search.dart';
import 'package:luminous/features/search/presentation/widgets/shared/add_to_box.dart';
import 'package:luminous/features/search/presentation/widgets/views/content.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(medicineSearchNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    // Build a set of already-added medicine keys (source:sourceRefId) so the
    // search result tiles can show an "already added" state.
    final snapshotAsync = ref.watch(healthContextSnapshotProvider);
    final addedMedicineIds = snapshotAsync.maybeWhen(
      data: (snapshot) => snapshot.currentMedicines
          .where((m) => m.isCurrent && m.sourceRefId != null)
          .map((m) => '${m.source}:${m.sourceRefId}')
          .toSet(),
      orElse: () => const <String>{},
    );

    return PageScaffold(
      title: l10n.medicineSearchPageTitle,
      child: MedicineSearchView(
        state: searchState,
        addedMedicineIds: addedMedicineIds,
        onQueryChanged: (q) =>
            ref.read(medicineSearchNotifierProvider.notifier).updateQuery(q),
        onSourceSwitched: (s) =>
            ref.read(medicineSearchNotifierProvider.notifier).switchSource(s),
        onResultSelected: (id) =>
            ref.read(medicineSearchNotifierProvider.notifier).selectResult(id),
        onRetry: () =>
            ref.read(medicineSearchNotifierProvider.notifier).retry(),
        onAddToCurrentMedicines: (result) =>
            _addToCurrentMedicines(ref, context, result),
      ),
    );
  }

  /// Thin delegation to the shared add-to-box loop
  /// ([addMedicineToBoxWithPrecheck]); the full F-9 flow lives in
  /// `widgets/shared/add_to_box.dart`, shared with the barcode scan exit.
  Future<void> _addToCurrentMedicines(
    WidgetRef ref,
    BuildContext context,
    MedicineSearchResult result,
  ) async {
    await addMedicineToBoxWithPrecheck(
      context,
      ref: ref,
      source: result.source == MedicineSearchSource.drugbank
          ? 'drugbank'
          : 'cn',
      sourceRefId: result.id,
      displayName: result.name,
    );
  }
}
