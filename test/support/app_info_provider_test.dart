import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/features/support/data/providers/resources.dart';

void main() {
  group('appInfoProvider', () {
    test('returns app info data DTO', () async {
      final fakeApi = FakeAppInfoApi(
        response: AppInfoResponseDto(
          code: 0,
          message: '',
          data: AppInfoDataDto(supportEmail: 'support@lumos.app'),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(appInfoApi: fakeApi),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(appInfoProvider.future);

      expect(result, isNotNull);
      expect(result!.supportEmail, equals('support@lumos.app'));
    });

    test('throws when response data is null', () async {
      final fakeApi = FakeAppInfoApi(response: null);

      final container = ProviderContainer(
        overrides: [
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(appInfoApi: fakeApi),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(appInfoProvider, (_, __) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = sub.read();
      expect(state.hasError, isTrue);
      expect(state.error, isA<DioException>());
    });
  });
}

class FakeAppInfoApi extends AppInfoApi {
  FakeAppInfoApi({required this.response}) : super(Dio());

  final AppInfoResponseDto? response;

  @override
  Future<Response<AppInfoResponseDto>> appInfoControllerGetAppInfoV1({
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (response == null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/public/app-info'),
      );
    }
    return _response(response!);
  }
}

class _FakeLucentClient extends LucentClient {
  _FakeLucentClient({required this.appInfoApi}) : super(LucentApi(dio: Dio()));

  final AppInfoApi appInfoApi;

  @override
  AppInfoApi get appInfo => appInfoApi;
}

Response<T> _response<T>(T data) {
  return Response<T>(
    data: data,
    requestOptions: RequestOptions(path: '/api/v1/public/app-info'),
  );
}
