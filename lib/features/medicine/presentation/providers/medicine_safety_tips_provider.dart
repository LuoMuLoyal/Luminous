import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/medicine/data/datasources/safety_tips_remote_data_source.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_safety_tip.dart';

export 'package:luminous/features/medicine/presentation/utils/medicine_safety_tip_style.dart';

final safetyTipsRemoteDataSourceProvider = Provider<SafetyTipsRemoteDataSource>(
  (ref) =>
      SafetyTipsRemoteDataSource(api: ref.watch(lucentMedicinesApiProvider)),
);

/// Current visible safety tips, managed as an [AsyncNotifier] so that the
/// "refresh" action can pass the previous tip ids to the backend for exclusion.
final medicineSafetyTipListProvider =
    AsyncNotifierProvider<
      MedicineSafetyTipListNotifier,
      List<MedicineSafetyTip>
    >(MedicineSafetyTipListNotifier.new);

class MedicineSafetyTipListNotifier
    extends AsyncNotifier<List<MedicineSafetyTip>> {
  @override
  Future<List<MedicineSafetyTip>> build() async {
    return _fetch(const []);
  }

  Future<void> refresh() async {
    final currentTips = state.value ?? const [];
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetch(currentTips.map((tip) => tip.id).toList()),
    );
  }

  Future<List<MedicineSafetyTip>> _fetch(List<String> excludeIds) async {
    final dataSource = ref.read(safetyTipsRemoteDataSourceProvider);
    return dataSource.fetchTips(excludeIds: excludeIds);
  }
}
