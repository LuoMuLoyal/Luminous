import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/database/daos/review_dashboard_dao.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/features/review/data/datasources/dashboard_remote.dart';
import 'package:luminous/features/review/data/repositories/lucent_dashboard.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';

import '../helpers/task_either.dart';

void main() {
  test(
    'Lucent report repository maps insufficient sleep data into domain state',
    () async {
      final repository = LucentReviewDashboardRepository(
        dao: _FakeReviewDashboardDao(),
        dataSource: _FakeReviewDashboardRemoteDataSource(
          _dashboardDto(
            aiSummaryEnabled: false,
            findings: [
              lucent.ReportFindingDto(
                kind: lucent.ReportFindingDtoKindEnum.sleep,
                title: '睡眠数据不足',
                body: '最近 7 天还没有睡眠记录。',
              ),
            ],
            metrics: [
              lucent.ReportMetricDto(
                kind: lucent.ReportMetricDtoKindEnum.sleep,
                value: '--',
                unit: 'h',
                status: lucent.ReportMetricDtoStatusEnum.insufficientData,
                delta: '--',
                direction: lucent.ReportMetricDtoDirectionEnum.flat,
                sparkline: [0, 0, 0, 0, 0, 0, 0],
              ),
            ],
            patterns: [
              lucent.ReportPatternDto(
                kind: lucent.ReportPatternDtoKindEnum.sleep,
                title: '等待睡眠数据',
                status: lucent.ReportPatternDtoStatusEnum.insufficientData,
                body: '补齐睡眠合同后再输出睡眠模式。',
                sparkline: [0, 0, 0, 0, 0, 0, 0],
              ),
            ],
            trends: [
              lucent.ReportTrendDto(
                kind: lucent.ReportTrendDtoKindEnum.sleep,
                unit: 'h',
                currentValue: '--',
                values: [0, 0, 0, 0, 0, 0, 0],
              ),
            ],
          ),
        ),
      );

      final dashboard = await expectTaskRight(
        repository.fetchDashboard(
          const ReviewDashboardQuery(range: ReviewDashboardRange.last7Days),
        ),
      );

      expect(dashboard.metrics.single.kind, ReviewDataKind.sleep);
      expect(dashboard.metrics.single.status, ReviewStatus.insufficientData);
      expect(dashboard.metrics.single.direction, ReviewMetricDirection.flat);
      expect(dashboard.trends.single.kind, ReviewDataKind.sleep);
      expect(dashboard.trends.single.currentValue, '--');
      expect(dashboard.findings.single.kind, ReviewInsightKind.sleep);
      expect(dashboard.patterns.single.status, ReviewStatus.insufficientData);
      expect(dashboard.aiSummaryEnabled, isFalse);
    },
  );

  test(
    'Lucent report repository uses ai summary mode and truncates summary findings',
    () async {
      final repository = LucentReviewDashboardRepository(
        dao: _FakeReviewDashboardDao(),
        dataSource: _FakeReviewDashboardRemoteDataSource(
          _dashboardDto(
            aiSummaryEnabled: true,
            findings: [
              for (var index = 1; index <= 4; index += 1)
                lucent.ReportFindingDto(
                  kind: lucent.ReportFindingDtoKindEnum.hydration,
                  title: '发现$index',
                  body: '正文$index',
                ),
            ],
            metrics: [
              lucent.ReportMetricDto(
                kind: lucent.ReportMetricDtoKindEnum.medication,
                value: '93',
                unit: '%',
                status: lucent.ReportMetricDtoStatusEnum.good,
                delta: '9%',
                direction: lucent.ReportMetricDtoDirectionEnum.up,
                sparkline: [80, 88, 92, 89, 93, 88, 93],
              ),
            ],
            patterns: [
              lucent.ReportPatternDto(
                kind: lucent.ReportPatternDtoKindEnum.medication,
                title: '用药依从性稳定',
                status: lucent.ReportPatternDtoStatusEnum.good,
                body: '近 7 天按计划完成率较高。',
                sparkline: [48, 50, 47, 52, 49, 51, 58],
              ),
            ],
            trends: [
              lucent.ReportTrendDto(
                kind: lucent.ReportTrendDtoKindEnum.medication,
                unit: '%',
                currentValue: '93%',
                values: [80, 88, 92, 89, 93, 88, 93],
              ),
            ],
          ),
        ),
      );

      final dashboard = await expectTaskRight(
        repository.fetchDashboard(
          const ReviewDashboardQuery(range: ReviewDashboardRange.last7Days),
        ),
      );

      expect(dashboard.aiSummaryEnabled, isTrue);
      expect(
        dashboard.exportActions.map((action) => action.kind).toList(),
        const [
          ReviewExportKind.hospital,
          ReviewExportKind.monthly,
          ReviewExportKind.print,
          ReviewExportKind.clinicShare,
        ],
      );
      expect(dashboard.metrics.single.status, ReviewStatus.good);
      expect(dashboard.metrics.single.direction, ReviewMetricDirection.up);
      expect(dashboard.patterns.single.kind, ReviewInsightKind.medication);
    },
  );

  test('Lucent report repository prefers generated observed metric', () async {
    final repository = LucentReviewDashboardRepository(
      dao: _FakeReviewDashboardDao(),
      dataSource: _FakeReviewDashboardRemoteDataSource(
        _dashboardDto(
          aiSummaryEnabled: false,
          findings: const [],
          patterns: const [],
          trends: const [],
          metrics: [
            lucent.ReportMetricDto(
              kind: lucent.ReportMetricDtoKindEnum.water,
              value: '999',
              unit: 'ml',
              status: lucent.ReportMetricDtoStatusEnum.good,
              delta: '999',
              direction: lucent.ReportMetricDtoDirectionEnum.up,
              sparkline: [999],
              observedMetric: lucent.ReportObservedMetricDto(
                value: 0,
                state: lucent.ReportObservedMetricDtoStateEnum.observed,
                coverage: lucent.ReportObservedMetricDtoCoverageEnum.sufficient,
                sources: [lucent.ReportObservedMetricDtoSourcesEnum.manual],
                observedCount: 1,
                expectedCount: null,
                windowStart: '2026-08-05',
                windowEnd: '2026-08-11',
              ),
            ),
          ],
        ),
      ),
    );

    final dashboard = await expectTaskRight(
      repository.fetchDashboard(
        const ReviewDashboardQuery(range: ReviewDashboardRange.last7Days),
      ),
    );

    final metric = dashboard.metrics.single;
    expect(metric.value, '999');
    expect(metric.observedMetric?.value, 0);
    expect(
      metric.observedMetric?.coverage,
      ReviewObservedMetricCoverage.sufficient,
    );
  });

  test(
    'Lucent report repository keeps scalar fallback when observed metric is absent',
    () async {
      final repository = LucentReviewDashboardRepository(
        dao: _FakeReviewDashboardDao(),
        dataSource: _FakeReviewDashboardRemoteDataSource(
          _dashboardDto(
            aiSummaryEnabled: false,
            findings: const [],
            patterns: const [],
            trends: const [],
            metrics: [
              lucent.ReportMetricDto(
                kind: lucent.ReportMetricDtoKindEnum.water,
                value: '500',
                unit: 'ml',
                status: lucent.ReportMetricDtoStatusEnum.good,
                delta: '10%',
                direction: lucent.ReportMetricDtoDirectionEnum.up,
                sparkline: [500],
              ),
            ],
          ),
        ),
      );

      final dashboard = await expectTaskRight(
        repository.fetchDashboard(
          const ReviewDashboardQuery(range: ReviewDashboardRange.last7Days),
        ),
      );

      expect(dashboard.metrics.single.value, '500');
      expect(dashboard.metrics.single.observedMetric, isNull);
    },
  );

  group('LucentReviewDashboardRepository – failure branches', () {
    const query = ReviewDashboardQuery(range: ReviewDashboardRange.last7Days);

    test('network failure maps to Left(network)', () async {
      final repository = LucentReviewDashboardRepository(
        dao: _FakeReviewDashboardDao(),
        dataSource: _FakeReviewDashboardRemoteDataSource(
          _dashboardDto(
            aiSummaryEnabled: false,
            metrics: const [],
            trends: const [],
            findings: const [],
            patterns: const [],
          ),
          error: DioException(
            requestOptions: RequestOptions(
              path: '/api/v1/user/reports/dashboard',
            ),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
      );

      final failure = await expectTaskLeft(repository.fetchDashboard(query));
      expect(failure.kind, LucentFailureKind.network);
      expect(failure.networkErrorCode, NetworkErrorCode.connectionTimeout);
    });

    test(
      'server business failure keeps Problem Details code and status',
      () async {
        final repository = LucentReviewDashboardRepository(
          dao: _FakeReviewDashboardDao(),
          dataSource: _FakeReviewDashboardRemoteDataSource(
            _dashboardDto(
              aiSummaryEnabled: false,
              metrics: const [],
              trends: const [],
              findings: const [],
              patterns: const [],
            ),
            error: DioException(
              requestOptions: RequestOptions(
                path: '/api/v1/user/reports/dashboard',
              ),
              response: Response(
                requestOptions: RequestOptions(
                  path: '/api/v1/user/reports/dashboard',
                ),
                statusCode: 404,
                headers: Headers.fromMap({
                  Headers.contentTypeHeader: ['application/problem+json'],
                }),
                data: <String, Object?>{
                  'type': 'about:blank',
                  'title': 'Not Found',
                  'status': 404,
                  'detail': '报告不存在',
                  'code': 'REPORT_NOT_FOUND',
                },
              ),
              type: DioExceptionType.badResponse,
            ),
          ),
        );

        final failure = await expectTaskLeft(repository.fetchDashboard(query));
        expect(failure.code, 'REPORT_NOT_FOUND');
        expect(failure.statusCode, 404);
        expect(failure.kind, LucentFailureKind.business);
      },
    );

    test(
      'empty success response body maps to Left(network/emptyResponse)',
      () async {
        final repository = LucentReviewDashboardRepository(
          dao: _FakeReviewDashboardDao(),
          dataSource: _FakeReviewDashboardRemoteDataSource(
            _dashboardDto(
              aiSummaryEnabled: false,
              metrics: const [],
              trends: const [],
              findings: const [],
              patterns: const [],
            ),
            error: LucentFailure.network(
              message: 'API 返回空响应体（fetchDashboard）',
              networkErrorCode: NetworkErrorCode.emptyResponse,
            ),
          ),
        );

        final failure = await expectTaskLeft(repository.fetchDashboard(query));
        expect(failure.kind, LucentFailureKind.network);
        expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
      },
    );

    test(
      'non problem+json error body keeps FormatException from .run()',
      () async {
        final repository = LucentReviewDashboardRepository(
          dao: _FakeReviewDashboardDao(),
          dataSource: _FakeReviewDashboardRemoteDataSource(
            _dashboardDto(
              aiSummaryEnabled: false,
              metrics: const [],
              trends: const [],
              findings: const [],
              patterns: const [],
            ),
            error: DioException(
              requestOptions: RequestOptions(
                path: '/api/v1/user/reports/dashboard',
              ),
              response: Response(
                requestOptions: RequestOptions(
                  path: '/api/v1/user/reports/dashboard',
                ),
                statusCode: 500,
                headers: Headers.fromMap({
                  Headers.contentTypeHeader: ['text/html'],
                }),
                data: '<html>oops</html>',
              ),
              type: DioExceptionType.badResponse,
            ),
          ),
        );

        await expectLater(
          repository.fetchDashboard(query).run(),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'unexpected exception maps to Left(unknown) with cause preserved',
      () async {
        final repository = LucentReviewDashboardRepository(
          dao: _FakeReviewDashboardDao(),
          dataSource: _FakeReviewDashboardRemoteDataSource(
            _dashboardDto(
              aiSummaryEnabled: false,
              metrics: const [],
              trends: const [],
              findings: const [],
              patterns: const [],
            ),
            error: StateError('boom'),
          ),
        );

        final failure = await expectTaskLeft(repository.fetchDashboard(query));
        expect(failure.kind, LucentFailureKind.unknown);
        expect(failure.cause, isA<StateError>());
      },
    );
  });
}

class _FakeReviewDashboardDao implements ReviewDashboardDao {
  @override
  Future<String?> fetch(String cacheKey) async => null;

  @override
  Future<void> replace(String cacheKey, String jsonData) async {}

  @override
  Future<void> clear() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeReviewDashboardRemoteDataSource
    extends ReviewDashboardRemoteDataSource {
  _FakeReviewDashboardRemoteDataSource(this._dto, {this.error})
    : super(
        api: lucent.ReportsApi(Dio(BaseOptions())),
        dio: Dio(BaseOptions()),
      );

  final lucent.ReportDashboardResponseDto _dto;
  Object? error;

  @override
  Future<lucent.ReportDashboardResponseDto> fetchDashboard(
    ReviewDashboardQuery query,
  ) async {
    if (error != null) {
      // ignore: only_throw_errors
      throw error!;
    }
    return _dto;
  }
}

lucent.ReportDashboardResponseDto _dashboardDto({
  required bool aiSummaryEnabled,
  required List<lucent.ReportMetricDto> metrics,
  required List<lucent.ReportTrendDto> trends,
  required List<lucent.ReportFindingDto> findings,
  required List<lucent.ReportPatternDto> patterns,
}) {
  return lucent.ReportDashboardResponseDto(
    range: lucent.ReportDashboardResponseDtoRangeEnum.last7Days,
    startDate: '2026-06-06',
    endDate: '2026-06-12',
    generatedAt: '2026-06-12T10:00:00.000Z',
    metrics: metrics,
    trends: trends,
    findings: findings,
    patterns: patterns,
    aiSummaryEnabled: aiSummaryEnabled,
  );
}
