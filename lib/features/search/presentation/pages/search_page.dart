import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/search/presentation/providers/search_provider.dart';
import 'package:luminous/features/search/presentation/widgets/search_view.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(medicineSearchNotifierProvider);

    return Scaffold(
      body: MedicineSearchView(
        state: searchState,
        onQueryChanged: (q) => ref.read(medicineSearchNotifierProvider.notifier).updateQuery(q),
        onSourceSwitched: (s) => ref.read(medicineSearchNotifierProvider.notifier).switchSource(s),
        onResultSelected: (id) => ref.read(medicineSearchNotifierProvider.notifier).selectResult(id),
        onRetry: () => ref.read(medicineSearchNotifierProvider.notifier).retry(),
      ),
    );
  }
}
