import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';

void main() {
  late _FakeUserSettingsApi fakeApi;
  late ProviderContainer container;

  ProviderContainer buildContainer({_FakeUserSettingsApi? api}) {
    final fake = api ?? _FakeUserSettingsApi();
    fakeApi = fake;
    final c = ProviderContainer(
      overrides: [
        lucentClientProvider.overrideWithValue(
          _FakeLucentClient(userSettingsApi: fake),
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
          assistantContext: const AssistantContextSettingsDto(
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
          assistantContext: const AssistantContextSettingsDto(
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

        final nextContext = const UpdateAssistantContextSettingsDto(
          healthProfile: false,
          dailyRecords: true,
          sleepRecords: false,
          currentMedicines: true,
        );

        fakeApi.patchResponse = _buildResponse(
          aiSummariesEnabled: false,
          dataSharingConsent: true,
          assistantEnabled: true,
          assistantContext: const AssistantContextSettingsDto(
            healthProfile: false,
            dailyRecords: true,
            sleepRecords: false,
            currentMedicines: true,
          ),
        );

        await container
            .read(userSettingsControllerProvider.notifier)
            .setAssistantContext(nextContext);

        final state = container.read(userSettingsControllerProvider);
        expect(state.value?.assistantContext.healthProfile, isFalse);
        expect(state.value?.assistantContext.dailyRecords, isTrue);
        expect(state.value?.assistantContext.sleepRecords, isFalse);
        expect(state.value?.assistantContext.currentMedicines, isTrue);
        expect(fakeApi.lastPatchDto?.assistantEnabled, isTrue);
        expect(fakeApi.lastPatchDto?.assistantContext.healthProfile, isFalse);
        expect(fakeApi.lastPatchDto?.assistantContext.dailyRecords, isTrue);
        expect(fakeApi.lastPatchDto?.assistantContext.sleepRecords, isFalse);
        expect(fakeApi.lastPatchDto?.assistantContext.currentMedicines, isTrue);
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
          const AssistantContextSettingsDto(
            healthProfile: true,
            dailyRecords: true,
            sleepRecords: true,
            currentMedicines: true,
          ),
      updatedAt: '2026-06-12T00:00:00.000Z',
      securityPin: const SecurityPinSettingsDto(
        enabled: false,
        lastChangedAt: null,
      ),
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

  static UserSettingsResponseDto _defaultResponse() =>
      const UserSettingsResponseDto(
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
          securityPin: SecurityPinSettingsDto(
            enabled: false,
            lastChangedAt: null,
          ),
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
  Future<UserSettingsResponseDto> userSettingsControllerGetSettingsV1() async {
    getCallCount++;
    if (getException != null) {
      throw getException!;
    }
    if (getReturnsNullResponse) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/user/settings'),
      );
    }
    return _getResponseData ?? _defaultResponse();
  }

  @override
  Future<UserSettingsResponseDto> userSettingsControllerUpdateSettingsV1({
    required UpdateUserSettingsDto body,
  }) async {
    patchCallCount++;
    lastPatchDto = body;
    if (patchException != null) {
      throw patchException!;
    }
    if (patchReturnsNull) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/user/settings'),
      );
    }
    return patchResponse;
  }

  @override
  Future<UserSettingsResponseDto> userSettingsControllerEnableSecurityPinV1({
    required EnableSecurityPinDto body,
  }) async => _defaultResponse();

  @override
  Future<SecurityPinElevationResponseDto>
  userSettingsControllerVerifySecurityPinV1({
    required VerifySecurityPinDto body,
  }) async => const SecurityPinElevationResponseDto(
    elevationToken: 'token',
    expiresAt: '2026-06-12T01:00:00.000Z',
  );

  @override
  Future<UserSettingsResponseDto> userSettingsControllerChangeSecurityPinV1({
    required ChangeSecurityPinDto body,
  }) async => _defaultResponse();

  @override
  Future<UserSettingsResponseDto> userSettingsControllerDisableSecurityPinV1({
    required DisableSecurityPinDto body,
  }) async => _defaultResponse();
}

/// A [LucentClient] subclass that returns a fake [UserSettingsApi].
class _FakeLucentClient extends LucentClient {
  _FakeLucentClient({required this.userSettingsApi}) : super(Dio());

  final UserSettingsApi userSettingsApi;

  @override
  UserSettingsApi get userSettings => userSettingsApi;
}
