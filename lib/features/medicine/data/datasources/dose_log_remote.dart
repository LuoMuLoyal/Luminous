import 'package:dio/dio.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/features/medicine/domain/entities/dose_log.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:luminous/features/medicine/domain/entities/dose_log.dart'
    show DoseLogItem, DoseLogStatus;

part 'dose_log_remote.g.dart';

/// Remote data source for medicine dose logs.
///
/// Transport only: returns plain `Future` and throws `DioException` /
/// `LucentFailure`; the repository boundary (`CachedDoseLogDataSource`)
/// maps every failure via `LucentErrorMapper.fromObject`. An empty success
/// body is a `LucentFailure.network(emptyResponse)` (reminder `_responseData`
/// / today `ai_remote` precedent — never a transport `FormatException`); a
/// structurally malformed body is a thrown protocol exception (logged via
/// [appTalker] for diagnosability) that surfaces as a `Left(unknown)` at the
/// repository boundary.
class DoseLogRemoteDataSource {
  DoseLogRemoteDataSource({required this.api, required this.dio});
  final MedicineDoseLogsApi api;
  final Dio dio;

  Future<List<DoseLogItem>> fetchForDate(String date) async {
    final response = await dio.get<Object>(
      LucentApiPaths.medicineDoseLogs,
      queryParameters: {'date': date},
    );
    final data = _requireData(response);
    final items = data['items'];
    if (items is! List) {
      appTalker.error(
        'DoseLogRemoteDataSource.fetchForDate: items is not a list: $items',
      );
      throw const FormatException('Dose log list items is not a list');
    }
    return items
        .map<DoseLogItem>((d) => _fromJson(_requireItemMap(d)))
        .toList();
  }

  Future<DoseLogItem> create(
    String currentMedicineId,
    String status,
    String date,
  ) async {
    final payload = <String, dynamic>{
      'currentMedicineId': currentMedicineId,
      'status': status,
      'scheduledFor': date,
    };
    final response = await dio.request<Object>(
      LucentApiPaths.medicineDoseLogs,
      data: payload,
      options: Options(method: 'POST', contentType: Headers.jsonContentType),
    );
    return _fromJson(_requireData(response));
  }

  Future<DoseLogItem> update(String doseLogId, String status) async {
    final response = await dio.request<Object>(
      LucentApiPaths.medicineDoseLog(doseLogId),
      data: <String, dynamic>{'status': status},
      options: Options(method: 'PATCH', contentType: Headers.jsonContentType),
    );
    return _fromJson(_requireData(response));
  }

  Future<void> delete(String doseLogId) async {
    await dio.request<Object>(
      LucentApiPaths.medicineDoseLog(doseLogId),
      options: Options(method: 'DELETE'),
    );
  }

  Future<DoseLogItem> mark({
    required String currentMedicineId,
    required String status,
    required String date,
    String? reminderId,
    String? scheduledTime,
  }) async {
    final payload = <String, dynamic>{
      'currentMedicineId': currentMedicineId,
      if (_hasText(reminderId)) 'reminderId': reminderId,
      'status': status,
      'scheduledFor': date,
      if (_hasText(scheduledTime)) 'scheduledTime': scheduledTime,
    };
    final response = await dio.request<Object>(
      LucentApiPaths.medicineDoseLogsMark,
      data: payload,
      options: Options(method: 'POST', contentType: Headers.jsonContentType),
    );
    return _fromJson(_requireData(response));
  }

  DoseLogStatus _parseStatus(String s) => DoseLogStatus.values.firstWhere(
    (e) => e.name == s,
    orElse: () => DoseLogStatus.planned,
  );

  DoseLogItem _fromJson(Map<String, dynamic> json) {
    return DoseLogItem(
      id: json['id'] as String,
      currentMedicineId: _optionalString(json['currentMedicineId']),
      reminderId: _optionalString(json['reminderId']),
      status: _parseStatus(json['status'] as String),
      scheduledFor: json['scheduledFor'] as String,
      scheduledTime: _optionalString(json['scheduledTime']),
      doseText: _optionalString(json['doseText']),
      note: _optionalString(json['note']),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  /// Extracts the direct resource body as a [Map<String, dynamic>], throwing
  /// [LucentFailure.network] if the body is missing or not a map.
  Map<String, dynamic> _requireData(Response<dynamic> response) {
    final data = coerceToStringMap(response.data);
    if (data == null) {
      throw LucentFailure.network(
        message: 'Empty dose log response body',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return data;
  }

  /// Coerces a list item into a [Map<String, dynamic>], throwing a protocol
  /// exception if the item is not a map.
  Map<String, dynamic> _requireItemMap(Object? item) {
    final map = coerceToStringMap(item);
    if (map == null) {
      appTalker.error(
        'DoseLogRemoteDataSource._requireItemMap: item is not a map: $item',
      );
      throw const FormatException('Dose log item is not a map');
    }
    return map;
  }

  String? _optionalString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
}

@riverpod
DoseLogRemoteDataSource doseLogRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).medicineDoseLogs;
  final dio = ref.watch(lucentDioClientProvider).dio;
  return DoseLogRemoteDataSource(api: api, dio: dio);
}
