import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/support/data/repositories/lucent.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/task_either.dart';

class _MockAppInfoApi extends Mock implements AppInfoApi {}

/// A network-class error without a response (no HTTP status).
DioException _networkException() {
  return DioException(requestOptions: RequestOptions(path: '/test'));
}

/// An RFC 9457 Problem Details body served with
/// `application/problem+json` (server business failure).
DioException _problemDetails({required int statusCode, required String code}) {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/public/app-info'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: '/api/v1/public/app-info'),
      statusCode: statusCode,
      headers: Headers.fromMap({
        Headers.contentTypeHeader: ['application/problem+json'],
      }),
      data: {
        'type': 'https://api.lumos.example/problems/$code',
        'title': 'App info error',
        'detail': '应用元数据请求失败',
        'code': code,
      },
    ),
  );
}

/// A 500 error body served as `text/html` — not Problem Details (protocol
/// invariant violation) — so `.run()` propagates `FormatException`.
DioException _nonProblemHtml500() {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/public/app-info'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: '/api/v1/public/app-info'),
      statusCode: 500,
      headers: Headers.fromMap({
        Headers.contentTypeHeader: ['text/html'],
      }),
      data: '<html><body>Internal Server Error</body></html>',
    ),
  );
}

Response<T> _response<T>(T data) => Response<T>(
  data: data,
  requestOptions: RequestOptions(path: ''),
  statusCode: 200,
);

void main() {
  group('LucentSupportRepository', () {
    late _MockAppInfoApi api;
    late LucentSupportRepository repo;

    setUp(() {
      api = _MockAppInfoApi();
      repo = LucentSupportRepository(api: api);
    });

    test('maps API response to AppInfo as Right', () async {
      final response = _response(
        AppInfoResponseDto(
          minClientVersion: '0.1.0',
          latestVersion: '0.2.0',
          downloadUrl: 'https://example.com/app.apk',
          supportEmail: 'support@lumos.app',
        ),
      );

      when(
        () => api.appInfoControllerGetAppInfoV1(),
      ).thenAnswer((_) async => response);

      final result = await expectTaskRight(repo.getAppInfo());

      final info = result!;
      expect(info.minClientVersion, '0.1.0');
      expect(info.latestVersion, '0.2.0');
      expect(info.downloadUrl, 'https://example.com/app.apk');
      expect(info.supportEmail, 'support@lumos.app');
    });

    test('keeps unconfigured (all-null) fields as a Right AppInfo', () async {
      // 未配置（env 驱动字段全空）是合法 Right，不转失败；字段为 zod 响应
      // 必填（nullable）参数，未配置时服务端回 null。
      final response = _response(
        AppInfoResponseDto(
          supportEmail: null,
          minClientVersion: null,
          latestVersion: null,
          downloadUrl: null,
        ),
      );

      when(
        () => api.appInfoControllerGetAppInfoV1(),
      ).thenAnswer((_) async => response);

      final result = await expectTaskRight(repo.getAppInfo());

      // 未配置（env 驱动字段全空）是合法 Right，不转失败；About/Help 页
      // 消费方自行回退本地值。
      final info = result!;
      expect(info.supportEmail, isNull);
      expect(info.latestVersion, isNull);
    });

    test('maps a network error to Left(network)', () async {
      when(
        () => api.appInfoControllerGetAppInfoV1(),
      ).thenThrow(_networkException());

      final failure = await expectTaskLeft(repo.getAppInfo());
      expect(failure.kind, LucentFailureKind.network);
    });

    test('keeps 500 Problem Details code/status as Left(server)', () async {
      when(() => api.appInfoControllerGetAppInfoV1()).thenThrow(
        _problemDetails(statusCode: 500, code: 'APP_INFO_SERVER_ERR'),
      );

      final failure = await expectTaskLeft(repo.getAppInfo());
      expect(failure.kind, LucentFailureKind.server);
      expect(failure.code, 'APP_INFO_SERVER_ERR');
      expect(failure.statusCode, 500);
    });

    test('keeps 404 Problem Details code/status as Left(business)', () async {
      when(
        () => api.appInfoControllerGetAppInfoV1(),
      ).thenThrow(_problemDetails(statusCode: 404, code: 'APP_INFO_NOT_FOUND'));

      final failure = await expectTaskLeft(repo.getAppInfo());
      expect(failure.kind, LucentFailureKind.business);
      expect(failure.code, 'APP_INFO_NOT_FOUND');
      expect(failure.statusCode, 404);
    });

    test('non-Problem Details error body propagates FormatException '
        'from run()', () async {
      when(
        () => api.appInfoControllerGetAppInfoV1(),
      ).thenThrow(_nonProblemHtml500());

      // 协议违反（500 + text/html 而非 problem+json）保持 mapper 抛出的
      // FormatException 从 .run() 传播，而不是映射成 Left。
      await expectLater(
        repo.getAppInfo().run(),
        throwsA(isA<FormatException>()),
      );
    });

    test('empty success body is Left(network/emptyResponse)', () async {
      when(() => api.appInfoControllerGetAppInfoV1()).thenAnswer(
        (_) async => Response<AppInfoResponseDto>(
          data: null,
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      final failure = await expectTaskLeft(repo.getAppInfo());
      expect(failure.kind, LucentFailureKind.network);
      expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
    });

    test('maps an unexpected exception to Left(unknown) with cause', () async {
      when(
        () => api.appInfoControllerGetAppInfoV1(),
      ).thenThrow(StateError('boom'));

      final failure = await expectTaskLeft(repo.getAppInfo());
      expect(failure.kind, LucentFailureKind.unknown);
      expect(failure.cause, isA<StateError>());
    });
  });
}
