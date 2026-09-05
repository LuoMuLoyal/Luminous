import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/client/dio_client.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';

import '../helpers/test_helpers.dart';

void main() {
  late _FakeDataExportApi fakeApi;
  late ProviderContainer container;

  ProviderContainer buildContainer({_FakeDataExportApi? api}) {
    final fake = api ?? _FakeDataExportApi();
    fakeApi = fake;
    final c = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        lucentClientProvider.overrideWithValue(
          LucentClient(_FakeLucentApi(dataExportApi: fake)),
        ),
      ],
    );
    addTearDown(c.dispose);
    container = c;
    return c;
  }

  group('build – initial load', () {
    test('loads latest export request on creation', () async {
      container = buildContainer();

      final state = await container.read(dataExportControllerProvider.future);

      expect(state, isNotNull);
      expect(state!.id, 'req-1');
      expect(state.status, DataExportRequestDataStatusEnum.completed);
      expect(state.downloadUrl, 'https://example.com/export.csv');
      expect(fakeApi.getLatestCallCount, 1);
    });

    test('returns null when no previous request exists (graceful)', () async {
      container = buildContainer(
        api: _FakeDataExportApi(latestReturnsNullData: true),
      );

      final state = await container.read(dataExportControllerProvider.future);
      expect(state, isNull);
      expect(fakeApi.getLatestCallCount, 1);
    });

    test('returns null on DioException from GET (graceful)', () async {
      container = buildContainer(
        api: _FakeDataExportApi(
          getLatestException: DioException(
            requestOptions: RequestOptions(
              path: '/api/v1/user/data-export-requests/latest',
            ),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
      );

      final state = await container.read(dataExportControllerProvider.future);
      expect(state, isNull);
    });

    test('returns null when GET response data is null (graceful)', () async {
      final api = _FakeDataExportApi();
      api.getLatestReturnsNullResponse = true;
      container = buildContainer(api: api);

      final state = await container.read(dataExportControllerProvider.future);
      expect(state, isNull);
      expect(fakeApi.getLatestCallCount, 1);
    });
  });

  group('requestExport', () {
    test('creates request and updates state on success', () async {
      container = buildContainer();

      await container.read(dataExportControllerProvider.future);

      fakeApi.createResponse = _buildCreateResponse(
        id: 'req-2',
        status: DataExportRequestDataStatusEnum.requested,
      );

      await container
          .read(dataExportControllerProvider.notifier)
          .requestExport(
            reviewHospitalPdfLast7DaysExportRequest,
            password: 'export-password',
          );

      final state = container.read(dataExportControllerProvider).value;
      expect(state, isNotNull);
      expect(state!.id, 'req-2');
      expect(state.status, DataExportRequestDataStatusEnum.requested);
      expect(fakeApi.createCallCount, 1);
      expect(
        fakeApi.lastCreateRequest?.kind,
        CreateRequestRequestKindEnum.hospital,
      );
      expect(
        fakeApi.lastCreateRequest?.format,
        CreateRequestRequestFormatEnum.pdf,
      );
      expect(
        fakeApi.lastCreateRequest?.range,
        CreateRequestRequestRangeEnum.last7Days,
      );
      expect(fakeApi.lastCreateRequest?.password, 'export-password');
      expect(
        container.read(dataExportRequestInFlightProvider).inFlight,
        isFalse,
      );
    });

    test('sends custom request parameters when provided', () async {
      container = buildContainer();

      await container.read(dataExportControllerProvider.future);

      await container
          .read(dataExportControllerProvider.notifier)
          .requestExport(
            const DataExportRequestInput(
              kind: CreateRequestRequestKindEnum.monthly,
              format: CreateRequestRequestFormatEnum.pdf,
              range: CreateRequestRequestRangeEnum
                  .last30Days,
            ),
            password: 'export-password',
          );

      expect(
        fakeApi.lastCreateRequest?.kind,
        CreateRequestRequestKindEnum.monthly,
      );
      expect(
        fakeApi.lastCreateRequest?.format,
        CreateRequestRequestFormatEnum.pdf,
      );
      expect(
        fakeApi.lastCreateRequest?.range,
        CreateRequestRequestRangeEnum.last30Days,
      );
    });

    test('tracks which export input is in flight', () async {
      container = buildContainer();

      await container.read(dataExportControllerProvider.future);

      final delayedApi = _FakeDataExportApi(
        createDelay: const Duration(milliseconds: 50),
      );
      container.dispose();
      container = buildContainer(api: delayedApi);
      await container.read(dataExportControllerProvider.future);

      final future = container
          .read(dataExportControllerProvider.notifier)
          .requestExport(
            reviewMonthlyPdfExportRequest,
            password: 'export-password',
          );

      await Future<void>.delayed(const Duration(milliseconds: 10));

      final inFlight = container.read(dataExportRequestInFlightProvider);
      expect(inFlight.inFlight, isTrue);
      expect(inFlight.input, reviewMonthlyPdfExportRequest);

      await future;

      expect(
        container.read(dataExportRequestInFlightProvider).inFlight,
        isFalse,
      );
    });

    test('propagates DioException when POST fails', () async {
      container = buildContainer();

      await container.read(dataExportControllerProvider.future);

      fakeApi.createException = DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/user/data-export-requests',
        ),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        () => container
            .read(dataExportControllerProvider.notifier)
            .requestExport(
              reviewHospitalPdfLast7DaysExportRequest,
              password: 'export-password',
            ),
        throwsA(isA<DioException>()),
      );

      // State should remain from the initial load.
      final state = container.read(dataExportControllerProvider);
      expect(state.value?.id, 'req-1');
    });

    test('propagates DioException when POST response data is null', () async {
      container = buildContainer();

      await container.read(dataExportControllerProvider.future);

      fakeApi.createReturnsNull = true;

      expect(
        () => container
            .read(dataExportControllerProvider.notifier)
            .requestExport(
              reviewHospitalPdfLast7DaysExportRequest,
              password: 'export-password',
            ),
        throwsA(isA<DioException>()),
      );
    });

    test(
      'creates and updates state after initial load returned null',
      () async {
        container = buildContainer(
          api: _FakeDataExportApi(latestReturnsNullData: true),
        );

        // Initial load returns null gracefully (no error state).
        final initial = await container.read(
          dataExportControllerProvider.future,
        );
        expect(initial, isNull);

        fakeApi.latestReturnsNullData = false;
        fakeApi.createResponse = _buildCreateResponse(
          id: 'req-first',
          status: DataExportRequestDataStatusEnum.processing,
        );

        await container
            .read(dataExportControllerProvider.notifier)
            .requestExport(
              reviewHospitalPdfLast7DaysExportRequest,
              password: 'export-password',
            );

        final state = container.read(dataExportControllerProvider).value;
        expect(state, isNotNull);
        expect(state!.id, 'req-first');
        expect(state.status, DataExportRequestDataStatusEnum.processing);
      },
    );
  });

  group('refresh', () {
    test('re-fetches latest and updates state', () async {
      container = buildContainer();

      await container.read(dataExportControllerProvider.future);
      expect(container.read(dataExportControllerProvider).value?.id, 'req-1');

      // Simulate a new request appearing on the server.
      fakeApi.latestResponse = _buildLatestResponse(
        id: 'req-3',
        status: DataExportRequestDataStatusEnum.processing,
      );

      await container.read(dataExportControllerProvider.notifier).refresh();

      final state = container.read(dataExportControllerProvider).value;
      expect(state, isNotNull);
      expect(state!.id, 'req-3');
      expect(state.status, DataExportRequestDataStatusEnum.processing);
      expect(fakeApi.getLatestCallCount, 2);
    });

    test('propagates DioException when latest becomes null', () async {
      container = buildContainer();

      await container.read(dataExportControllerProvider.future);
      expect(container.read(dataExportControllerProvider).value, isNotNull);

      fakeApi.latestReturnsNullData = true;

      expect(
        () => container.read(dataExportControllerProvider.notifier).refresh(),
        throwsA(isA<DioException>()),
      );
    });

    test('propagates DioException when GET fails', () async {
      container = buildContainer();

      await container.read(dataExportControllerProvider.future);

      fakeApi.getLatestException = DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/user/data-export-requests/latest',
        ),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        () => container.read(dataExportControllerProvider.notifier).refresh(),
        throwsA(isA<DioException>()),
      );

      // State remains from the last successful load.
      expect(container.read(dataExportControllerProvider).value?.id, 'req-1');
    });
  });

  group('request → refresh flow', () {
    test(
      'requestExport then refresh reflects server-side processing',
      () async {
        container = buildContainer();

        await container.read(dataExportControllerProvider.future);

        // Step 1: Submit export request.
        fakeApi.createResponse = _buildCreateResponse(
          id: 'req-4',
          status: DataExportRequestDataStatusEnum.requested,
        );
        await container
            .read(dataExportControllerProvider.notifier)
            .requestExport(
              reviewHospitalPdfLast7DaysExportRequest,
              password: 'export-password',
            );

        expect(
          container.read(dataExportControllerProvider).value?.status,
          DataExportRequestDataStatusEnum.requested,
        );

        // Step 2: Server transitions to processing; refresh picks it up.
        fakeApi.latestResponse = _buildLatestResponse(
          id: 'req-4',
          status: DataExportRequestDataStatusEnum.processing,
        );
        await container.read(dataExportControllerProvider.notifier).refresh();

        expect(
          container.read(dataExportControllerProvider).value?.status,
          DataExportRequestDataStatusEnum.processing,
        );

        // Step 3: Server completes; refresh picks it up.
        fakeApi.latestResponse = _buildLatestResponse(
          id: 'req-4',
          status: DataExportRequestDataStatusEnum.completed,
        );
        await container.read(dataExportControllerProvider.notifier).refresh();

        final finalState = container.read(dataExportControllerProvider).value;
        expect(
          finalState?.status,
          DataExportRequestDataStatusEnum.completed,
        );
        expect(fakeApi.createCallCount, 1);
        expect(fakeApi.getLatestCallCount, 3); // build + 2 refreshes
      },
    );
  });

  group('dataExportUiStatusForRequest', () {
    test(
      'maps completed request without download url to completedLinkMissing',
      () {
        final request = DataExportRequestData(
          id: 'req-link-missing',
          kind: DataExportRequestDataKindEnum.hospital,
          format: DataExportRequestDataFormatEnum.pdf,
          range: DataExportRequestDataRangeEnum.last7Days,
          status: DataExportRequestDataStatusEnum.completed,
          requestedAt: '2026-06-12T00:00:00.000Z',
          completedAt: '2026-06-12T00:01:00.000Z',
          downloadUrl: '',
          fileName: null,
          fileSizeBytes: null,
          errorMessage: null,
        );

        expect(
          dataExportUiStatusForRequest(request),
          DataExportUiStatus.completedLinkMissing,
        );
      },
    );
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Response<T> _response<T>(T data) => Response<T>(
  data: data,
  requestOptions: RequestOptions(path: ''),
  statusCode: 200,
);

DataExportRequestData _buildRequestData({
  String id = 'req-1',
  DataExportRequestDataStatusEnum status =
      DataExportRequestDataStatusEnum.completed,
}) {
  return DataExportRequestData(
    id: id,
    kind: DataExportRequestDataKindEnum.hospital,
    format: DataExportRequestDataFormatEnum.pdf,
    range: DataExportRequestDataRangeEnum.last7Days,
    status: status,
    requestedAt: '2026-06-12T00:00:00.000Z',
    completedAt: status == DataExportRequestDataStatusEnum.completed
        ? '2026-06-12T00:01:00.000Z'
        : null,
    downloadUrl: status == DataExportRequestDataStatusEnum.completed
        ? 'https://example.com/export.csv'
        : null,
    errorMessage: status == DataExportRequestDataStatusEnum.failed
        ? 'Export failed'
        : null,
    fileName: status == DataExportRequestDataStatusEnum.completed
        ? 'export.csv'
        : null,
    fileSizeBytes: status == DataExportRequestDataStatusEnum.completed
        ? 1024
        : null,
  );
}

DataExportRequestResponse _buildCreateResponse({
  String id = 'req-2',
  DataExportRequestDataStatusEnum status =
      DataExportRequestDataStatusEnum.requested,
}) {
  return DataExportRequestResponse.fromJson(
    _buildRequestData(id: id, status: status).toJson(),
  );
}

DataExportRequestData _buildLatestResponse({
  String id = 'req-1',
  DataExportRequestDataStatusEnum status =
      DataExportRequestDataStatusEnum.completed,
}) {
  return _buildRequestData(id: id, status: status);
}

// ---------------------------------------------------------------------------
// Fake API
// ---------------------------------------------------------------------------

class _FakeDataExportApi implements DataExportApi {
  _FakeDataExportApi({
    this.latestReturnsNullData = false,
    this.getLatestException,
    this.createDelay = Duration.zero,
  });

  // GET latest state.
  int getLatestCallCount = 0;
  DataExportRequestData? latestResponse;
  bool latestReturnsNullData = false;
  bool getLatestReturnsNullResponse = false;
  DioException? getLatestException;

  // POST create state.
  int createCallCount = 0;
  DataExportRequestResponse createResponse = _buildCreateResponse();
  bool createReturnsNull = false;
  DioException? createException;
  CreateRequestRequest? lastCreateRequest;
  Duration createDelay;

  @override
  Future<Response<DataExportRequestData>>
  getLatestRequest({
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    getLatestCallCount++;
    if (getLatestException != null) {
      throw getLatestException!;
    }
    if (getLatestReturnsNullResponse) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/user/data-export-requests/latest',
        ),
      );
    }
    if (latestReturnsNullData) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/user/data-export-requests/latest',
        ),
      );
    }
    return _response(latestResponse ?? _buildRequestData());
  }

  @override
  Future<Response<DataExportRequestResponse>>
  createRequest({
    required CreateRequestRequest
    createRequestRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    createCallCount++;
    lastCreateRequest = createRequestRequest;
    if (createException != null) {
      throw createException!;
    }
    if (createDelay > Duration.zero) {
      await Future<void>.delayed(createDelay);
    }
    if (createReturnsNull) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/user/data-export-requests',
        ),
      );
    }
    return _response(createResponse);
  }
}

class _FakeLucentApi extends LucentApi {
  _FakeLucentApi({required this.dataExportApi}) : super();

  final DataExportApi dataExportApi;

  @override
  DataExportApi getDataExportApi() => dataExportApi;
}
