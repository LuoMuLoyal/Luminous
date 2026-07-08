import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart' show MedicineDoseLogsApi;
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart';

void main() {
  group('DoseLogRemoteDataSource', () {
    late _FakeDoseLogAdapter adapter;
    late DoseLogRemoteDataSource dataSource;

    setUp(() {
      adapter = _FakeDoseLogAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
      dio.httpClientAdapter = adapter;
      dataSource = DoseLogRemoteDataSource(
        api: MedicineDoseLogsApi(dio),
        dio: dio,
      );
    });

    test(
      'mark posts slot-aware reminder identity to the mark endpoint',
      () async {
        final result = await dataSource.mark(
          currentMedicineId: 'med-1',
          reminderId: 'reminder-1',
          scheduledTime: '07:45',
          status: 'taken',
          date: '2026-06-08',
        );

        final request = adapter.requestAt(
          'POST',
          '/api/v1/user/medicine-dose-logs/mark',
        );
        expect(request.jsonBody, {
          'currentMedicineId': 'med-1',
          'reminderId': 'reminder-1',
          'status': 'taken',
          'scheduledFor': '2026-06-08',
          'scheduledTime': '07:45',
        });
        expect(
          adapter.requests.where(
            (captured) =>
                captured.path == '/api/v1/user/medicine-dose-logs' ||
                captured.path == '/api/v1/user/medicine-dose-logs/dose-1',
          ),
          isEmpty,
        );
        expect(result.reminderId, 'reminder-1');
        expect(result.scheduledTime, '07:45');
        expect(result.status, DoseLogStatus.taken);
      },
    );

    test(
      'mark omits slot identity when the plan has no reminder slot',
      () async {
        final result = await dataSource.mark(
          currentMedicineId: 'med-1',
          status: 'skipped',
          date: '2026-06-08',
        );

        final request = adapter.requestAt(
          'POST',
          '/api/v1/user/medicine-dose-logs/mark',
        );
        expect(request.jsonBody, {
          'currentMedicineId': 'med-1',
          'status': 'skipped',
          'scheduledFor': '2026-06-08',
        });
        expect(result.reminderId, isNull);
        expect(result.scheduledTime, isNull);
        expect(result.status, DoseLogStatus.skipped);
      },
    );
  });
}

class _FakeDoseLogAdapter implements HttpClientAdapter {
  final requests = <_CapturedDoseLogRequest>[];
  List<Map<String, Object?>> listItems = const <Map<String, Object?>>[];

  _CapturedDoseLogRequest requestAt(String method, String path) {
    return requests.singleWhere(
      (request) => request.method == method && request.path == path,
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bodyBytes = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        bodyBytes.addAll(chunk);
      }
    }

    requests.add(
      _CapturedDoseLogRequest(
        method: options.method,
        path: options.path,
        queryParameters: Map<String, Object?>.from(options.queryParameters),
        bodyBytes: bodyBytes,
      ),
    );

    if (options.method == 'GET') {
      return _jsonResponse(<String, Object?>{
        'code': 0,
        'message': '',
        'data': <String, Object?>{'items': listItems},
      });
    }

    final payload = requests.last.jsonBody;
    final currentMedicineId =
        payload['currentMedicineId'] as String? ??
        listItems.first['currentMedicineId'] as String?;
    return _jsonResponse(<String, Object?>{
      'code': 0,
      'message': '',
      'data': _doseJson(
        id: options.method == 'PATCH' ? 'dose-1' : 'dose-new',
        currentMedicineId: currentMedicineId,
        reminderId: payload['reminderId'] as String?,
        status: payload['status'] as String,
        scheduledFor: payload['scheduledFor'] as String? ?? '2026-06-08',
        scheduledTime: payload['scheduledTime'] as String?,
      ),
    });
  }

  @override
  void close({bool force = false}) {}

  ResponseBody _jsonResponse(Map<String, Object?> body) {
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: const <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }
}

class _CapturedDoseLogRequest {
  const _CapturedDoseLogRequest({
    required this.method,
    required this.path,
    required this.queryParameters,
    required this.bodyBytes,
  });

  final String method;
  final String path;
  final Map<String, Object?> queryParameters;
  final List<int> bodyBytes;

  Map<String, dynamic> get jsonBody {
    if (bodyBytes.isEmpty) return const <String, dynamic>{};
    return jsonDecode(utf8.decode(bodyBytes)) as Map<String, dynamic>;
  }
}

Map<String, Object?> _doseJson({
  required String id,
  required String? currentMedicineId,
  String? reminderId,
  required String status,
  required String scheduledFor,
  String? scheduledTime,
}) {
  return <String, Object?>{
    'id': id,
    'currentMedicineId': currentMedicineId,
    'reminderId': reminderId,
    'status': status,
    'scheduledFor': scheduledFor,
    'scheduledTime': scheduledTime,
    'doseText': null,
    'note': null,
    'createdAt': '2026-06-08T08:00:00.000Z',
    'updatedAt': '2026-06-08T08:00:00.000Z',
  };
}
