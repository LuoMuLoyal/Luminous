import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Scripted HTTP adapter: responds per (method, path) handler, recording the
/// outgoing request options so tests can assert request bodies.
class _ScriptedAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final Map<String, Future<ResponseBody> Function(RequestOptions)> handlers =
      {};

  void on(
    String method,
    String path,
    Future<ResponseBody> Function(RequestOptions) handler,
  ) {
    handlers['$method $path'] = handler;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    requests.add(options);
    final handler = handlers['${options.method} ${options.path}'];
    if (handler == null) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        error: StateError(
          'no scripted handler for ${options.method} ${options.path}',
        ),
      );
    }
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _requestBody(RequestOptions options) {
  final data = options.data;
  return data is String
      ? jsonDecode(data) as Map<String, dynamic>
      : (data as Map).cast<String, dynamic>();
}

ResponseBody _jsonBody(Map<String, dynamic> envelope) {
  return ResponseBody.fromString(
    const JsonEncoder().convert(envelope),
    200,
    headers: {
      'content-type': ['application/json; charset=utf-8'],
    },
  );
}

Map<String, dynamic> _envelope(Object? data) {
  return {'code': 0, 'message': '', 'data': data};
}

Map<String, dynamic> _coverageJson() {
  return {
    'checkIns': _coverageEntryJson(),
    'water': _coverageEntryJson(),
    'dose': _coverageEntryJson(),
    'sleep': _coverageEntryJson(),
  };
}

Map<String, dynamic> _coverageEntryJson() {
  return {
    'state': 'observed',
    'coverage': 'none',
    'sources': ['manual'],
    'observedCount': 0,
    'expectedCount': null,
    'windowStart': null,
    'windowEnd': null,
  };
}

/// A preview response body. [sections] controls which section keys are
/// present — deselected sections are omitted by the server, exactly like the
/// real wire format.
Map<String, dynamic> _summaryJson({
  List<String> sections = const [
    'profile',
    'allergies',
    'conditions',
    'currentMedicines',
  ],
  List<String>? findings = const ['长期服用需监测'],
}) {
  return {
    'generatedAt': '2026-07-01T10:30:00',
    'scopeLabel': 'last_7_days',
    'start': '2026-06-24T00:00:00',
    'end': '2026-07-01T00:00:00',
    'selectedFields': sections,
    'coverage': _coverageJson(),
    'dataRange': 'last_7_days',
    if (sections.contains('profile'))
      'profile': {
        'nickname': 'Lumi',
        'age': 30,
        'sexAtBirth': 'male',
        'bloodType': 'A',
      },
    if (sections.contains('allergies'))
      'allergies': [
        {'label': '青霉素', 'reaction': '皮疹', 'severity': 'moderate'},
      ],
    if (sections.contains('conditions'))
      'conditions': [
        {'label': '高血压', 'status': 'active', 'diagnosedYear': 2023},
      ],
    if (sections.contains('currentMedicines'))
      'currentMedicines': [
        {'displayName': '阿莫西林', 'doseText': '0.5g 每日一次'},
      ],
    if (findings != null) 'findings': findings,
    'disclaimer': '本摘要仅供参考，不构成医疗建议',
  };
}

ClinicSummaryShareListItemDto _shareItem({
  String id = 'share-1',
  String? revokedAt,
  int accessCount = 3,
  String? lastAccessedAt = '2026-07-03T09:00:00',
}) {
  return ClinicSummaryShareListItemDto(
    id: id,
    createdAt: '2026-07-01T08:00:00',
    expiresAt: '2026-07-08T08:00:00',
    revokedAt: revokedAt,
    accessCount: accessCount,
    firstAccessedAt: lastAccessedAt,
    lastAccessedAt: lastAccessedAt,
    scope: ClinicSummaryShareScopeDto(
      eventId: null,
      dateFrom: '2026-06-02',
      dateTo: '2026-07-01',
    ),
    selectedFields: const ['event_overview', 'symptom_changes'],
  );
}

Response<ClinicSummaryShareListResponseDto> _shareListResponse(
  List<ClinicSummaryShareListItemDto> items,
) {
  return Response<ClinicSummaryShareListResponseDto>(
    data: ClinicSummaryShareListResponseDto(
      code: 0,
      message: '',
      data: ClinicSummaryShareListDataDto(items: items),
    ),
    requestOptions: RequestOptions(path: '/shares'),
    statusCode: 200,
  );
}

