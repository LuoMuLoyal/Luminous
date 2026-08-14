import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/analytics/product_event_service.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/core/network/session_store.dart';
import 'package:luminous/features/report/presentation/providers/clinic_summary.dart';
import 'package:luminous/features/report/presentation/widgets/dialogs/clinic_summary_preview_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_forui_app.dart';
import '../helpers/test_helpers.dart';

class _MockReportsApi extends Mock implements ReportsApi {}

class _FakeLucentClient extends LucentClient {
  _FakeLucentClient({required this.reportsApi}) : super(LucentApi(dio: Dio()));

  final ReportsApi reportsApi;

  @override
  ReportsApi get reports => reportsApi;
}

ClinicSummaryCoverageEntryDto _coverageEntry() {
  return ClinicSummaryCoverageEntryDto(
    state: ClinicSummaryCoverageEntryDtoStateEnum.observed,
    coverage: ClinicSummaryCoverageEntryDtoCoverageEnum.none,
    sources: const [ClinicSummaryCoverageEntryDtoSourcesEnum.manual],
    observedCount: 0,
    expectedCount: null,
    windowStart: null,
    windowEnd: null,
  );
}

ClinicSummaryCoverageDto _coverage() {
  return ClinicSummaryCoverageDto(
    checkIns: _coverageEntry(),
    water: _coverageEntry(),
    dose: _coverageEntry(),
    sleep: _coverageEntry(),
  );
}

ClinicSummaryDto _dto({List<String>? findings}) {
  return ClinicSummaryDto(
    generatedAt: '2026-07-01T10:30:00',
    scopeLabel: 'last_7_days',
    start: '2026-06-24T00:00:00',
    end: '2026-07-01T00:00:00',
    selectedFields: const [],
    coverage: _coverage(),
    dataRange: 'last_7_days',
    profile: ClinicSummaryProfileDto(
      nickname: 'Lumi',
      age: 30,
      sexAtBirth: 'male',
      bloodType: 'A',
    ),
    allergies: const ['青霉素'],
    conditions: const ['高血压'],
    currentMedicines: const ['阿莫西林'],
    findings: findings,
    disclaimer: '本摘要仅供参考',
  );
}

