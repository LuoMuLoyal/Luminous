import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';

class ReviewDashboardRemoteDataSource {
  ReviewDashboardRemoteDataSource({required this.api, required this.dio});

  final lucent.ReportsApi api;
  final Dio dio;

  static final _dateOnlyFormat = DateFormat('yyyy-MM-dd');

  Future<lucent.ReportDashboardResponse> fetchDashboard(
    ReviewDashboardQuery query,
  ) async {
    final response = await api.getDashboard(
      range: query.range.apiValue,
      startDate: query.isCustom
          ? _dateOnlyFormat.format(query.startDate!)
          : null,
      endDate: query.isCustom ? _dateOnlyFormat.format(query.endDate!) : null,
    );
    return _requireData(response.data, operation: 'fetchDashboard');
  }

  /// Extracts a non-null generated-client payload, throwing
  /// [LucentFailure.network] (emptyResponse) when the success body is absent
  /// (settings / notification `_requireData` precedent).
  T _requireData<T>(T? data, {String? operation}) {
    if (data == null) {
      final context = operation != null ? ' ($operation)' : '';
      throw LucentFailure.network(
        message: 'Empty response body$context',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return data;
  }
}
