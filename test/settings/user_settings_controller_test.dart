import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';

import '../helpers/test_helpers.dart';

void main() {
  late _FakeUserSettingsApi fakeApi;
  late ProviderContainer container;

  ProviderContainer buildContainer({_FakeUserSettingsApi? api}) {
    final fake = api ?? _FakeUserSettingsApi();
    fakeApi = fake;
    final c = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        lucentClientProvider.overrideWithValue(
          LucentClient(_FakeLucentApi(userSettingsApi: fake)),
        ),
      ],
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
      expect(state.error, isA<DioException>());
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
      expect(fakeApi.lastPatchDto?.dataSharingConsent, isTrue);
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
        throwsA(isA<DioException>()),
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
      expect(fakeApi.lastPatchDto?.aiSummariesEnabled, isFalse);
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
    test(
      'setAssistantEnabled patches settings and updates state on success',
      () async {
        container = buildContainer();

        await container.read(userSettingsControllerProvider.future);

        fakeApi.patchResponse = _buildResponse(
          aiSummariesEnabled: false,
          dataSharingConsent: true,
          assistantEnabled: false,
          assistantContext: AssistantContextSettingsDto(
            healthProfile: true,
            dailyRecords: true,
            sleepRecords: true,
            currentMedicines: true,
          ),
        );

        await container
            .read(userSettingsControllerProvider.notifier)
            .setAssistantEnabled(false);

        final state = container.read(userSettingsControllerProvider);
        expect(state.value?.assistantEnabled, isFalse);
        expect(fakeApi.lastPatchDto?.assistantEnabled, isFalse);
        expect(fakeApi.lastPatchDto?.assistantContext, isNotNull);
      },
    );

    test(
      'setAssistantMemoryEnabled patches settings and updates state on success',
      () async {
        container = buildContainer();

        await container.read(userSettingsControllerProvider.future);

        fakeApi.patchResponse = _buildResponse(
          aiSummariesEnabled: false,
          dataSharingConsent: true,
          assistantEnabled: true,
          assistantMemoryEnabled: true,
          assistantContext: AssistantContextSettingsDto(
            healthProfile: true,
            dailyRecords: true,
            sleepRecords: true,
            currentMedicines: true,
          ),
        );

        await container
            .read(userSettingsControllerProvider.notifier)
            .setAssistantMemoryEnabled(true);

        final state = container.read(userSettingsControllerProvider);
        expect(state.value?.assistantMemoryEnabled, isTrue);
        expect(fakeApi.lastPatchDto?.assistantMemoryEnabled, isTrue);
      },
    );

    test(
      'setAssistantContext patches context fields and updates state on success',
      () async {
        container = buildContainer();

        await container.read(userSettingsControllerProvider.future);

        const nextContext = AssistantContextPatch(
          healthProfile: false,
          dailyRecords: true,
          sleepRecords: false,
          currentMedicines: true,
        );

        fakeApi.patchResponse = _buildResponse(
          aiSummariesEnabled: false,
          dataSharingConsent: true,
          assistantEnabled: true,
          assistantContext: AssistantContextSettingsDto(
            healthProfile: false,
            dailyRecords: true,
            sleepRecords: false,
            currentMedicines: true,
          ),
        );

        await container
            .read(userSettingsControllerProvider.notifier)
            .setAssistantContext(nextContext);

        final state = container.read(userSettingsControllerProvider).value!;
        expect(state.assistantContext.healthProfile, isFalse);
        expect(state.assistantContext.dailyRecords, isTrue);
        expect(state.assistantContext.sleepRecords, isFalse);
        expect(state.assistantContext.currentMedicines, isTrue);

        final patchDto = fakeApi.lastPatchDto!;
        expect(patchDto.assistantEnabled, isTrue);
        expect(patchDto.assistantContext!.healthProfile, isFalse);
        expect(patchDto.assistantContext!.dailyRecords, isTrue);
        expect(patchDto.assistantContext!.sleepRecords, isFalse);
        expect(patchDto.assistantContext!.currentMedicines, isTrue);
      },
    );
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

Response<T> _response<T>(T data) => Response<T>(
  data: data,
  requestOptions: RequestOptions(path: ''),
  statusCode: 200,
);

UserSettingsResponseDto _buildResponse({
  bool aiSummariesEnabled = false,
  bool dataSharingConsent = false,
  bool assistantEnabled = true,
  bool assistantMemoryEnabled = false,
  AssistantContextSettingsDto? assistantContext,
}) {
  return UserSettingsResponseDto(
    code: 0,
    message: 'ok',
    data: UserSettingsDataDto(
      aiSummariesEnabled: aiSummariesEnabled,
      dataSharingConsent: dataSharingConsent,
      assistantEnabled: assistantEnabled,
      assistantMemoryEnabled: assistantMemoryEnabled,
      waterTargetCount: 8,
      assistantContext:
          assistantContext ??
          AssistantContextSettingsDto(
            healthProfile: true,
            dailyRecords: true,
            sleepRecords: true,
            currentMedicines: true,
          ),
      updatedAt: '2026-06-12T00:00:00.000Z',
      securityPin: SecurityPinSettingsDto(enabled: false, lastChangedAt: null),
    ),
  );
}

// ---------------------------------------------------------------------------
// Fake API
// ---------------------------------------------------------------------------

class _FakeUserSettingsApi implements UserSettingsApi {
  _FakeUserSettingsApi({
    UserSettingsResponseDto? responseData,
    this.getException,
  }) : _getResponseData = responseData;

  static UserSettingsResponseDto _defaultResponse() => UserSettingsResponseDto(
    code: 0,
    message: 'ok',
    data: UserSettingsDataDto(
      aiSummariesEnabled: false,
      dataSharingConsent: true,
      assistantEnabled: true,
      assistantMemoryEnabled: false,
      waterTargetCount: 8,
      assistantContext: AssistantContextSettingsDto(
        healthProfile: true,
        dailyRecords: true,
        sleepRecords: true,
        currentMedicines: true,
      ),
      updatedAt: '2026-06-12T00:00:00.000Z',
      securityPin: SecurityPinSettingsDto(enabled: false, lastChangedAt: null),
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
    if (getReturnsNullResponse) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/user/settings'),
      );
    }
    return _response(_getResponseData ?? _defaultResponse());
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
    if (patchReturnsNull) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/user/settings'),
      );
    }
    return _response(patchResponse);
  }

  @override
  Future<Response<UserSettingsResponseDto>>
  userSettingsControllerEnableSecurityPinV1({
    required EnableSecurityPinDto enableSecurityPinDto,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async => _response(_defaultResponse());

  @override
  Future<Response<SecurityPinElevationResponseDto>>
  userSettingsControllerVerifySecurityPinV1({
    required VerifySecurityPinDto verifySecurityPinDto,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async => _response(
    SecurityPinElevationResponseDto(
      elevationToken: 'token',
      expiresAt: '2026-06-12T01:00:00.000Z',
    ),
  );

  @override
  Future<Response<UserSettingsResponseDto>>
  userSettingsControllerChangeSecurityPinV1({
    required ChangeSecurityPinDto changeSecurityPinDto,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async => _response(_defaultResponse());

  @override
  Future<Response<UserSettingsResponseDto>>
  userSettingsControllerDisableSecurityPinV1({
    required DisableSecurityPinDto disableSecurityPinDto,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async => _response(_defaultResponse());
}

class _FakeLucentApi extends LucentApi {
  _FakeLucentApi({required this.userSettingsApi}) : super();

  final UserSettingsApi userSettingsApi;

  @override
  UserSettingsApi getUserSettingsApi() => userSettingsApi;
}
