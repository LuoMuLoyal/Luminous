import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/support/data/providers/support_resources_providers.dart';

/// Fake SupportResourcesApi that returns canned responses.
class FakeSupportResourcesApi implements SupportResourcesApi {
  FakeSupportResourcesApi({this.resourcesResponse, this.appInfoResponse});

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
    return Response<SupportResourceListResponseDto>(
      data: resourcesResponse,
      requestOptions: RequestOptions(path: '/api/v1/public/support-resources'),
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
    return Response<AppInfoResponseDto>(
      data: appInfoResponse,
      requestOptions: RequestOptions(path: '/api/v1/public/app-info'),
    );
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
          lucentSupportResourcesApiProvider.overrideWithValue(fakeApi),
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

    test('returns empty list when response data is null', () async {
      final fakeApi = FakeSupportResourcesApi(resourcesResponse: null);

      final container = ProviderContainer(
        overrides: [
          lucentSupportResourcesApiProvider.overrideWithValue(fakeApi),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        supportResourcesProvider('about').future,
      );

      expect(result, isEmpty);
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
          lucentSupportResourcesApiProvider.overrideWithValue(capturingApi),
        ],
      );
      addTearDown(container.dispose);

      await container.read(supportResourcesProvider('campus').future);

      expect(capturedScope, equals('campus'));
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
          lucentSupportResourcesApiProvider.overrideWithValue(fakeApi),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(appInfoProvider.future);

      expect(result, isNotNull);
      expect(result!.name, equals('Lumos'));
      expect(result.version, equals('1.0.0'));
      expect(result.supportEmail, equals('support@lumos.app'));
    });

    test('returns null when response data is null', () async {
      final fakeApi = FakeSupportResourcesApi(appInfoResponse: null);

      final container = ProviderContainer(
        overrides: [
          lucentSupportResourcesApiProvider.overrideWithValue(fakeApi),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(appInfoProvider.future);

      expect(result, isNull);
    });
  });
}

/// A fake that captures method calls without constructing canned response DTOs.
class _CapturingSupportResourcesApi implements SupportResourcesApi {
  _CapturingSupportResourcesApi({this.onGetResources});

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
    return Response<SupportResourceListResponseDto>(
      data: SupportResourceListResponseDto(
        code: 0,
        message: '',
        data: SupportResourceListDataDto(
          items: <SupportResourceDto>[],
          updatedAt: '2026-06-01T00:00:00.000Z',
        ),
      ),
      requestOptions: RequestOptions(path: '/api/v1/public/support-resources'),
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
    return Response<AppInfoResponseDto>(
      data: null,
      requestOptions: RequestOptions(path: '/api/v1/public/app-info'),
    );
  }
}
