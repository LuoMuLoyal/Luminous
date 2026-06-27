import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/today/data/datasources/today_recommendations_remote_data_source.dart';
import 'package:luminous/features/today/domain/entities/today_recommendation.dart';

final todayRecommendationsRemoteDataSourceProvider =
    Provider<TodayRecommendationsRemoteDataSource>(
      (ref) => TodayRecommendationsRemoteDataSource(
        api: ref.watch(lucentTodayAnalysisApiProvider),
      ),
    );

/// Current visible Today recommendations, managed as an [AsyncNotifier] so that
/// the "refresh" action can pass the previous ids to the backend for exclusion.
final todayRecommendationsProvider =
    AsyncNotifierProvider<
      TodayRecommendationsNotifier,
      List<TodayRecommendation>
    >(TodayRecommendationsNotifier.new);

class TodayRecommendationsNotifier
    extends AsyncNotifier<List<TodayRecommendation>> {
  @override
  Future<List<TodayRecommendation>> build() async {
    return _fetch(const []);
  }

  Future<void> refresh() async {
    final current = state.value ?? const [];
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetch(current.map((item) => item.id).toList()),
    );
  }

  Future<List<TodayRecommendation>> _fetch(List<String> excludeIds) async {
    final dataSource = ref.read(todayRecommendationsRemoteDataSourceProvider);
    return dataSource.fetchRecommendations(excludeIds: excludeIds);
  }
}
