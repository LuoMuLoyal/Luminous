import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_workspace_provider.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
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
    final authSession = ref.read(authSessionProvider);
    if (!authSession.canAccessProtectedData) {
      if (authSession.isLoading) {
        return;
      }
      if (context.mounted) {
        context.go('/login');
      }
      return;
    }

    final repository = ref.read(healthContextRepositoryProvider);

    final medicineSource = result.source == MedicineSearchSource.drugbank
        ? HealthMedicineSource.drugbank
        : HealthMedicineSource.cn;

    final input = CurrentMedicineWriteInput(
      source: medicineSource,
      sourceRefId: result.id,
      displayName: result.name,
    );

    try {
      await repository.createCurrentMedicine(input);
      ref.invalidate(healthContextSnapshotProvider);
      ref.invalidate(medicineWorkspaceProvider);
      ref.invalidate(todayDashboardProvider);

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
