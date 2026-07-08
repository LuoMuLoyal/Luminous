import 'package:lucent_api/api/export.dart';
import 'package:luminous/features/today/domain/entities/recommendation.dart';

class TodayRecommendationsRemoteDataSource {
  const TodayRecommendationsRemoteDataSource({required this.api});

  final TodayAnalysisApi api;

  Future<List<TodayRecommendation>> fetchRecommendations({
    List<String>? excludeIds,
  }) async {
    final response = await api.todayAnalysisControllerGetRecommendationsV1(
      exclude: excludeIds,
    );
    final dtos = response;
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
