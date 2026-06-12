import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/features/report/data/datasources/report_remote_data_source.dart';

void main() {
  group('ReportRemoteDataSource', () {
    late _FakeReportAdapter adapter;
    late ReportRemoteDataSource dataSource;

    setUp(() {
      adapter = _FakeReportAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
      dio.httpClientAdapter = adapter;
      dataSource = ReportRemoteDataSource(
        api: lucent.ReportsApi(dio),
        dio: dio,
      );
    });

    test(
      'fetchDashboard requests dashboard endpoint and unwraps envelope',
      () async {
        final dashboard = await dataSource.fetchDashboard();

        final request = adapter.requestAt(
          'GET',
          '/api/v1/user/reports/dashboard',
        );
        expect(request.queryParameters, containsPair('range', 'last_7_days'));
        expect(
          dashboard.range,
          lucent.ReportDashboardDataDtoRangeEnum.last7Days,
        );
        expect(dashboard.startDate, '2026-06-06');
        expect(dashboard.endDate, '2026-06-12');
        expect(dashboard.aiSummaryEnabled, isTrue);
        expect(
          dashboard.metrics.single.kind,
          lucent.ReportMetricDtoKindEnum.water,
        );
        expect(dashboard.trends.single.currentValue, '1.8L');
        expect(dashboard.findings.single.title, '饮水改善');
        expect(dashboard.patterns.single.title, '饮水正在回升');
      },
    );
  });
}

class _FakeReportAdapter implements HttpClientAdapter {
  final requests = <_CapturedReportRequest>[];

  _CapturedReportRequest requestAt(String method, String path) {
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
    requests.add(
      _CapturedReportRequest(
        method: options.method,
        path: options.path,
        queryParameters: Map<String, Object?>.from(options.queryParameters),
      ),
    );

    return ResponseBody.fromString(
      jsonEncode(<String, Object?>{
        'code': 0,
        'message': '',
        'data': <String, Object?>{
          'range': 'last_7_days',
          'startDate': '2026-06-06',
          'endDate': '2026-06-12',
          'generatedAt': '2026-06-12T10:00:00.000Z',
          'score': <String, Object?>{
            'value': 82,
            'maxValue': 100,
            'status': 'good',
            'summary': '本周饮水和用药执行整体稳定。',
          },
          'metrics': <Object?>[
            <String, Object?>{
              'kind': 'water',
              'value': '1.8',
              'unit': 'L',
              'status': 'good',
              'delta': '+0.4L',
              'direction': 'up',
              'sparkline': <num>[1.2, 1.5, 1.7, 1.6, 1.8, 1.9, 1.8],
            },
          ],
          'trends': <Object?>[
            <String, Object?>{
              'kind': 'water',
              'unit': 'L',
              'currentValue': '1.8L',
              'values': <num>[1.2, 1.5, 1.7, 1.6, 1.8, 1.9, 1.8],
            },
          ],
          'findings': <Object?>[
            <String, Object?>{
              'kind': 'hydration',
              'title': '饮水改善',
              'body': '最近 7 天饮水量较前期更稳定。',
            },
          ],
          'patterns': <Object?>[
            <String, Object?>{
              'kind': 'hydration',
              'title': '饮水正在回升',
              'status': 'good',
              'body': '工作日下午的补水频率更稳定。',
              'sparkline': <num>[30, 34, 38, 36, 42, 44, 43],
            },
          ],
          'aiSummaryEnabled': true,
        },
      }),
      200,
      headers: const <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _CapturedReportRequest {
  const _CapturedReportRequest({
    required this.method,
    required this.path,
    required this.queryParameters,
  });

  final String method;
  final String path;
  final Map<String, Object?> queryParameters;
}
