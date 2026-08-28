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
import 'package:luminous/core/providers/sensitive_action_password.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/utils/export_actions.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_forui_app.dart';
import '../helpers/test_helpers.dart';

class _MockDataExportApi extends Mock implements DataExportApi {}

class _FakeLucentClient extends LucentClient {
  _FakeLucentClient({required this.dataExportApi})
    : super(LucentApi(dio: Dio()));

  final DataExportApi dataExportApi;

  @override
  DataExportApi get dataExport => dataExportApi;
}

/// Records export results instead of posting events.
class _RecordingProductEventService extends ProductEventService {
  _RecordingProductEventService() : super(api: _MockProductEventsApi());

  final List<ProductEventResult> exportResults = [];

  @override
  Future<void> trackVisitSummaryExported(ProductEventResult result) async {
    exportResults.add(result);
  }
}

class _MockProductEventsApi extends Mock implements ProductEventsApi {}

class _FakeUserSettingsController extends UserSettingsController {
  @override
  Future<UserSettings> build() async {
    return const UserSettings(
      aiSummariesEnabled: false,
      dataSharingConsent: false,
      assistantEnabled: false,
      assistantMemoryEnabled: false,
      waterTargetCount: 8,
      assistantContext: AssistantContextSettings(
        healthProfile: true,
        dailyRecords: true,
        sleepRecords: true,
        currentMedicines: true,
      ),
      passwordReauthenticationRequired: true,
    );
  }
}

DataExportRequestDataDto _request(DataExportStatus status) {
  return DataExportRequestDataDto(
    id: 'req-1',
    kind: DataExportKind.monthly,
    format: DataExportFormat.pdf,
    range: DataExportRange.last30Days,
    status: status,
    requestedAt: '2026-08-14T08:00:00Z',
  );
}

Future<void> _pumpHarness(
  WidgetTester tester, {
  required _MockDataExportApi api,
  required _RecordingProductEventService service,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        lucentClientProvider.overrideWithValue(
          _FakeLucentClient(dataExportApi: api),
        ),
        sensitiveActionPasswordPromptProvider.overrideWithValue(
          (_, {title, message, label}) async => 'export-password',
        ),
        productEventServiceProvider.overrideWithValue(service),
        userSettingsControllerProvider.overrideWith(
          () => _FakeUserSettingsController(),
        ),
      ],
      child: TestForuiApp(
        locale: const Locale('zh'),
        home: FToaster(
          child: Consumer(
            builder: (context, ref, _) => Center(
              child: FButton(
                onPress: () => handleReviewExportAction(
                  context,
                  ref,
                  ReviewExportKind.monthly,
                ),
                child: const Text('export'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Taps the export button and drains both the flow and the toast
/// auto-dismiss timer so no timers remain pending at test end.
Future<void> _tapExport(WidgetTester tester) async {
  await tester.tap(find.text('export'));
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  late _MockDataExportApi api;
  late _RecordingProductEventService service;

  setUp(() {
    api = _MockDataExportApi();
    service = _RecordingProductEventService();
    // The export controller's build()/refresh() read the latest request;
    // return a benign response so those reads never throw.
    when(() => api.dataExportControllerGetLatestRequestV1()).thenAnswer(
      (_) async => Response<DataExportRequestDataDto>(
        data: _request(DataExportStatus.completed),
        requestOptions: RequestOptions(path: '/data-export-requests/latest'),
        statusCode: 200,
      ),
    );
  });

  testWidgets(
    'records exported failure when the server returns a failed request status',
    (tester) async {
      when(
        () => api.dataExportControllerCreateRequestV1(
          createDataExportRequestDto: reviewMonthlyPdfExportRequest.toDto(
            password: 'export-password',
          ),
        ),
      ).thenAnswer(
        (_) async => Response<DataExportRequestResponseDto>(
          data: DataExportRequestResponseDto.fromJson(
            _request(DataExportStatus.failed).toJson(),
          ),
          requestOptions: RequestOptions(path: '/data-export-requests'),
          statusCode: 200,
        ),
      );

      await _pumpHarness(tester, api: api, service: service);
      await _tapExport(tester);

      // HTTP 200 alone must not count as exported — the request itself is in
      // a failed state, so the event records failure.
      expect(service.exportResults, [ProductEventResult.failure]);
    },
  );

  testWidgets(
    'records exported success when the server returns a completed request',
    (tester) async {
      when(
        () => api.dataExportControllerCreateRequestV1(
          createDataExportRequestDto: reviewMonthlyPdfExportRequest.toDto(
            password: 'export-password',
          ),
        ),
      ).thenAnswer(
        (_) async => Response<DataExportRequestResponseDto>(
          data: DataExportRequestResponseDto.fromJson(
            _request(DataExportStatus.completed).toJson(),
          ),
          requestOptions: RequestOptions(path: '/data-export-requests'),
          statusCode: 200,
        ),
      );

      await _pumpHarness(tester, api: api, service: service);
      await _tapExport(tester);

      expect(service.exportResults, [ProductEventResult.success]);
    },
  );

  testWidgets(
    'records exported failure when the server returns an unavailable request',
    (tester) async {
      when(
        () => api.dataExportControllerCreateRequestV1(
          createDataExportRequestDto: reviewMonthlyPdfExportRequest.toDto(
            password: 'export-password',
          ),
        ),
      ).thenAnswer(
        (_) async => Response<DataExportRequestResponseDto>(
          data: DataExportRequestResponseDto.fromJson(
            _request(DataExportStatus.unavailable).toJson(),
          ),
          requestOptions: RequestOptions(path: '/data-export-requests'),
          statusCode: 200,
        ),
      );

      await _pumpHarness(tester, api: api, service: service);
      await _tapExport(tester);

      expect(service.exportResults, [ProductEventResult.failure]);
    },
  );

  testWidgets('records exported failure when the request call throws', (
    tester,
  ) async {
    when(
      () => api.dataExportControllerCreateRequestV1(
        createDataExportRequestDto: reviewMonthlyPdfExportRequest.toDto(
          password: 'export-password',
        ),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/data-export-requests'),
        type: DioExceptionType.connectionError,
      ),
    );

    await _pumpHarness(tester, api: api, service: service);
    await _tapExport(tester);

    expect(service.exportResults, [ProductEventResult.failure]);
  });
}