void main() {
  late _MockReportsApi reportsApi;
  late _FakeLucentClient client;
  late List<ClinicSummaryRequestDto> previewRequests;

  setUpAll(() {
    registerFallbackValue(ClinicSummaryRequestDto(selectedFields: []));
  });

  setUp(() {
    reportsApi = _MockReportsApi();
    client = _FakeLucentClient(reportsApi: reportsApi);
    previewRequests = [];
  });

  ProviderContainer makeContainer({
    LucentDioClient? dioClient,
    bool useMockClient = true,
  }) {
    final dio =
        dioClient ??
        LucentDioClient(
          baseUrl: 'http://localhost',
          sessionStore: _MemSessionStore(),
          httpClientAdapter: _ScriptedAdapter(),
        );
    addTearDown(dio.dispose);
    final c = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        lucentDioClientProvider.overrideWithValue(dio),
        if (useMockClient) lucentClientProvider.overrideWithValue(client),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('clinicSummaryPreviewProvider', () {
    test(
      'returns the clinic summary with the default field selection',
      () async {
        final adapter = _ScriptedAdapter();
        adapter.on('POST', '/api/v1/user/reports/clinic-summary/preview', (
          o,
        ) async {
          return _jsonBody(_envelope(_summaryJson()));
        });
        final dioClient = LucentDioClient(
          baseUrl: 'http://localhost',
          sessionStore: _MemSessionStore(),
          httpClientAdapter: adapter,
        );
        addTearDown(dioClient.dispose);

        final c = makeContainer(dioClient: dioClient, useMockClient: false);
        final dto = await c.read(
          clinicSummaryPreviewProvider(kClinicSummaryDefaultFields).future,
        );

        expect(dto.profile!.nickname, 'Lumi');
        expect(dto.allergies!.single.label, '青霉素');
        expect(dto.disclaimer, '本摘要仅供参考，不构成医疗建议');

        // The request carries only the selected fields — the default selection
        // is the five non-notes fields; the free-text notes stay off.
        final body = _requestBody(adapter.requests.first);
        expect(body['selectedFields'], [
          'event_overview',
          'symptom_changes',
          'medication_slots',
          'water',
          'sleep',
        ]);
      },
    );

    test('forwards the custom field selection in the request', () async {
      final adapter = _ScriptedAdapter();
      adapter.on('POST', '/api/v1/user/reports/clinic-summary/preview', (
        o,
      ) async {
        return _jsonBody(_envelope(_summaryJson()));
      });
      final dioClient = LucentDioClient(
        baseUrl: 'http://localhost',
        sessionStore: _MemSessionStore(),
        httpClientAdapter: adapter,
      );
      addTearDown(dioClient.dispose);

      final c = makeContainer(dioClient: dioClient, useMockClient: false);
      await c.read(
        clinicSummaryPreviewProvider(kClinicSummaryAllFields).future,
      );

      final body = _requestBody(adapter.requests.first);
      expect(body['selectedFields'], [
        'event_overview',
        'symptom_changes',
        'medication_slots',
        'water',
        'sleep',
        'notes',
      ]);
    });

    test('tolerates deselected sections omitted from the response', () async {
      final adapter = _ScriptedAdapter();
      // symptom_changes (conditions) deselected: the server omits the key.
      adapter.on('POST', '/api/v1/user/reports/clinic-summary/preview', (
        o,
      ) async {
        return _jsonBody(
          _envelope(
            _summaryJson(sections: const ['profile', 'currentMedicines']),
          ),
        );
      });
      final dioClient = LucentDioClient(
        baseUrl: 'http://localhost',
        sessionStore: _MemSessionStore(),
        httpClientAdapter: adapter,
      );
      addTearDown(dioClient.dispose);

      final c = makeContainer(dioClient: dioClient, useMockClient: false);
      final dto = await c.read(
        clinicSummaryPreviewProvider(kClinicSummaryDefaultFields).future,
      );

      expect(dto.selectedFields, ['profile', 'currentMedicines']);
      // Deselected sections deserialize to null instead of placeholders.
      expect(dto.conditions, isNull);
      expect(dto.allergies, isNull);
      expect(dto.profile!.nickname, 'Lumi');
    });

    test(
      'handles event_overview deselected (profile omitted) without throwing',
      () async {
        final adapter = _ScriptedAdapter();
        // event_overview (profile) deselected: the server omits the profile
        // key entirely, so the optional contract field deserializes to null.
        adapter.on('POST', '/api/v1/user/reports/clinic-summary/preview', (
          o,
        ) async {
          return _jsonBody(
            _envelope(
              _summaryJson(sections: const ['conditions', 'currentMedicines']),
            ),
          );
        });
        final dioClient = LucentDioClient(
          baseUrl: 'http://localhost',
          sessionStore: _MemSessionStore(),
          httpClientAdapter: adapter,
        );
        addTearDown(dioClient.dispose);

        final c = makeContainer(dioClient: dioClient, useMockClient: false);
        final dto = await c.read(
          clinicSummaryPreviewProvider(kClinicSummaryDefaultFields).future,
        );

        expect(dto.selectedFields, ['conditions', 'currentMedicines']);
        expect(dto.conditions!.single.label, '高血压');
        expect(dto.currentMedicines!.single.displayName, '阿莫西林');
        // The omitted profile section is null — no placeholder needed.
        expect(dto.profile, isNull);
        expect(dto.allergies, isNull);
      },
    );

    test('tolerates a response without any of the four sections', () async {
      // A selection mapping to no data section (e.g. water/sleep/notes) still
      // omits every section key from the wire response; the optional contract
      // fields must deserialize to null without throwing.
      final adapter = _ScriptedAdapter();
      adapter.on('POST', '/api/v1/user/reports/clinic-summary/preview', (
        o,
      ) async {
        return _jsonBody(_envelope(_summaryJson(sections: const [])));
      });
      final dioClient = LucentDioClient(
        baseUrl: 'http://localhost',
        sessionStore: _MemSessionStore(),
        httpClientAdapter: adapter,
      );
      addTearDown(dioClient.dispose);

      final c = makeContainer(dioClient: dioClient, useMockClient: false);
      final dto = await c.read(
        clinicSummaryPreviewProvider(kClinicSummaryDefaultFields).future,
      );

      expect(dto.selectedFields, isEmpty);
      expect(dto.profile, isNull);
      expect(dto.allergies, isNull);
      expect(dto.conditions, isNull);
      expect(dto.currentMedicines, isNull);
      expect(dto.disclaimer, '本摘要仅供参考，不构成医疗建议');
    });

    test('propagates API errors', () async {
      final adapter = _ScriptedAdapter();
      adapter.on('POST', '/api/v1/user/reports/clinic-summary/preview', (
        o,
      ) async {
        throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionError,
        );
      });
      final dioClient = LucentDioClient(
        baseUrl: 'http://localhost',
        sessionStore: _MemSessionStore(),
        httpClientAdapter: adapter,
      );
      addTearDown(dioClient.dispose);

      final c = makeContainer(dioClient: dioClient, useMockClient: false);
      // Keep the autoDispose provider alive while the error propagates.
      final sub = c.listen<AsyncValue<ClinicSummaryDto>>(
        clinicSummaryPreviewProvider(kClinicSummaryDefaultFields),
        (_, __) {},
      );
      addTearDown(sub.close);

      await expectLater(
        c.read(
          clinicSummaryPreviewProvider(kClinicSummaryDefaultFields).future,
        ),
        // The error interceptor re-wraps the mapped LucentApiException
        // inside a DioException, so the provider sees a DioException.
        throwsA(isA<DioException>()),
      );
    });
  });

  group('clinicSummarySharedProvider', () {
    Future<ProviderContainer> containerWithShared(
      _ScriptedAdapter adapter,
    ) async {
      final dioClient = LucentDioClient(
        baseUrl: 'http://localhost',
        sessionStore: _MemSessionStore(),
        httpClientAdapter: adapter,
      );
      addTearDown(dioClient.dispose);
      return makeContainer(dioClient: dioClient, useMockClient: false);
    }

    test(
      'fetches a shared summary by token via raw Dio (envelope unwrapped)',
      () async {
        final adapter = _ScriptedAdapter();
        adapter.on(
          'GET',
          '/api/v1/user/reports/clinic-summary/shared/abc123',
          (o) async =>
              _jsonBody(_envelope(_summaryJson(findings: const ['发现一条']))),
        );

        final c = await containerWithShared(adapter);
        final dto = await c.read(clinicSummarySharedProvider('abc123').future);

        expect(dto.dataRange, 'last_7_days');
        expect(dto.findings, ['发现一条']);
        expect(dto.allergies!.single.label, '青霉素');

        // Public route: the request carries no Authorization header, exactly
        // like the public shared PDF download.
        final options = adapter.requests.single;
        expect(
          options.path,
          '/api/v1/user/reports/clinic-summary/shared/abc123',
        );
        expect(options.extra['skipAuthorization'], isTrue);
        expect(options.headers.containsKey('Authorization'), isFalse);
      },
    );

    test(
      'tolerates deselected sections omitted from the shared response',
      () async {
        // A share created with a partial field selection omits the deselected
        // section keys — the provider must fill them instead of throwing.
        final adapter = _ScriptedAdapter();
        adapter.on(
          'GET',
          '/api/v1/user/reports/clinic-summary/shared/abc123',
          (o) async => _jsonBody(
            _envelope(
              _summaryJson(sections: const ['conditions', 'currentMedicines']),
            ),
          ),
        );

        final c = await containerWithShared(adapter);
        final dto = await c.read(clinicSummarySharedProvider('abc123').future);

        expect(dto.selectedFields, ['conditions', 'currentMedicines']);
        expect(dto.conditions!.single.label, '高血压');
        expect(dto.currentMedicines!.single.displayName, '阿莫西林');
        // The omitted sections deserialize to null; the content widget never
        // renders null sections (rendering is gated on the server-echoed
        // selectedFields AND on the section being present).
        expect(dto.profile, isNull);
        expect(dto.allergies, isNull);
      },
    );

    test('is per-token cached', () async {
      final adapter = _ScriptedAdapter();
      adapter.on(
        'GET',
        '/api/v1/user/reports/clinic-summary/shared/a',
        (o) async => _jsonBody(_envelope(_summaryJson())),
      );
      adapter.on(
        'GET',
        '/api/v1/user/reports/clinic-summary/shared/b',
        (o) async => _jsonBody(_envelope(_summaryJson())),
      );

      final c = await containerWithShared(adapter);
      await c.read(clinicSummarySharedProvider('a').future);
      await c.read(clinicSummarySharedProvider('b').future);

      expect(adapter.requests.map((r) => r.path), [
        '/api/v1/user/reports/clinic-summary/shared/a',
        '/api/v1/user/reports/clinic-summary/shared/b',
      ]);
    });

    test('propagates API errors (expired / revoked / unknown token)', () async {
      final adapter = _ScriptedAdapter();
      adapter.on('GET', '/api/v1/user/reports/clinic-summary/shared/abc123', (
        o,
      ) async {
        throw DioException(
          requestOptions: o,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: o,
            statusCode: 404,
            data: _envelope(null),
          ),
        );
      });

      final c = await containerWithShared(adapter);
      // Keep the autoDispose provider alive while the error propagates.
      final sub = c.listen<AsyncValue<ClinicSummaryDto>>(
        clinicSummarySharedProvider('abc123'),
        (_, __) {},
      );
      addTearDown(sub.close);

      await expectLater(
        c.read(clinicSummarySharedProvider('abc123').future),
        // The error interceptor re-wraps the mapped LucentApiException
        // inside a DioException, so the provider sees a DioException.
        throwsA(isA<DioException>()),
      );
    });
  });

  group('clinicSummaryShareListProvider', () {
    test('lists the current user shares', () async {
      when(
        () => reportsApi.reportsControllerListClinicSummarySharesV1(),
      ).thenAnswer((_) async => _shareListResponse([_shareItem()]));

      final c = makeContainer();
      final items = await c.read(clinicSummaryShareListProvider.future);

      expect(items, hasLength(1));
      expect(items.first.id, 'share-1');
      expect(items.first.accessCount, 3);
      verify(
        () => reportsApi.reportsControllerListClinicSummarySharesV1(),
      ).called(1);
    });

    test('revoke deletes the share and refreshes the list', () async {
      when(
        () => reportsApi.reportsControllerListClinicSummarySharesV1(),
      ).thenAnswer((_) async => _shareListResponse([_shareItem()]));
      when(
        () => reportsApi.reportsControllerRevokeClinicSummaryShareV1(
          shareId: 'share-1',
        ),
      ).thenAnswer(
        (_) async => Response<void>(
          requestOptions: RequestOptions(path: '/revoke'),
          statusCode: 200,
        ),
      );

      final c = makeContainer();
      final notifier = c.read(clinicSummaryShareListProvider.notifier);
      final sub = c.listen(clinicSummaryShareListProvider, (_, __) {});
      addTearDown(sub.close);

      await c.read(clinicSummaryShareListProvider.future);
      await notifier.revoke('share-1');
      await c.read(clinicSummaryShareListProvider.future);

      verify(
        () => reportsApi.reportsControllerRevokeClinicSummaryShareV1(
          shareId: 'share-1',
        ),
      ).called(1);
      // invalidateSelf triggers a refetch of the list.
      verify(
        () => reportsApi.reportsControllerListClinicSummarySharesV1(),
      ).called(2);
    });
  });

  Future<_ScriptedAdapter> openDialog(
    WidgetTester tester, {
    required _FakeLucentClient client,
    required _RecordingProductEventService service,
    Map<String, Future<ResponseBody> Function(RequestOptions)>? handlers,
    Object? previewError,
  }) async {
    final adapter = _ScriptedAdapter();
    adapter.on('POST', '/api/v1/user/reports/clinic-summary/preview', (
      o,
    ) async {
      return _jsonBody(_envelope(_summaryJson()));
    });
    (handlers ?? const {}).forEach((key, handler) {
      final parts = key.split(' ');
      adapter.on(parts.first, parts.sublist(1).join(' '), handler);
    });
    final dioClient = LucentDioClient(
      baseUrl: 'http://localhost',
      sessionStore: _MemSessionStore(),
      httpClientAdapter: adapter,
    );
    addTearDown(dioClient.dispose);
    when(
      () => reportsApi.reportsControllerPreviewClinicSummaryV1(
        clinicSummaryRequestDto: any(named: 'clinicSummaryRequestDto'),
      ),
    ).thenAnswer((invocation) async {
      previewRequests.add(
        invocation.namedArguments[#clinicSummaryRequestDto]
            as ClinicSummaryRequestDto,
      );
      if (previewError != null) throw previewError;
      return Response<ClinicSummaryResponseDto>(
        requestOptions: RequestOptions(path: '/preview'),
        statusCode: 200,
        data: ClinicSummaryResponseDto.fromJson(_envelope(_summaryJson())),
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          lucentDioClientProvider.overrideWithValue(dioClient),
          lucentClientProvider.overrideWithValue(client),
          productEventServiceProvider.overrideWithValue(service),
        ],
        // The toaster wraps the whole app (above the Navigator) so the
        // bottom-sheet dialog can show toasts; toast timers are drained in
        // each test before it ends.
        child: TestForuiApp(
          locale: const Locale('zh'),
          // Toasts (copy / PDF failure) need an FToaster above the
          // Navigator; each test drains the 1800ms toast timer before
          // it ends.
          showToaster: true,
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
    return adapter;
  }

  // ── Preview dialog measurement ─────────────────────────────────────────

  group('clinic summary preview dialog measurement', () {
    testWidgets('records previewed success after the server responds', (
      tester,
    ) async {
      final service = _RecordingProductEventService();

      await openDialog(tester, client: client, service: service);

      expect(service.previewResults, [ProductEventResult.success]);
      expect(service.exportResults, isEmpty);
      // The preview content is actually presented.
      expect(find.text('本摘要仅供参考，不构成医疗建议'), findsOneWidget);
    });

    testWidgets('records previewed failure when the preview request fails', (
      tester,
    ) async {
      final service = _RecordingProductEventService();

      await openDialog(
        tester,
        client: client,
        service: service,
        previewError: DioException(
          requestOptions: RequestOptions(path: '/preview'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(service.previewResults, [ProductEventResult.failure]);
      expect(service.exportResults, isEmpty);
    });

    testWidgets('records exported failure when the PDF download fails', (
      tester,
    ) async {
      final service = _RecordingProductEventService();

      await openDialog(
        tester,
        client: client,
        service: service,
        handlers: {
          'POST /api/v1/user/reports/clinic-summary/preview/pdf': (o) async {
            throw DioException(
              requestOptions: o,
              type: DioExceptionType.connectionError,
            );
          },
        },
      );

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final pdfButton = find.text(l10n.reportClinicSummaryDownloadPdf);
      await tester.ensureVisible(pdfButton);
      await tester.pumpAndSettle();
      await tester.tap(pdfButton);
      await tester.pumpAndSettle();

      expect(service.previewResults, [ProductEventResult.success]);
      expect(service.exportResults, [ProductEventResult.failure]);
      // The PDF failure toast auto-dismisses; drain its timer.
      await tester.pump(const Duration(milliseconds: 1900));
      await tester.pumpAndSettle();
    });
  });

  // ── Preview dialog field selection ─────────────────────────────────────

  group('clinic summary preview dialog field selection', () {
    testWidgets('shows all six toggles with notes off by default', (
      tester,
    ) async {
      final service = _RecordingProductEventService();
      await openDialog(tester, client: client, service: service);

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      for (final label in [
        l10n.reportClinicSummaryFieldEventOverview,
        l10n.reportClinicSummaryFieldSymptomChanges,
        l10n.reportClinicSummaryFieldMedicationSlots,
        l10n.reportClinicSummaryFieldWater,
        l10n.reportClinicSummaryFieldSleep,
        l10n.reportClinicSummaryFieldNotes,
      ]) {
        expect(find.text(label), findsOneWidget);
      }

      FCheckbox checkboxFor(String fieldValue) {
        return tester.widget<FCheckbox>(
          find.descendant(
            of: find.byKey(Key('clinic-summary-field-$fieldValue')),
            matching: find.byType(FCheckbox),
          ),
        );
      }

      expect(checkboxFor('notes').value, isFalse);
      expect(checkboxFor('event_overview').value, isTrue);
      expect(checkboxFor('sleep').value, isTrue);

      // The first preview request carries the default five-field selection
      // (notes off), matching the widget defaults.
      expect(previewRequests.single.selectedFields?.map((e) => e.value), [
        'event_overview',
        'symptom_changes',
        'medication_slots',
        'water',
        'sleep',
      ]);
    });

    testWidgets(
      'toggling a field re-requests the preview with the new selection',
      (tester) async {
        final service = _RecordingProductEventService();
        await openDialog(tester, client: client, service: service);

        await tester.tap(
          find.descendant(
            of: find.byKey(const Key('clinic-summary-field-notes')),
            matching: find.byType(FCheckbox),
          ),
        );
        await tester.pumpAndSettle();

        expect(previewRequests, hasLength(2));
        expect(previewRequests.last.selectedFields?.map((e) => e.value), [
          'event_overview',
          'symptom_changes',
          'medication_slots',
          'water',
          'sleep',
          'notes',
        ]);

        // Toggling re-fetches but does not re-measure the presentation.
        expect(service.previewResults, [ProductEventResult.success]);
      },
    );

    testWidgets('the last remaining field cannot be deselected', (
      tester,
    ) async {
      final service = _RecordingProductEventService();
      await openDialog(tester, client: client, service: service);

      FCheckbox checkboxFor(String fieldValue) {
        return tester.widget<FCheckbox>(
          find.descendant(
            of: find.byKey(Key('clinic-summary-field-$fieldValue')),
            matching: find.byType(FCheckbox),
          ),
        );
      }

      // Deselect four of the five default fields, leaving only sleep.
      for (final field in [
        'event_overview',
        'symptom_changes',
        'medication_slots',
        'water',
      ]) {
        await tester.tap(
          find.descendant(
            of: find.byKey(Key('clinic-summary-field-$field')),
            matching: find.byType(FCheckbox),
          ),
        );
        await tester.pumpAndSettle();
      }

      expect(checkboxFor('sleep').value, isTrue);
      expect(checkboxFor('sleep').enabled, isFalse);

      // Tapping the disabled last toggle does not fire another request.
      final requestCount = previewRequests.length;
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('clinic-summary-field-sleep')),
          matching: find.byType(FCheckbox),
        ),
      );
      await tester.pumpAndSettle();
      expect(previewRequests.length, requestCount);

      expect(previewRequests.last.selectedFields?.map((e) => e.value), [
        'sleep',
      ]);
    });
  });

  // ── Preview dialog share flow ──────────────────────────────────────────

  group('clinic summary preview dialog share flow', () {
    Future<(_ScriptedAdapter, List<MethodCall>)> openDialogWithClipboard(
      WidgetTester tester, {
      required _FakeLucentClient client,
      required _RecordingProductEventService service,
    }) async {
      final clipboardCalls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardCalls.add(call);
          }
          return null;
        },
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });

      final adapter = await openDialog(
        tester,
        client: client,
        service: service,
      );
      return (adapter, clipboardCalls);
    }

    testWidgets('shows expiry and link-holder notice before creating', (
      tester,
    ) async {
      final service = _RecordingProductEventService();
      await openDialog(tester, client: client, service: service);

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await tester.ensureVisible(find.text(l10n.reportClinicSummaryShare));
      await tester.tap(find.text(l10n.reportClinicSummaryShare));
      await tester.pumpAndSettle();

      // Pre-create confirmation: expiry + anyone-with-the-link notice.
      expect(find.text(l10n.reportShareConfirmTitle), findsOneWidget);
      expect(find.text(l10n.reportShareConfirmExpiryHint(7)), findsOneWidget);
      expect(find.text(l10n.reportShareConfirmNotice), findsOneWidget);

      // No doctor-implies copy anywhere in the share flow.
      expect(find.textContaining('医生'), findsNothing);
      expect(find.textContaining('已收到'), findsNothing);
    });

    testWidgets(
      'creating a share sends the current selection and shows copy + revoke',
      (tester) async {
        when(
          () => reportsApi.reportsControllerRevokeClinicSummaryShareV1(
            shareId: any(named: 'shareId'),
          ),
        ).thenAnswer(
          (_) async => Response<void>(
            requestOptions: RequestOptions(path: '/revoke'),
            statusCode: 200,
          ),
        );
        final service = _RecordingProductEventService();
        final (adapter, clipboardCalls) = await openDialogWithClipboard(
          tester,
          client: client,
          service: service,
        );
        when(
          () => reportsApi.reportsControllerShareClinicSummaryV1(
            clinicSummaryRequestDto: any(named: 'clinicSummaryRequestDto'),
          ),
        ).thenAnswer(
          (_) async => Response<ClinicSummaryShareResponseDto>(
            requestOptions: RequestOptions(path: '/share'),
            statusCode: 200,
            data: ClinicSummaryShareResponseDto.fromJson(
              _envelope({
                'shareId': 'share-42',
                'token': 'tok',
                'shareUrl':
                    'https://example.com/api/v1/user/reports/clinic-summary/shared/abc',
                'expiresAt': '2026-07-08T08:00:00',
                'scope': {
                  'eventId': null,
                  'dateFrom': '2026-06-02',
                  'dateTo': '2026-07-01',
                },
                'selectedFields': [
                  'event_overview',
                  'symptom_changes',
                  'medication_slots',
                  'water',
                  'sleep',
                ],
              }),
            ),
          ),
        );

        final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
        await tester.ensureVisible(find.text(l10n.reportClinicSummaryShare));
        await tester.tap(find.text(l10n.reportClinicSummaryShare));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.reportShareConfirmAction));
        await tester.pumpAndSettle();

        // The share request carries the current field selection (notes off).
        final shareRequest = verify(
          () => reportsApi.reportsControllerShareClinicSummaryV1(
            clinicSummaryRequestDto: captureAny(
              named: 'clinicSummaryRequestDto',
            ),
          ),
        ).captured.single as ClinicSummaryRequestDto;
        expect(
          shareRequest.selectedFields?.map((e) => e.value),
          [
            'event_overview',
            'symptom_changes',
            'medication_slots',
            'water',
            'sleep',
          ],
        );

        // Created state: link + expiry + copy + revoke.
        expect(find.text(l10n.reportShareCreatedTitle), findsOneWidget);
        expect(
          find.textContaining('clinic-summary/shared/abc'),
          findsOneWidget,
        );
        expect(find.text(l10n.reportShareCopyAction), findsOneWidget);
        expect(find.text(l10n.reportShareRevokeAction), findsOneWidget);
        // The share-create event is server-side; the client records nothing.
        expect(service.exportResults, isEmpty);

        // Copy writes the link to the clipboard and confirms with a toast.
        await tester.tap(find.text(l10n.reportShareCopyAction));
        await tester.pumpAndSettle();
        expect(clipboardCalls, hasLength(1));
        expect(
          (clipboardCalls.single.arguments as Map)['text'],
          'https://example.com/api/v1/user/reports/clinic-summary/shared/abc',
        );
        expect(find.text(l10n.reportShareCopiedToast), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 1900));
        await tester.pumpAndSettle();

        // Revoke calls DELETE with the share id and shows the revoked state.
        await tester.tap(find.text(l10n.reportShareRevokeAction));
        await tester.pumpAndSettle();
        verify(
          () => reportsApi.reportsControllerRevokeClinicSummaryShareV1(
            shareId: 'share-42',
          ),
        ).called(1);
        expect(find.text(l10n.reportShareRevokedTitle), findsOneWidget);
        expect(find.text(l10n.reportShareRevokedBody), findsOneWidget);
      },
    );

    testWidgets(
      'creating a share invalidates the share list so the management sheet '
      'shows the new share',
      (tester) async {
        var listCalls = 0;
        when(
          () => reportsApi.reportsControllerListClinicSummarySharesV1(),
        ).thenAnswer((_) async {
          listCalls += 1;
          return _shareListResponse([_shareItem()]);
        });
        final service = _RecordingProductEventService();
        await openDialog(tester, client: client, service: service);
        when(
          () => reportsApi.reportsControllerShareClinicSummaryV1(
            clinicSummaryRequestDto: any(named: 'clinicSummaryRequestDto'),
          ),
        ).thenAnswer(
          (_) async => Response<ClinicSummaryShareResponseDto>(
            requestOptions: RequestOptions(path: '/share'),
            statusCode: 200,
            data: ClinicSummaryShareResponseDto.fromJson(
              _envelope({
                'shareId': 'share-new',
                'token': 'tok',
                'shareUrl':
                    'https://example.com/api/v1/user/reports/clinic-summary/shared/def',
                'expiresAt': '2026-07-08T08:00:00',
                'scope': {
                  'eventId': null,
                  'dateFrom': '2026-06-02',
                  'dateTo': '2026-07-01',
                },
                'selectedFields': ['event_overview'],
              }),
            ),
          ),
        );

        // Watch the share list provider from the pumped container so the
        // invalidation (and its refetch) is observable.
        final container = ProviderScope.containerOf(
          tester.element(find.text('open preview')),
        );
        var notifications = 0;
        final sub = container.listen(
          clinicSummaryShareListProvider,
          (_, __) => notifications += 1,
        );
        addTearDown(sub.close);
        await container.read(clinicSummaryShareListProvider.future);
        verify(
          () => reportsApi.reportsControllerListClinicSummarySharesV1(),
        ).called(1);

        final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
        await tester.ensureVisible(find.text(l10n.reportClinicSummaryShare));
        await tester.tap(find.text(l10n.reportClinicSummaryShare));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.reportShareConfirmAction));
        await tester.pumpAndSettle();

        expect(find.text(l10n.reportShareCreatedTitle), findsOneWidget);
        // The create invalidated the cached list, so the next read refetches.
        await container.read(clinicSummaryShareListProvider.future);
        // The create invalidated the cached list: the provider rebuilt
        // (listener notified again) and refetched from the API.
        expect(listCalls, 2);
        expect(notifications, greaterThan(1));
      },
    );

    testWidgets(
      'field toggles stay enabled during confirm and lock once created',
      (tester) async {
        final service = _RecordingProductEventService();
        await openDialog(tester, client: client, service: service);
        when(
          () => reportsApi.reportsControllerShareClinicSummaryV1(
            clinicSummaryRequestDto: any(named: 'clinicSummaryRequestDto'),
          ),
        ).thenAnswer(
          (_) async => Response<ClinicSummaryShareResponseDto>(
            requestOptions: RequestOptions(path: '/share'),
            statusCode: 200,
            data: ClinicSummaryShareResponseDto.fromJson(
              _envelope({
                'shareId': 'share-42',
                'token': 'tok',
                'shareUrl':
                    'https://example.com/api/v1/user/reports/clinic-summary/shared/abc',
                'expiresAt': '2026-07-08T08:00:00',
                'scope': {
                  'eventId': null,
                  'dateFrom': '2026-06-02',
                  'dateTo': '2026-07-01',
                },
                'selectedFields': ['event_overview'],
              }),
            ),
          ),
        );

        FCheckbox notesCheckbox() {
          return tester.widget<FCheckbox>(
            find.descendant(
              of: find.byKey(const Key('clinic-summary-field-notes')),
              matching: find.byType(FCheckbox),
            ),
          );
        }

        final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
        await tester.ensureVisible(find.text(l10n.reportClinicSummaryShare));
        await tester.tap(find.text(l10n.reportClinicSummaryShare));
        await tester.pumpAndSettle();

        // Confirm step: toggling must stay enabled (it affects the share
        // being created).
        expect(find.text(l10n.reportShareConfirmTitle), findsOneWidget);
        expect(notesCheckbox().enabled, isTrue);

        await tester.tap(find.text(l10n.reportShareConfirmAction));
        await tester.pumpAndSettle();

        // Created step: the link is fixed, toggles are locked so the preview
        // cannot silently change behind the shown link.
        expect(find.text(l10n.reportShareCreatedTitle), findsOneWidget);
        expect(notesCheckbox().enabled, isFalse);

        final requestsBefore = previewRequests.length;
        await tester.tap(
          find.descendant(
            of: find.byKey(const Key('clinic-summary-field-notes')),
            matching: find.byType(FCheckbox),
          ),
        );
        await tester.pumpAndSettle();
        expect(previewRequests.length, requestsBefore);
      },
    );
  });
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
