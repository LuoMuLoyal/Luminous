import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/lucent_envelope.dart';

void main() {
  group('LucentEnvelope', () {
    test('isSuccess returns true when code is 0', () {
      const envelope = LucentEnvelope<String>(code: 0, message: '', data: 'ok');
      expect(envelope.isSuccess, isTrue);
    });

    test('isSuccess returns false when code is non-zero', () {
      const envelope = LucentEnvelope<String>(
        code: 400001,
        message: 'Bad request',
        data: null,
      );
      expect(envelope.isSuccess, isFalse);
    });

    group('fromJson', () {
      test('parses basic envelope with string data', () {
        final envelope = LucentEnvelope<String>.fromJson(<String, dynamic>{
          'code': 0,
          'message': '',
          'data': 'hello',
        });

        expect(envelope.code, equals(0));
        expect(envelope.message, equals(''));
        expect(envelope.data, equals('hello'));
        expect(envelope.isSuccess, isTrue);
      });

      test('parses envelope with map data', () {
        final envelope = LucentEnvelope<Map<String, dynamic>>.fromJson(
          <String, dynamic>{
            'code': 0,
            'message': 'ok',
            'data': <String, dynamic>{'key': 'value'},
          },
        );

        expect(envelope.data, isA<Map<String, dynamic>>());
        expect(envelope.data!['key'], equals('value'));
      });

      test('parses envelope with null data', () {
        final envelope = LucentEnvelope<Object?>.fromJson(<String, dynamic>{
          'code': 0,
          'message': '',
          'data': null,
        });

        expect(envelope.data, isNull);
      });

      test('uses dataDecoder when provided', () {
        final envelope = LucentEnvelope<String>.fromJson(<String, dynamic>{
          'code': 0,
          'message': '',
          'data': '{"nested": "value"}',
        }, dataDecoder: (raw) => 'decoded: $raw');

        expect(envelope.data, equals('decoded: {"nested": "value"}'));
      });

      test('parses meta as coerceToStringMap', () {
        final envelope = LucentEnvelope<String>.fromJson(<String, dynamic>{
          'code': 0,
          'message': '',
          'data': null,
          'meta': <String, dynamic>{'page': 1, 'total': 10},
        });

        expect(envelope.meta, isNotNull);
        expect(envelope.meta!['page'], equals(1));
        expect(envelope.meta!['total'], equals(10));
      });

      test('message fallback to empty string when null', () {
        final envelope = LucentEnvelope<String>.fromJson(<String, dynamic>{
          'code': 400,
          'message': null,
          'data': null,
        });

        expect(envelope.message, equals(''));
      });

      test('_parseCode handles num type', () {
        final envelope = LucentEnvelope<String>.fromJson(<String, dynamic>{
          'code': 3.14,
          'message': '',
          'data': null,
        });

        expect(envelope.code, equals(3));
      });

      test('_parseCode handles string type', () {
        final envelope = LucentEnvelope<String>.fromJson(<String, dynamic>{
          'code': '400001',
          'message': '',
          'data': null,
        });

        expect(envelope.code, equals(400001));
      });

      test('_parseCode returns -1 for unparseable values', () {
        final envelope = LucentEnvelope<String>.fromJson(<String, dynamic>{
          'code': 'abc',
          'message': '',
          'data': null,
        });

        expect(envelope.code, equals(-1));
      });

      test('_parseCode returns -1 for null code', () {
        final envelope = LucentEnvelope<String>.fromJson(<String, dynamic>{
          'code': null,
          'message': '',
          'data': null,
        });

        expect(envelope.code, equals(-1));
      });
    });
  });
}
