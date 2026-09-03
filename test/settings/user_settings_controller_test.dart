import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/client/dio_client.dart';
import 'package:luminous/core/network/contract/error_code.dart';
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

    test('throws a network failure when API returns an empty body', () async {
      final api = _FakeUserSettingsApi()..getReturnsNullResponse = true;
      container = buildContainer(api: api);

      // Trigger build; the provider should transition to AsyncError.
      container.read(userSettingsControllerProvider);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(userSettingsControllerProvider);
      expect(state.hasError, isTrue);
      final failure = state.error;
      expect(failure, isA<LucentFailure>());
      expect((failure as LucentFailure).kind, LucentFailureKind.network);
      expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
    });

    test('propagates DioException from API as LucentFailure', () async {
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
      expect(state.error, isA<LucentFailure>());
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
        throwsA(isA<LucentFailure>()),
      );

      // State remains from the successful initial load.
      final state = container.read(userSettingsControllerProvider);
      expect(state.value?.aiSummariesEnabled, isFalse);
      expect(state.value?.dataSharingConsent, isTrue);
    });

    test(
      'propagates network failure when patch response body is empty',
      () async {
        container = buildContainer();

        await container.read(userSettingsControllerProvider.future);

        fakeApi.patchReturnsNull = true;

        await expectLater(
          container
              .read(userSettingsControllerProvider.notifier)
              .setAiSummariesEnabled(true),
          throwsA(
            isA<LucentFailure>()
                .having(
                  (failure) => failure.kind,
                  'kind',
                  LucentFailureKind.network,
                )
                .having(
                  (failure) => failure.networkErrorCode,
                  'networkErrorCode',
                  NetworkErrorCode.emptyResponse,
                ),
          ),
        );
      },
    );
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
        throwsA(isA<LucentFailure>()),
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
          assistantContext: UserSettingsResponseDtoAssistantContext(
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
          assistantContext: UserSettingsResponseDtoAssistantContext(
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
          assistantContext: UserSettingsResponseDtoAssistantContext(
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

Response<T> _response<T>(T? data) => Response<T>(
  data: data,
  requestOptions: RequestOptions(path: ''),
  statusCode: 200,
);

UserSettingsResponseDto _buildResponse({
  bool aiSummariesEnabled = false,
  bool dataSharingConsent = false,
  bool assistantEnabled = true,
  bool assistantMemoryEnabled = false,
  UserSettingsResponseDtoAssistantContext? assistantContext,
}) {
  return UserSettingsResponseDto(
    aiSummariesEnabled: aiSummariesEnabled,
    dataSharingConsent: dataSharingConsent,
    assistantEnabled: assistantEnabled,
    assistantMemoryEnabled: assistantMemoryEnabled,
    waterTargetCount: 8,
    assistantContext:
        assistantContext ??
        UserSettingsResponseDtoAssistantContext(
          healthProfile: true,
          dailyRecords: true,
          sleepRecords: true,
          currentMedicines: true,
        ),
    updatedAt: '2026-06-12T00:00:00.000Z',
    passwordReauthenticationRequired: false,
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
    aiSummariesEnabled: false,
    dataSharingConsent: true,
    assistantEnabled: true,
    assistantMemoryEnabled: false,
    waterTargetCount: 8,
    assistantContext: UserSettingsResponseDtoAssistantContext(
      healthProfile: true,
      dailyRecords: true,
      sleepRecords: true,
      currentMedicines: true,
    ),
    updatedAt: '2026-06-12T00:00:00.000Z',
    passwordReauthenticationRequired: false,
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
  UserSettingsControllerUpdateSettingsV1Request? lastPatchDto;

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
      // HTTP 200 with an empty body: the generated client leaves
      // response.data null, so the repository throws a network failure.
      return _response<UserSettingsResponseDto>(null);
    }
    return _response(_getResponseData ?? _defaultResponse());
  }

  @override
  Future<Response<UserSettingsResponseDto>>
  userSettingsControllerUpdateSettingsV1({
    required UserSettingsControllerUpdateSettingsV1Request
    userSettingsControllerUpdateSettingsV1Request,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    patchCallCount++;
    lastPatchDto = userSettingsControllerUpdateSettingsV1Request;
    if (patchException != null) {
      throw patchException!;
    }
    if (patchReturnsNull) {
      // HTTP 200 with an empty body: response.data is null.
      return _response<UserSettingsResponseDto>(null);
    }
    return _response(patchResponse);
  }
}

class _FakeLucentApi extends LucentApi {
  _FakeLucentApi({required this.userSettingsApi}) : super();

  final UserSettingsApi userSettingsApi;

  @override
  UserSettingsApi getUserSettingsApi() => userSettingsApi;
}
