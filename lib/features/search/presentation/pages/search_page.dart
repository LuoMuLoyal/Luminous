import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/search/presentation/providers/medicine_search_provider.dart';
import 'package:luminous/features/search/presentation/widgets/medicine_search_view.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(medicineSearchProvider);

    return Scaffold(
      body: searchAsync.when(
        data: (dashboard) => MedicineSearchView(dashboard: dashboard),
        loading: () => const MedicineSearchLoadingView(),
        error: (_, __) => MedicineSearchErrorView(
          onRetry: () => ref.invalidate(medicineSearchProvider),
        ),
      ),
    );
  }
}
