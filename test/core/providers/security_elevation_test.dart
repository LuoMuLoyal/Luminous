import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/core/providers/security_elevation.dart';

import '../../auth/test_helpers.dart' as auth_helpers;

// ── Helpers ────────────────────────────────────────────────────────────────

Response<T> _response<T>(T data) => Response<T>(
  data: data,
  requestOptions: RequestOptions(path: ''),
  statusCode: 200,
);

SecurityPinElevationResponseDto _successResponse({
  String expiresAt = '2030-01-01T00:00:00.000Z',
  String token = 'elevation-token',
}) {
  return SecurityPinElevationResponseDto(
    code: 0,
    message: 'ok',
    data: SecurityPinElevationDataDto(
      elevationToken: token,
      expiresAt: expiresAt,
    ),
  );
}

// ── Fake API ───────────────────────────────────────────────────────────────

class _FakeUserSettingsApi implements UserSettingsApi {
  _FakeUserSettingsApi({this.verifyResponse, this.verifyException});

  /// Response returned by verify; null → the default success response.
  SecurityPinElevationResponseDto? verifyResponse;

  /// When set, verify throws this object instead of returning a response.
  Object? verifyException;

  int verifyCallCount = 0;
  String? lastVerifyPin;

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
  }) async {
    verifyCallCount++;
    lastVerifyPin = verifySecurityPinDto.pin;
    if (verifyException != null) {
      throw verifyException!;
    }
    return _response(verifyResponse ?? _successResponse());
  }

  @override
  Future<Response<UserSettingsResponseDto>>
  userSettingsControllerGetSettingsV1({
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async => _response(
    UserSettingsResponseDto(
      code: 0,
      message: 'ok',
      data: UserSettingsDataDto(
        aiSummariesEnabled: false,
        dataSharingConsent: false,
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
    ),
  );

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
  }) async => _response(
    UserSettingsResponseDto(
      code: 0,
      message: 'ok',
      data: UserSettingsDataDto(
        aiSummariesEnabled: false,
        dataSharingConsent: false,
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
    ),
  );

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
  }) async => _response(
    UserSettingsResponseDto(
      code: 0,
      message: 'ok',
      data: UserSettingsDataDto(
        aiSummariesEnabled: false,
        dataSharingConsent: false,
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
        securityPin: SecurityPinSettingsDto(enabled: true, lastChangedAt: null),
      ),
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
  }) async => _response(
    UserSettingsResponseDto(
      code: 0,
      message: 'ok',
      data: UserSettingsDataDto(
        aiSummariesEnabled: false,
        dataSharingConsent: false,
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
        securityPin: SecurityPinSettingsDto(enabled: true, lastChangedAt: null),
      ),
    ),
  );

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
  }) async => _response(
    UserSettingsResponseDto(
      code: 0,
      message: 'ok',
      data: UserSettingsDataDto(
        aiSummariesEnabled: false,
        dataSharingConsent: false,
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
    ),
  );
}

class _FakeLucentApi extends LucentApi {
  _FakeLucentApi({required this.userSettingsApi}) : super();

  final UserSettingsApi userSettingsApi;

  @override
  UserSettingsApi getUserSettingsApi() => userSettingsApi;
}

void main() {
  late _FakeUserSettingsApi fakeApi;
  late ProviderContainer container;

  ProviderContainer buildContainer({_FakeUserSettingsApi? api}) {
    final fake = api ?? _FakeUserSettingsApi();
    fakeApi = fake;
    final c = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(
          auth_helpers.SignedInAuthSessionNotifier.new,
        ),
        lucentClientProvider.overrideWithValue(
          LucentClient(_FakeLucentApi(userSettingsApi: fake)),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('SecurityElevationController.verify', () {
    test('成功:返回 true,设置提升令牌并进入 Verified 状态', () async {
      container = buildContainer();

      final controller = container.read(
        securityElevationControllerProvider.notifier,
      );
      final ok = await controller.verify('123456');

      expect(ok, isTrue);
      expect(fakeApi.verifyCallCount, 1);
      expect(fakeApi.lastVerifyPin, '123456');
      expect(
        container.read(securityElevationControllerProvider).isVerified,
        isTrue,
      );
      expect(
        container.read(securityElevationTokenHolderProvider).token,
        isNotNull,
      );
    });

    test('expiresAt 非法:返回 false 且不设置提升令牌(拒绝客户端时间兜底)', () async {
      final api = _FakeUserSettingsApi(
        verifyResponse: _successResponse(expiresAt: 'not-a-date'),
      );
      container = buildContainer(api: api);

      final controller = container.read(
        securityElevationControllerProvider.notifier,
      );
      final ok = await controller.verify('123456');

      expect(ok, isFalse);
      expect(
        container.read(securityElevationControllerProvider).isVerified,
        isFalse,
      );
      expect(
        container.read(securityElevationTokenHolderProvider).token,
        isNull,
      );
    });

    test('DioException(网络/HTTP/业务失败):返回 false,不设置提升令牌', () async {
      final api = _FakeUserSettingsApi(
        verifyException: DioException(
          requestOptions: RequestOptions(
            path: '/api/v1/user/settings/security-pin/verify',
          ),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
          ),
        ),
      );
      container = buildContainer(api: api);

      final controller = container.read(
        securityElevationControllerProvider.notifier,
      );
      final ok = await controller.verify('123456');

      expect(ok, isFalse);
      expect(
        container.read(securityElevationControllerProvider).isVerified,
        isFalse,
      );
      expect(
        container.read(securityElevationTokenHolderProvider).token,
        isNull,
      );
    });

    test('业务码非 0(拦截器未生效的调用路径):返回 false', () async {
      final api = _FakeUserSettingsApi(
        verifyResponse: SecurityPinElevationResponseDto(
          code: 401001,
          message: 'pin not enabled',
          data: SecurityPinElevationDataDto(
            elevationToken: 'should-not-be-set',
            expiresAt: '2030-01-01T00:00:00.000Z',
          ),
        ),
      );
      container = buildContainer(api: api);

      final controller = container.read(
        securityElevationControllerProvider.notifier,
      );
      final ok = await controller.verify('123456');

      expect(ok, isFalse);
      expect(
        container.read(securityElevationTokenHolderProvider).token,
        isNull,
      );
    });

    test('意外异常(非可预期类型):记录日志后返回 false,不向上抛', () async {
      final api = _FakeUserSettingsApi(
        verifyException: StateError('unexpected'),
      );
      container = buildContainer(api: api);

      final controller = container.read(
        securityElevationControllerProvider.notifier,
      );
      final ok = await controller.verify('123456');

      expect(ok, isFalse);
      expect(
        container.read(securityElevationControllerProvider).isVerified,
        isFalse,
      );
      expect(
        container.read(securityElevationTokenHolderProvider).token,
        isNull,
      );
    });
  });
}
