import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/support/data/providers/resources_providers.dart';

/// Fake SupportResourcesApi that returns canned responses.
class FakeSupportResourcesApi implements SupportResourcesApi {
  FakeSupportResourcesApi({this.resourcesResponse, this.appInfoResponse});

  final SupportResourceListResponseDto? resourcesResponse;
  final AppInfoResponseDto? appInfoResponse;

  @override
  Future<SupportResourceListResponseDto>
  supportResourcesControllerGetResourcesV1({Scope? scope}) async {
    if (resourcesResponse == null) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/public/support-resources',
        ),
      );
    }
    return resourcesResponse!;
  }

  @override
  Future<AppInfoResponseDto> supportResourcesControllerGetAppInfoV1() async {
    if (appInfoResponse == null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/public/app-info'),
      );
    }
    return appInfoResponse!;
  }
}

void main() {
  group('supportResourcesProvider', () {
    test('returns resources filtered by scope', () async {
      final fakeApi = FakeSupportResourcesApi(
        resourcesResponse: const SupportResourceListResponseDto(
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

    test('throws when response data is null', () async {
      final fakeApi = FakeSupportResourcesApi(resourcesResponse: null);

      final container = ProviderContainer(
        overrides: [
          lucentSupportResourcesApiProvider.overrideWithValue(fakeApi),
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
      Scope? capturedScope;
      final capturingApi = _CapturingSupportResourcesApi(
        onGetResources: (Scope? scope) {
          capturedScope = scope;
        },
      );

      final container = ProviderContainer(
        overrides: [
          lucentSupportResourcesApiProvider.overrideWithValue(capturingApi),
        ],
      );
      addTearDown(container.dispose);

      await container.read(supportResourcesProvider('help').future);

      expect(capturedScope, equals(Scope.help));
    });
  });

  group('appInfoProvider', () {
    test('returns app info data DTO', () async {
      final fakeApi = FakeSupportResourcesApi(
        appInfoResponse: const AppInfoResponseDto(
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

    test('throws when response data is null', () async {
      final fakeApi = FakeSupportResourcesApi(appInfoResponse: null);

      final container = ProviderContainer(
        overrides: [
          lucentSupportResourcesApiProvider.overrideWithValue(fakeApi),
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

/// A fake that captures method calls without constructing canned response DTOs.
class _CapturingSupportResourcesApi implements SupportResourcesApi {
  _CapturingSupportResourcesApi({this.onGetResources});

  final void Function(Scope? scope)? onGetResources;

  @override
  Future<SupportResourceListResponseDto>
  supportResourcesControllerGetResourcesV1({Scope? scope}) async {
    onGetResources?.call(scope);
    return const SupportResourceListResponseDto(
      code: 0,
      message: '',
      data: SupportResourceListDataDto(
        items: <SupportResourceDto>[],
        updatedAt: '2026-06-01T00:00:00.000Z',
      ),
    );
  }

  @override
  Future<AppInfoResponseDto> supportResourcesControllerGetAppInfoV1() async {
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/public/app-info'),
    );
  }
}
