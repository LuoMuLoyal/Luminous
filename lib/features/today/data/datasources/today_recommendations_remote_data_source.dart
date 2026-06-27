import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/today/domain/entities/today_recommendation.dart';

class TodayRecommendationsRemoteDataSource {
  const TodayRecommendationsRemoteDataSource({required this.api});

  final TodayAnalysisApi api;

  Future<List<TodayRecommendation>> fetchRecommendations({
    List<String>? excludeIds,
  }) async {
    final response = await api.todayAnalysisControllerGetRecommendationsV1(
      exclude: excludeIds,
    );
    final dtos = response.data ?? const [];
    return dtos
        .map(
          (dto) => TodayRecommendation(
            id: dto.id,
            text: dto.text,
            category: dto.category,
          ),
        )
        .toList(growable: false);
  }
}
