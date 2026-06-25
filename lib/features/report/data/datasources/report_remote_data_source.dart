import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';

class ReportRemoteDataSource {
  ReportRemoteDataSource({required this.api, required this.dio});

  final lucent.ReportsApi api;
  final Dio dio;

  static final _dateOnlyFormat = DateFormat('yyyy-MM-dd');

  Future<lucent.ReportDashboardDataDto> fetchDashboard(
    ReportDashboardQuery query,
  ) async {
    final response = await api.reportsControllerGetDashboardV1(
      range: query.range.apiValue,
      startDate: query.isCustom
          ? _dateOnlyFormat.format(query.startDate!)
          : null,
      endDate: query.isCustom ? _dateOnlyFormat.format(query.endDate!) : null,
    );
    return response.data!.data;
  }
}