void main() {
  late _MockReportsApi reportsApi;
  late _FakeLucentClient client;

  setUpAll(() {
    registerFallbackValue(ClinicSummaryRequestDto());
  });

  setUp(() {
    reportsApi = _MockReportsApi();
    client = _FakeLucentClient(reportsApi: reportsApi);
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        lucentClientProvider.overrideWithValue(client),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('clinicSummaryPreviewProvider', () {
    test('returns the clinic summary for authenticated users', () async {
      when(
        () => reportsApi.reportsControllerPreviewClinicSummaryV1(
          clinicSummaryRequestDto: any(named: 'clinicSummaryRequestDto'),
        ),
      ).thenAnswer(
        (_) async => Response<ClinicSummaryDto>(
          data: _dto(),
          requestOptions: RequestOptions(path: '/preview'),
          statusCode: 200,
        ),
      );

      final c = makeContainer();
      final dto = await c.read(clinicSummaryPreviewProvider.future);

      expect(dto.profile.nickname, 'Lumi');
      expect(dto.allergies, ['青霉素']);
      expect(dto.disclaimer, '本摘要仅供参考');
      verify(
        () => reportsApi.reportsControllerPreviewClinicSummaryV1(
          clinicSummaryRequestDto: any(named: 'clinicSummaryRequestDto'),
        ),
      ).called(1);
    });

    test('propagates API errors', () async {
      when(
        () => reportsApi.reportsControllerPreviewClinicSummaryV1(
          clinicSummaryRequestDto: any(named: 'clinicSummaryRequestDto'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/preview'),
          type: DioExceptionType.connectionError,
        ),
      );

      final c = makeContainer();
      // Keep the autoDispose provider alive while the error propagates.
      final sub = c.listen<AsyncValue<ClinicSummaryDto>>(
        clinicSummaryPreviewProvider,
        (_, __) {},
      );
      addTearDown(sub.close);

      await expectLater(
        c.read(clinicSummaryPreviewProvider.future),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('clinicSummarySharedProvider', () {
    test('fetches a shared summary by token', () async {
      when(
        () => reportsApi.reportsControllerGetSharedClinicSummaryV1(
          token: 'abc123',
        ),
      ).thenAnswer(
        (_) async => Response<ClinicSummaryDto>(
          data: _dto(findings: const ['发现一条']),
          requestOptions: RequestOptions(path: '/shared'),
          statusCode: 200,
        ),
      );

      final c = ProviderContainer(
        overrides: [lucentClientProvider.overrideWithValue(client)],
      );
      addTearDown(c.dispose);

      final dto = await c.read(clinicSummarySharedProvider('abc123').future);

      expect(dto.dataRange, 'last_7_days');
      expect(dto.findings, ['发现一条']);
      verify(
        () => reportsApi.reportsControllerGetSharedClinicSummaryV1(
          token: 'abc123',
        ),
      ).called(1);
    });

    test('is per-token cached', () async {
      when(
        () => reportsApi.reportsControllerGetSharedClinicSummaryV1(
          token: any(named: 'token'),
        ),
      ).thenAnswer(
        (_) async => Response<ClinicSummaryDto>(
          data: _dto(),
          requestOptions: RequestOptions(path: '/shared'),
          statusCode: 200,
        ),
      );

      final c = ProviderContainer(
        overrides: [lucentClientProvider.overrideWithValue(client)],
      );
      addTearDown(c.dispose);

      await c.read(clinicSummarySharedProvider('a').future);
      await c.read(clinicSummarySharedProvider('b').future);

      verify(
        () => reportsApi.reportsControllerGetSharedClinicSummaryV1(token: 'a'),
      ).called(1);
      verify(
        () => reportsApi.reportsControllerGetSharedClinicSummaryV1(token: 'b'),
      ).called(1);
    });
  });

  // ── Preview dialog measurement ─────────────────────────────────────────

  group('clinic summary preview dialog measurement', () {
    Future<void> openDialog(
      WidgetTester tester, {
      required _FakeLucentClient client,
      required _RecordingProductEventService service,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
            lucentClientProvider.overrideWithValue(client),
            productEventServiceProvider.overrideWithValue(service),
          ],
          child: TestForuiApp(
            locale: const Locale('zh'),
            home: Builder(
              builder: (context) => Center(
                child: FButton(
                  onPress: () => showClinicSummaryPreviewDialog(context),
                  child: const Text('open preview'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open preview'));
      await tester.pumpAndSettle();
    }

    testWidgets('records previewed success after the server responds', (
      tester,
    ) async {
      when(
        () => reportsApi.reportsControllerPreviewClinicSummaryV1(
          clinicSummaryRequestDto: any(named: 'clinicSummaryRequestDto'),
        ),
      ).thenAnswer(
        (_) async => Response<ClinicSummaryDto>(
          data: _dto(),
          requestOptions: RequestOptions(path: '/preview'),
          statusCode: 200,
        ),
      );
      final service = _RecordingProductEventService();

      await openDialog(tester, client: client, service: service);

      expect(service.previewResults, [ProductEventResult.success]);
      expect(service.exportResults, isEmpty);
      // The preview content is actually presented.
      expect(find.text('本摘要仅供参考'), findsOneWidget);
    });

    testWidgets('records previewed failure when the preview request fails', (
      tester,
    ) async {
      when(
        () => reportsApi.reportsControllerPreviewClinicSummaryV1(
          clinicSummaryRequestDto: any(named: 'clinicSummaryRequestDto'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/preview'),
          type: DioExceptionType.connectionError,
        ),
      );
      final service = _RecordingProductEventService();

      await openDialog(tester, client: client, service: service);

      expect(service.previewResults, [ProductEventResult.failure]);
      expect(service.exportResults, isEmpty);
    });

    testWidgets('records exported failure when the PDF download fails', (
      tester,
    ) async {
      when(
        () => reportsApi.reportsControllerPreviewClinicSummaryV1(
          clinicSummaryRequestDto: any(named: 'clinicSummaryRequestDto'),
        ),
      ).thenAnswer(
        (_) async => Response<ClinicSummaryDto>(
          data: _dto(),
          requestOptions: RequestOptions(path: '/preview'),
          statusCode: 200,
        ),
      );
      final service = _RecordingProductEventService();

      // The dialog downloads the PDF through lucentDioClientProvider's Dio —
      // override it with a client whose adapter fails immediately (real
      // network is unavailable in widget tests).
      final failingDio = LucentDioClient(
        baseUrl: 'http://localhost',
        sessionStore: _MemSessionStore(),
        httpClientAdapter: _FailingAdapter(),
      );
      addTearDown(failingDio.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
            lucentClientProvider.overrideWithValue(client),
            lucentDioClientProvider.overrideWithValue(failingDio),
            productEventServiceProvider.overrideWithValue(service),
          ],
          child: TestForuiApp(
            locale: const Locale('zh'),
            home: Builder(
              builder: (context) => Center(
                child: FButton(
                  onPress: () => showClinicSummaryPreviewDialog(context),
                  child: const Text('open preview'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open preview'));
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final pdfButton = find.text(l10n.reportClinicSummaryDownloadPdf);
      await tester.ensureVisible(pdfButton);
      await tester.pumpAndSettle();
      await tester.tap(pdfButton);
      await tester.pumpAndSettle();

      expect(service.previewResults, [ProductEventResult.success]);
      expect(service.exportResults, [ProductEventResult.failure]);
    });
  });
}

/// Adapter that fails every request with a connection error.
class _FailingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
    );
  }

  @override
  void close({bool force = false}) {}
}

class _MemSessionStore implements LucentSessionStore {
  @override
  Future<LucentSessionTokens?> read() async => null;

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> write(LucentSessionTokens tokens) async {}

  @override
  Future<void> clear() async {}
}

/// Records preview/export results instead of posting events.
class _RecordingProductEventService extends ProductEventService {
  _RecordingProductEventService() : super(api: _MockProductEventsApi());

  final List<ProductEventResult> previewResults = [];
  final List<ProductEventResult> exportResults = [];

  @override
  Future<void> trackVisitSummaryPreviewed(ProductEventResult result) async {
    previewResults.add(result);
  }

  @override
  Future<void> trackVisitSummaryExported(ProductEventResult result) async {
    exportResults.add(result);
  }
}

class _MockProductEventsApi extends Mock implements ProductEventsApi {}
