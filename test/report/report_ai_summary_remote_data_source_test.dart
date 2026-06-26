import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/features/report/data/datasources/report_ai_summary_remote_data_source.dart';
import 'package:luminous/features/report/domain/entities/report_ai_summary.dart';

void main() {
  late _FakeReportsAdapter adapter;
  late ReportAiSummaryRemoteDataSource dataSource;

  setUp(() {
    adapter = _FakeReportsAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    dio.httpClientAdapter = adapter;
    dataSource = ReportAiSummaryRemoteDataSource(
      api: lucent.ReportsApi(dio),
      dio: dio,
    );
  });

  test('generate sends POST to summary/generate endpoint', () async {
    final result = await dataSource.generate(ReportAiSummaryRange.last30Days);

    final req = adapter.lastRequest!;
    expect(req.method, 'POST');
    expect(req.path, '/api/v1/user/reports/summary/generate');

    // Request body should be a valid GenerateReportSummaryDto JSON.
    final body = req.jsonBody;
    expect(body, isA<Map<String, dynamic>>());
    expect(body['range'], 'last_30_days');

    // Response should deserialize correctly.
    expect(result.summary, '本周用药记录整体稳定。');
    expect(result.bullets, hasLength(1));
    expect(result.bullets.first.text, '用药记录良好。');
  });

  test('generate propagates DioException on network failure', () async {
    adapter.failNext = true;

    expect(
      () => dataSource.generate(ReportAiSummaryRange.last7Days),
      throwsA(isA<DioException>()),
    );
  });

  test('generate throws on empty response', () async {
    adapter.emptyResponse = true;

    expect(
      () => dataSource.generate(ReportAiSummaryRange.last7Days),
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.badResponse,
        ),
      ),
    );
  });
}

// ---------------------------------------------------------------------------
// Fake adapter
// ---------------------------------------------------------------------------

class _FakeReportsAdapter implements HttpClientAdapter {
  _CapturedRequest? lastRequest;
  bool failNext = false;
  bool emptyResponse = false;

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

    lastRequest = _CapturedRequest(
      method: options.method,
      path: options.path,
      bodyBytes: bodyBytes,
    );

    if (failNext) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionTimeout,
      );
    }

    if (emptyResponse) {
      return ResponseBody.fromString('', 200);
    }

    return _jsonResponse(<String, Object?>{
      'code': 0,
      'message': 'ok',
      'data': <String, Object?>{
        'range': 'last_30_days',
        'startDate': '2026-05-14',
        'endDate': '2026-06-12',
        'generatedAt': '2026-06-12T10:00:00.000Z',
        'summary': '本周用药记录整体稳定。',
        'bullets': [
          <String, Object?>{'kind': 'medication', 'text': '用药记录良好。'},
        ],
        'actionLabel': '查看报告',
        'action': 'today',
        'confidenceNote': '仅基于近 7 天已记录数据生成。',
      },
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

class _CapturedRequest {
  const _CapturedRequest({
    required this.method,
    required this.path,
    required this.bodyBytes,
  });

  final String method;
  final String path;
  final List<int> bodyBytes;

  Map<String, dynamic> get jsonBody {
    if (bodyBytes.isEmpty) return const <String, dynamic>{};
    return jsonDecode(utf8.decode(bodyBytes)) as Map<String, dynamic>;
  }
}
