import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/settings/presentation/providers/data_export_controller.dart';

void main() {
  late _FakeDataExportApi fakeApi;
  late ProviderContainer container;

  ProviderContainer buildContainer({_FakeDataExportApi? api}) {
    final fake = api ?? _FakeDataExportApi();
    fakeApi = fake;
    final c = ProviderContainer(
      overrides: [lucentDataExportApiProvider.overrideWithValue(fake)],
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
      expect(state.status, DataExportStatus.completed);
      expect(state.downloadUrl, 'https://example.com/export.csv');
      expect(fakeApi.getLatestCallCount, 1);
    });

    test('yields null state when no previous request exists', () async {
      container = buildContainer(
        api: _FakeDataExportApi(latestReturnsNullData: true),
      );

      final state = await container.read(dataExportControllerProvider.future);

      expect(state, isNull);
      expect(fakeApi.getLatestCallCount, 1);
    });

    test('propagates DioException from GET', () async {
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

      container.read(dataExportControllerProvider);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(dataExportControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<DioException>());
    });

    test('yields null state when GET response data is null', () async {
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
        status: DataExportStatus.requested,
      );

      await container
          .read(dataExportControllerProvider.notifier)
          .requestExport();

      final state = container.read(dataExportControllerProvider).value;
      expect(state, isNotNull);
      expect(state!.id, 'req-2');
      expect(state.status, DataExportStatus.requested);
      expect(fakeApi.createCallCount, 1);
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
            .requestExport(),
        throwsA(isA<DioException>()),
      );

      // State should remain from the initial load.
      final state = container.read(dataExportControllerProvider);
      expect(state.value?.id, 'req-1');
    });

    test('sets null state when POST response data is null', () async {
      container = buildContainer();

      await container.read(dataExportControllerProvider.future);

      fakeApi.createReturnsNull = true;

      await container
          .read(dataExportControllerProvider.notifier)
          .requestExport();

      final state = container.read(dataExportControllerProvider).value;
      expect(state, isNull);
    });

    test('with no prior request creates and updates state from null', () async {
      container = buildContainer(
        api: _FakeDataExportApi(latestReturnsNullData: true),
      );

      await container.read(dataExportControllerProvider.future);
      expect(container.read(dataExportControllerProvider).value, isNull);

      fakeApi.createResponse = _buildCreateResponse(
        id: 'req-first',
        status: DataExportStatus.processing,
      );

      await container
          .read(dataExportControllerProvider.notifier)
          .requestExport();

      final state = container.read(dataExportControllerProvider).value;
      expect(state, isNotNull);
      expect(state!.id, 'req-first');
      expect(state.status, DataExportStatus.processing);
    });
  });

  group('refresh', () {
    test('re-fetches latest and updates state', () async {
      container = buildContainer();

      await container.read(dataExportControllerProvider.future);
      expect(container.read(dataExportControllerProvider).value?.id, 'req-1');

      // Simulate a new request appearing on the server.
      fakeApi.latestResponse = _buildLatestResponse(
        id: 'req-3',
        status: DataExportStatus.processing,
      );

      await container.read(dataExportControllerProvider.notifier).refresh();

      final state = container.read(dataExportControllerProvider).value;
      expect(state, isNotNull);
      expect(state!.id, 'req-3');
      expect(state.status, DataExportStatus.processing);
      expect(fakeApi.getLatestCallCount, 2);
    });

    test('clears state when latest becomes null', () async {
      container = buildContainer();

      await container.read(dataExportControllerProvider.future);
      expect(container.read(dataExportControllerProvider).value, isNotNull);

      fakeApi.latestReturnsNullData = true;

      await container.read(dataExportControllerProvider.notifier).refresh();

      expect(container.read(dataExportControllerProvider).value, isNull);
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
          status: DataExportStatus.requested,
        );
        await container
            .read(dataExportControllerProvider.notifier)
            .requestExport();

        expect(
          container.read(dataExportControllerProvider).value?.status,
          DataExportStatus.requested,
        );

        // Step 2: Server transitions to processing; refresh picks it up.
        fakeApi.latestResponse = _buildLatestResponse(
          id: 'req-4',
          status: DataExportStatus.processing,
        );
        await container.read(dataExportControllerProvider.notifier).refresh();

        expect(
          container.read(dataExportControllerProvider).value?.status,
          DataExportStatus.processing,
        );

        // Step 3: Server completes; refresh picks it up.
        fakeApi.latestResponse = _buildLatestResponse(
          id: 'req-4',
          status: DataExportStatus.completed,
        );
        await container.read(dataExportControllerProvider.notifier).refresh();

        final finalState = container.read(dataExportControllerProvider).value;
        expect(finalState?.status, DataExportStatus.completed);
        expect(fakeApi.createCallCount, 1);
        expect(fakeApi.getLatestCallCount, 3); // build + 2 refreshes
      },
    );
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

DataExportRequestDataDto _buildRequestData({
  String id = 'req-1',
  DataExportStatus status = DataExportStatus.completed,
}) {
  return DataExportRequestDataDto(
    id: id,
    status: status,
    requestedAt: '2026-06-12T00:00:00.000Z',
    completedAt: status == DataExportStatus.completed
        ? '2026-06-12T00:01:00.000Z'
        : null,
    downloadUrl: status == DataExportStatus.completed
        ? 'https://example.com/export.csv'
        : null,
    errorMessage: status == DataExportStatus.failed ? 'Export failed' : null,
  );
}

DataExportRequestResponseDto _buildCreateResponse({
  String id = 'req-2',
  DataExportStatus status = DataExportStatus.requested,
}) {
  return DataExportRequestResponseDto(
    code: 0,
    message: 'ok',
    data: _buildRequestData(id: id, status: status),
  );
}

DataExportLatestResponseDto _buildLatestResponse({
  String id = 'req-1',
  DataExportStatus status = DataExportStatus.completed,
}) {
  return DataExportLatestResponseDto(
    code: 0,
    message: 'ok',
    data: _buildRequestData(id: id, status: status),
  );
}

// ---------------------------------------------------------------------------
// Fake API
// ---------------------------------------------------------------------------

class _FakeDataExportApi extends DataExportApi {
  _FakeDataExportApi({
    this.latestReturnsNullData = false,
    this.getLatestException,
  }) : super(Dio());

  // GET latest state.
  int getLatestCallCount = 0;
  DataExportLatestResponseDto? latestResponse;
  bool latestReturnsNullData = false;
  bool getLatestReturnsNullResponse = false;
  DioException? getLatestException;

  // POST create state.
  int createCallCount = 0;
  DataExportRequestResponseDto createResponse = _buildCreateResponse();
  bool createReturnsNull = false;
  DioException? createException;

  @override
  Future<Response<DataExportLatestResponseDto>>
  dataExportControllerGetLatestRequestV1({
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
      return Response<DataExportLatestResponseDto>(
        data: null,
        requestOptions: RequestOptions(
          path: '/api/v1/user/data-export-requests/latest',
        ),
        statusCode: 200,
      );
    }
    return Response<DataExportLatestResponseDto>(
      data: latestReturnsNullData
          ? null
          : (latestResponse ??
                DataExportLatestResponseDto(
                  code: 0,
                  message: 'ok',
                  data: _buildRequestData(),
                )),
      requestOptions: RequestOptions(
        path: '/api/v1/user/data-export-requests/latest',
      ),
      statusCode: 200,
    );
  }

  @override
  Future<Response<DataExportRequestResponseDto>>
  dataExportControllerCreateRequestV1({
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    createCallCount++;
    if (createException != null) {
      throw createException!;
    }
    return Response<DataExportRequestResponseDto>(
      data: createReturnsNull ? null : createResponse,
      requestOptions: RequestOptions(path: '/api/v1/user/data-export-requests'),
      statusCode: 200,
    );
  }
}
