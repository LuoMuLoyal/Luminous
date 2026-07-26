import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/support/data/providers/resources.dart';

Response<T> _response<T>(T data) => Response<T>(
  data: data,
  requestOptions: RequestOptions(path: ''),
  statusCode: 200,
);

/// Fake SupportResourcesApi that returns canned responses.
class FakeSupportResourcesApi extends SupportResourcesApi {
  FakeSupportResourcesApi({this.resourcesResponse, this.appInfoResponse})
    : super(Dio());

  final SupportResourceListResponseDto? resourcesResponse;
  final AppInfoResponseDto? appInfoResponse;

  @override
  Future<Response<SupportResourceListResponseDto>>
  supportResourcesControllerGetResourcesV1({
    String? scope,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (resourcesResponse == null) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/public/support-resources',
        ),
      );
    }
    return _response(resourcesResponse!);
  }

  @override
  Future<Response<AppInfoResponseDto>> supportResourcesControllerGetAppInfoV1({
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (appInfoResponse == null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/public/app-info'),
      );
    }
    return _response(appInfoResponse!);
  }
}

void main() {
  group('supportResourcesProvider', () {
    test('returns resources filtered by scope', () async {
      final fakeApi = FakeSupportResourcesApi(
        resourcesResponse: SupportResourceListResponseDto(
          code: 0,
          message: '',
          data: SupportResourceListDataDto(
            items: <SupportResourceDto>[
              SupportResourceDto(
                id: 'res-1',
                scope: SupportResourceScope.help,
                title: 'FAQ',
                available: true,
              ),
              SupportResourceDto(
                id: 'res-2',
                scope: SupportResourceScope.help,
                title: 'Contact Us',
                available: true,
              ),
            ],
            updatedAt: '2026-06-01T00:00:00.000Z',
          ),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(supportResourcesApi: fakeApi),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        supportResourcesProvider('help').future,
      );

      expect(result, hasLength(2));
      expect(result[0].title, equals('FAQ'));
      expect(result[1].title, equals('Contact Us'));
    });

    test('throws when response data is null', () async {
      final fakeApi = FakeSupportResourcesApi(resourcesResponse: null);

      final container = ProviderContainer(
        overrides: [
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(supportResourcesApi: fakeApi),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Keep the autoDispose provider alive during the async operation.
      final sub = container.listen(
        supportResourcesProvider('about'),
        (_, __) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = sub.read();
      expect(state.hasError, isTrue);
      expect(state.error, isA<DioException>());
    });

    test('passes the scope parameter to the API', () async {
      String? capturedScope;
      final capturingApi = _CapturingSupportResourcesApi(
        onGetResources: (String? scope) {
          capturedScope = scope;
        },
      );

      final container = ProviderContainer(
        overrides: [
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(supportResourcesApi: capturingApi),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(supportResourcesProvider('help').future);

      expect(capturedScope, equals('help'));
    });
  });

  group('appInfoProvider', () {
    test('returns app info data DTO', () async {
      final fakeApi = FakeSupportResourcesApi(
        appInfoResponse: AppInfoResponseDto(
          code: 0,
          message: '',
          data: AppInfoDataDto(
            name: 'Lumos',
            version: '1.0.0',
            description: 'Health tracking platform',
            buildDate: '2026-06-01T00:00:00.000Z',
            supportEmail: 'support@lumos.app',
          ),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(supportResourcesApi: fakeApi),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(appInfoProvider.future);

      expect(result, isNotNull);
      expect(result!.name, equals('Lumos'));
      expect(result.version, equals('1.0.0'));
      expect(result.supportEmail, equals('support@lumos.app'));
    });

    test('throws when response data is null', () async {
      final fakeApi = FakeSupportResourcesApi(appInfoResponse: null);

      final container = ProviderContainer(
        overrides: [
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(supportResourcesApi: fakeApi),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Keep the autoDispose provider alive during the async operation.
      final sub = container.listen(appInfoProvider, (_, __) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = sub.read();
      expect(state.hasError, isTrue);
      expect(state.error, isA<DioException>());
    });
  });
}

/// A [LucentClient] subclass that returns a fake [SupportResourcesApi].
class _FakeLucentClient extends LucentClient {
  _FakeLucentClient({required this.supportResourcesApi})
    : super(LucentApi(dio: Dio()));

  final SupportResourcesApi supportResourcesApi;

  @override
  SupportResourcesApi get supportResources => supportResourcesApi;
}

/// A fake that captures method calls without constructing canned response DTOs.
class _CapturingSupportResourcesApi extends SupportResourcesApi {
  _CapturingSupportResourcesApi({this.onGetResources}) : super(Dio());

  final void Function(String? scope)? onGetResources;

  @override
  Future<Response<SupportResourceListResponseDto>>
  supportResourcesControllerGetResourcesV1({
    String? scope,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    onGetResources?.call(scope);
    return _response(
      SupportResourceListResponseDto(
        code: 0,
        message: '',
        data: SupportResourceListDataDto(
          items: <SupportResourceDto>[],
          updatedAt: '2026-06-01T00:00:00.000Z',
        ),
      ),
    );
  }

  @override
  Future<Response<AppInfoResponseDto>> supportResourcesControllerGetAppInfoV1({
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/public/app-info'),
    );
  }
}
