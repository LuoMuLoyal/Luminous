import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/database/models/pending_sync_error_details.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/error_code.dart';

/// Locks the JSON backward-compatibility contract for
/// [PendingSyncErrorDetails]: rows persisted by the pre-migration shape
/// (legacy `AppErrorKind` kind names + numeric `code`) must still decode —
/// a throw would drop the whole entry's structured details.
void main() {
  group('PendingSyncErrorDetails.fromLucentFailure', () {
    test('copies the normalized LucentFailure fields', () {
      final details = PendingSyncErrorDetails.fromLucentFailure(
        const LucentFailure(
          kind: LucentFailureKind.authentication,
          message: 'Session expired',
          code: 'AUTH_TOKEN_EXPIRED',
          statusCode: 401,
          traceId: 'trace-1',
          networkErrorCode: null,
        ),
        'DioException: 401',
      );

      expect(details.kind, LucentFailureKind.authentication);
      expect(details.message, 'Session expired');
      expect(details.code, 'AUTH_TOKEN_EXPIRED');
      expect(details.statusCode, 401);
      expect(details.traceId, 'trace-1');
      expect(details.raw, 'DioException: 401');
    });

    test('network failure keeps its networkErrorCode', () {
      final details = PendingSyncErrorDetails.fromLucentFailure(
        LucentFailure.network(
          message: 'timeout',
          networkErrorCode: NetworkErrorCode.connectionTimeout,
        ),
        'timeout',
      );

      expect(details.kind, LucentFailureKind.network);
      expect(details.networkErrorCode, NetworkErrorCode.connectionTimeout);
    });
  });

  group('PendingSyncErrorDetails.fromJson — current shape', () {
    test('round-trips string code and LucentFailureKind names', () {
      const json = <String, dynamic>{
        'message': 'Session expired',
        'code': 'AUTH_TOKEN_EXPIRED',
        'statusCode': 401,
        'traceId': 'trace-1',
        'networkErrorCode': null,
        'kind': 'authentication',
        'raw': 'raw text',
      };

      final details = PendingSyncErrorDetails.fromJson(json);

      expect(details.kind, LucentFailureKind.authentication);
      expect(details.code, 'AUTH_TOKEN_EXPIRED');
      expect(details.statusCode, 401);
      expect(details.traceId, 'trace-1');
      expect(details.raw, 'raw text');
      expect(details.toJson()['code'], 'AUTH_TOKEN_EXPIRED');
      expect(details.toJson()['kind'], 'authentication');
    });

    test('network kind round-trips through its own name', () {
      const json = <String, dynamic>{
        'kind': 'network',
        'networkErrorCode': 'connectionError',
        'code': null,
      };

      final details = PendingSyncErrorDetails.fromJson(json);

      expect(details.kind, LucentFailureKind.network);
      expect(details.networkErrorCode, NetworkErrorCode.connectionError);
    });

    test('missing kind and code stay null', () {
      const json = <String, dynamic>{'message': 'only message'};

      final details = PendingSyncErrorDetails.fromJson(json);

      expect(details.kind, isNull);
      expect(details.code, isNull);
      expect(details.message, 'only message');
    });
  });

  group(
    'PendingSyncErrorDetails.fromJson — legacy AppErrorKind kind names',
    () {
      for (final (legacyName, expected) in <(String, LucentFailureKind)>[
        ('network', LucentFailureKind.network),
        ('auth', LucentFailureKind.authentication),
        ('server', LucentFailureKind.server),
        ('business', LucentFailureKind.business),
        ('unknown', LucentFailureKind.unknown),
      ]) {
        test('legacy kind "$legacyName" maps to $expected', () {
          final details = PendingSyncErrorDetails.fromJson(<String, dynamic>{
            'kind': legacyName,
          });
          expect(details.kind, expected);
        });
      }

      test('unknown legacy kind value falls back to unknown, never throws', () {
        final details = PendingSyncErrorDetails.fromJson(<String, dynamic>{
          'kind': 'some_future_kind',
        });
        expect(details.kind, LucentFailureKind.unknown);
      });

      test('non-string legacy kind value becomes null, never throws', () {
        final details = PendingSyncErrorDetails.fromJson(<String, dynamic>{
          'kind': 5,
        });
        expect(details.kind, isNull);
      });
    },
  );

  group('PendingSyncErrorDetails.fromJson — legacy numeric code', () {
    test('legacy badRequest 400001 normalizes to VALIDATION_FAILED', () {
      final details = PendingSyncErrorDetails.fromJson(<String, dynamic>{
        'code': 400001,
      });
      expect(details.code, 'VALIDATION_FAILED');
    });

    test('legacy validationFailed 400002 normalizes to VALIDATION_FAILED', () {
      final details = PendingSyncErrorDetails.fromJson(<String, dynamic>{
        'code': 400002,
      });
      expect(details.code, 'VALIDATION_FAILED');
    });

    test('other legacy numeric codes convert to their string form', () {
      final details = PendingSyncErrorDetails.fromJson(<String, dynamic>{
        'code': 400100,
      });
      expect(details.code, '400100');
    });

    test('integral double codes normalize like their int value', () {
      final details = PendingSyncErrorDetails.fromJson(<String, dynamic>{
        'code': 400001.0,
      });
      expect(details.code, 'VALIDATION_FAILED');
    });

    test('non-numeric non-string code becomes null, never throws', () {
      final details = PendingSyncErrorDetails.fromJson(<String, dynamic>{
        'code': true,
      });
      expect(details.code, isNull);
    });
  });

  group('PendingSyncErrorDetails.fromJson — full legacy row', () {
    test('decodes a complete pre-migration row without throwing', () {
      const json = <String, dynamic>{
        'message': '验证码错误',
        'code': 401002,
        'statusCode': 401,
        'traceId': 'legacy-trace',
        'networkErrorCode': null,
        'kind': 'auth',
        'raw': 'AppError(message: 验证码错误, kind: auth, code: 401002)',
      };

      final details = PendingSyncErrorDetails.fromJson(json);

      expect(details.kind, LucentFailureKind.authentication);
      expect(details.code, '401002');
      expect(details.statusCode, 401);
      expect(details.traceId, 'legacy-trace');
      expect(details.raw, contains('AppError'));
    });

    test(
      'legacy business validation row maps to the current validation code',
      () {
        const json = <String, dynamic>{
          'message': '数据无效',
          'code': 400001,
          'statusCode': 400,
          'networkErrorCode': null,
          'kind': 'business',
        };

        final details = PendingSyncErrorDetails.fromJson(json);

        expect(details.kind, LucentFailureKind.business);
        expect(details.code, 'VALIDATION_FAILED');
      },
    );
  });
}
