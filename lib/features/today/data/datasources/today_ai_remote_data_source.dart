import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;

class TodayAiRemoteDataSource {
  TodayAiRemoteDataSource({required this.api, required this.dio});

  final lucent.TodayAnalysisApi api;
  final Dio dio;

  Future<lucent.TodayAnalysisDataDto> generate({String? date}) async {
    final response = await api.todayAnalysisControllerGenerateV1(
      generateTodayAnalysisDto: lucent.GenerateTodayAnalysisDto(date: date),
    );
    return response.data!.data;
  }
}
