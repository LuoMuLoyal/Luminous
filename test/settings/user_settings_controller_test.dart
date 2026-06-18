import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';

void main() {
  late _FakeUserSettingsApi fakeApi;
  late ProviderContainer container;

  ProviderContainer buildContainer({_FakeUserSettingsApi? api}) {
    final fake = api ?? _FakeUserSettingsApi();
    fakeApi = fake;
    final c = ProviderContainer(
      overrides: [lucentUserSettingsApiProvider.overrideWithValue(fake)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('build – initial load', () {
    test('loads settings from API on creation', () async {
      container = buildContainer();

      final state = await container.read(userSettingsControllerProvider.future);

      expect(state.aiSummariesEnabled, isFalse);
      expect(state.dataSharingConsent, isTrue);
      expect(state.updatedAt, '2026-06-12T00:00:00.000Z');
      expect(fakeApi.getCallCount, 1);
    });

    test('throws when API returns null data', () async {
      final api = _FakeUserSettingsApi()..getReturnsNullResponse = true;
      container = buildContainer(api: api);

      // Trigger build; the provider should transition to AsyncError.
      container.read(userSettingsControllerProvider);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(userSettingsControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<StateError>());
    });

    test('propagates DioException from API', () async {
      final api = _FakeUserSettingsApi(
        getException: DioException(
          requestOptions: RequestOptions(path: '/api/v1/user/settings'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      container = buildContainer(api: api);

      container.read(userSettingsControllerProvider);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(userSettingsControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<DioException>());
    });
  });

  group('setAiSummariesEnabled', () {
    test('patches settings and updates state on success', () async {
      container = buildContainer();

      // Wait for initial load.
      await container.read(userSettingsControllerProvider.future);

      // Patch response returns updated state.
      fakeApi.patchResponse = _buildResponse(
        aiSummariesEnabled: true,
        dataSharingConsent: true,
      );

      await container
          .read(userSettingsControllerProvider.notifier)
          .setAiSummariesEnabled(true);

      final state = container.read(userSettingsControllerProvider);
      expect(state.value?.aiSummariesEnabled, isTrue);
      expect(state.value?.dataSharingConsent, isTrue);
      expect(fakeApi.lastPatchDto?.aiSummariesEnabled, isTrue);
      expect(fakeApi.lastPatchDto?.dataSharingConsent, isNull);
      expect(fakeApi.patchCallCount, 1);
    });

    test('disables previously enabled AI summaries', () async {
      container = buildContainer(
        api: _FakeUserSettingsApi(
          responseData: _buildResponse(aiSummariesEnabled: true),
        ),
      );

      await container.read(userSettingsControllerProvider.future);

      fakeApi.patchResponse = _buildResponse(aiSummariesEnabled: false);

      await container
          .read(userSettingsControllerProvider.notifier)
          .setAiSummariesEnabled(false);

      expect(
        container
            .read(userSettingsControllerProvider)
            .value
            ?.aiSummariesEnabled,
        isFalse,
      );
      expect(fakeApi.lastPatchDto?.aiSummariesEnabled, isFalse);
    });

    test('propagates error when API call fails', () async {
      container = buildContainer();

      await container.read(userSettingsControllerProvider.future);

      fakeApi.patchException = DioException(
        requestOptions: RequestOptions(path: '/api/v1/user/settings'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        () => container
            .read(userSettingsControllerProvider.notifier)
            .setAiSummariesEnabled(true),
        throwsA(isA<DioException>()),
      );

      // State remains from the successful initial load.
      final state = container.read(userSettingsControllerProvider);
      expect(state.value?.aiSummariesEnabled, isFalse);
      expect(state.value?.dataSharingConsent, isTrue);
    });

    test('propagates error when patch response data is null', () async {
      container = buildContainer();

      await container.read(userSettingsControllerProvider.future);

      fakeApi.patchReturnsNull = true;

      expect(
        () => container
            .read(userSettingsControllerProvider.notifier)
            .setAiSummariesEnabled(true),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('setDataSharingConsent', () {
    test('patches settings and updates state on success', () async {
      container = buildContainer();

      await container.read(userSettingsControllerProvider.future);

      fakeApi.patchResponse = _buildResponse(
        aiSummariesEnabled: false,
        dataSharingConsent: true,
      );

      await container
          .read(userSettingsControllerProvider.notifier)
          .setDataSharingConsent(true);

      final state = container.read(userSettingsControllerProvider);
      expect(state.value?.dataSharingConsent, isTrue);
      expect(fakeApi.lastPatchDto?.dataSharingConsent, isTrue);
      expect(fakeApi.lastPatchDto?.aiSummariesEnabled, isNull);
      expect(fakeApi.patchCallCount, 1);
    });

    test('revokes previously granted data sharing consent', () async {
      container = buildContainer(
        api: _FakeUserSettingsApi(
          responseData: _buildResponse(dataSharingConsent: true),
        ),
      );

      await container.read(userSettingsControllerProvider.future);

      fakeApi.patchResponse = _buildResponse(dataSharingConsent: false);

      await container
          .read(userSettingsControllerProvider.notifier)
          .setDataSharingConsent(false);

      expect(
        container
            .read(userSettingsControllerProvider)
            .value
            ?.dataSharingConsent,
        isFalse,
      );
    });

    test('propagates error when API call fails', () async {
      container = buildContainer();

      await container.read(userSettingsControllerProvider.future);

      fakeApi.patchException = DioException(
        requestOptions: RequestOptions(path: '/api/v1/user/settings'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        () => container
            .read(userSettingsControllerProvider.notifier)
            .setDataSharingConsent(true),
        throwsA(isA<DioException>()),
      );

      // State should remain from the initial load.
      final state = container.read(userSettingsControllerProvider);
      expect(state.value?.dataSharingConsent, isTrue);
    });
  });

  group('ai chat settings', () {
    test('setAiChatEnabled patches settings and updates state on success', () async {
      container = buildContainer();

      await container.read(userSettingsControllerProvider.future);

      fakeApi.patchResponse = _buildResponse(
        aiSummariesEnabled: false,
        dataSharingConsent: true,
        aiChatEnabled: false,
        aiChatContext: AiChatContextSettingsDto(
          healthProfile: true,
          dailyRecords: true,
          sleepRecords: true,
          currentMedicines: true,
        ),
      );

      await container
          .read(userSettingsControllerProvider.notifier)
          .setAiChatEnabled(false);

      final state = container.read(userSettingsControllerProvider);
      expect(state.value?.aiChatEnabled, isFalse);
      expect(fakeApi.lastPatchDto?.aiChatEnabled, isFalse);
      expect(fakeApi.lastPatchDto?.aiChatContext, isNull);
    });

    test('setAiChatMemoryEnabled patches settings and updates state on success', () async {
      container = buildContainer();

      await container.read(userSettingsControllerProvider.future);

      fakeApi.patchResponse = _buildResponse(
        aiSummariesEnabled: false,
        dataSharingConsent: true,
        aiChatEnabled: true,
        aiChatMemoryEnabled: true,
        aiChatContext: AiChatContextSettingsDto(
          healthProfile: true,
          dailyRecords: true,
          sleepRecords: true,
          currentMedicines: true,
        ),
      );

      await container
          .read(userSettingsControllerProvider.notifier)
          .setAiChatMemoryEnabled(true);

      final state = container.read(userSettingsControllerProvider);
      expect(state.value?.aiChatMemoryEnabled, isTrue);
      expect(fakeApi.lastPatchDto?.aiChatMemoryEnabled, isTrue);
    });

    test('setAiChatContext patches context fields and updates state on success', () async {
      container = buildContainer();

      await container.read(userSettingsControllerProvider.future);

      final nextContext = UpdateAiChatContextSettingsDto(
        healthProfile: false,
        dailyRecords: true,
        sleepRecords: false,
        currentMedicines: true,
      );

      fakeApi.patchResponse = _buildResponse(
        aiSummariesEnabled: false,
        dataSharingConsent: true,
        aiChatEnabled: true,
        aiChatContext: AiChatContextSettingsDto(
          healthProfile: false,
          dailyRecords: true,
          sleepRecords: false,
          currentMedicines: true,
        ),
      );

      await container
          .read(userSettingsControllerProvider.notifier)
          .setAiChatContext(nextContext);

      final state = container.read(userSettingsControllerProvider);
      expect(state.value?.aiChatContext.healthProfile, isFalse);
      expect(state.value?.aiChatContext.dailyRecords, isTrue);
      expect(state.value?.aiChatContext.sleepRecords, isFalse);
      expect(state.value?.aiChatContext.currentMedicines, isTrue);
      expect(fakeApi.lastPatchDto?.aiChatEnabled, isNull);
      expect(fakeApi.lastPatchDto?.aiChatContext?.healthProfile, isFalse);
      expect(fakeApi.lastPatchDto?.aiChatContext?.dailyRecords, isTrue);
      expect(fakeApi.lastPatchDto?.aiChatContext?.sleepRecords, isFalse);
      expect(fakeApi.lastPatchDto?.aiChatContext?.currentMedicines, isTrue);
    });
  });

  group('toggle independence', () {
    test('AI summaries toggle does not affect data sharing consent', () async {
      container = buildContainer();

      await container.read(userSettingsControllerProvider.future);

      fakeApi.patchResponse = _buildResponse(
        aiSummariesEnabled: true,
        dataSharingConsent: true,
      );

      await container
          .read(userSettingsControllerProvider.notifier)
          .setAiSummariesEnabled(true);

      // Patch response should carry both fields back.
      expect(
        container
            .read(userSettingsControllerProvider)
            .value
            ?.aiSummariesEnabled,
        isTrue,
      );
      expect(
        container
            .read(userSettingsControllerProvider)
            .value
            ?.dataSharingConsent,
        isTrue,
      );

      // Now toggle data sharing off.
      fakeApi.patchResponse = _buildResponse(
        aiSummariesEnabled: true,
        dataSharingConsent: false,
      );

      await container
          .read(userSettingsControllerProvider.notifier)
          .setDataSharingConsent(false);

      expect(
        container
            .read(userSettingsControllerProvider)
            .value
            ?.aiSummariesEnabled,
        isTrue,
      );
      expect(
        container
            .read(userSettingsControllerProvider)
            .value
            ?.dataSharingConsent,
        isFalse,
      );
    });
  });

  group('multiple sequential patches', () {
    test('applies patches in order and reflects latest state', () async {
      container = buildContainer();

      await container.read(userSettingsControllerProvider.future);

      fakeApi.patchResponse = _buildResponse(aiSummariesEnabled: true);
      await container
          .read(userSettingsControllerProvider.notifier)
          .setAiSummariesEnabled(true);

      fakeApi.patchResponse = _buildResponse(
        aiSummariesEnabled: true,
        dataSharingConsent: true,
      );
      await container
          .read(userSettingsControllerProvider.notifier)
          .setDataSharingConsent(true);

      fakeApi.patchResponse = _buildResponse(
        aiSummariesEnabled: false,
        dataSharingConsent: true,
      );
      await container
          .read(userSettingsControllerProvider.notifier)
          .setAiSummariesEnabled(false);

      final state = container.read(userSettingsControllerProvider).value;
      expect(state?.aiSummariesEnabled, isFalse);
      expect(state?.dataSharingConsent, isTrue);
      expect(fakeApi.patchCallCount, 3);
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

UserSettingsResponseDto _buildResponse({
  bool aiSummariesEnabled = false,
  bool dataSharingConsent = false,
  bool aiChatEnabled = true,
  bool aiChatMemoryEnabled = false,
  AiChatContextSettingsDto? aiChatContext,
}) {
  return UserSettingsResponseDto(
    code: 0,
    message: 'ok',
    data: UserSettingsDataDto(
      aiSummariesEnabled: aiSummariesEnabled,
      dataSharingConsent: dataSharingConsent,
      aiChatEnabled: aiChatEnabled,
      aiChatMemoryEnabled: aiChatMemoryEnabled,
      aiChatContext:
          aiChatContext ??
          AiChatContextSettingsDto(
            healthProfile: true,
            dailyRecords: true,
            sleepRecords: true,
            currentMedicines: true,
          ),
      updatedAt: '2026-06-12T00:00:00.000Z',
    ),
  );
}

// ---------------------------------------------------------------------------
// Fake API
// ---------------------------------------------------------------------------

class _FakeUserSettingsApi extends UserSettingsApi {
  _FakeUserSettingsApi({
    UserSettingsResponseDto? responseData,
    this.getException,
  }) : _getResponseData = responseData,
       super(Dio());

  static UserSettingsResponseDto _defaultResponse() => UserSettingsResponseDto(
    code: 0,
    message: 'ok',
    data: UserSettingsDataDto(
      aiSummariesEnabled: false,
      dataSharingConsent: true,
      aiChatEnabled: true,
      aiChatMemoryEnabled: false,
      aiChatContext: AiChatContextSettingsDto(
        healthProfile: true,
        dailyRecords: true,
        sleepRecords: true,
        currentMedicines: true,
      ),
      updatedAt: '2026-06-12T00:00:00.000Z',
    ),
  );

  // GET state.
  int getCallCount = 0;
  final UserSettingsResponseDto? _getResponseData;
  bool getReturnsNullResponse = false;
  final DioException? getException;

  // PATCH state.
  int patchCallCount = 0;
  UserSettingsResponseDto patchResponse = _defaultResponse();
  bool patchReturnsNull = false;
  DioException? patchException;
  UpdateUserSettingsDto? lastPatchDto;

  @override
  Future<Response<UserSettingsResponseDto>>
  userSettingsControllerGetSettingsV1({
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    getCallCount++;
    if (getException != null) {
      throw getException!;
    }
    return Response<UserSettingsResponseDto>(
      data: getReturnsNullResponse
          ? null
          : (_getResponseData ?? _defaultResponse()),
      requestOptions: RequestOptions(path: '/api/v1/user/settings'),
      statusCode: 200,
    );
  }

  @override
  Future<Response<UserSettingsResponseDto>>
  userSettingsControllerUpdateSettingsV1({
    required UpdateUserSettingsDto updateUserSettingsDto,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    patchCallCount++;
    lastPatchDto = updateUserSettingsDto;
    if (patchException != null) {
      throw patchException!;
    }
    return Response<UserSettingsResponseDto>(
      data: patchReturnsNull ? null : patchResponse,
      requestOptions: RequestOptions(path: '/api/v1/user/settings'),
      statusCode: 200,
    );
  }
}
