import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/oauth_callback_parser.dart';

void main() {
  group('OAuthCallbackParser', () {
    group('parse — full URL', () {
      test('parses URL with code and state', () {
        final result = OAuthCallbackParser.parse(
          'https://app.example.com/oauth/wechat/callback?code=abc123&state=xyz789',
          null,
        );
        expect(result, isNotNull);
        expect(result!.code, 'abc123');
        expect(result.state, 'xyz789');
      });

      test('uses fallbackState when URL has code but no state', () {
        final result = OAuthCallbackParser.parse(
          'https://app.example.com/oauth/callback?code=abc123',
          'fallback-state',
        );
        expect(result, isNotNull);
        expect(result!.code, 'abc123');
        expect(result.state, 'fallback-state');
      });

      test('returns null when URL has neither code nor state and no fallback', () {
        final result = OAuthCallbackParser.parse(
          'https://app.example.com/oauth/callback',
          null,
        );
        expect(result, isNull);
      });

      test('returns null when URL has empty code', () {
        final result = OAuthCallbackParser.parse(
          'https://app.example.com/oauth/callback?code=&state=xyz',
          null,
        );
        // Empty code triggers fallback to bare-token path, but 'code=' has '='
        // and splitQueryString returns empty string → not isNotEmpty → null
        expect(result, isNull);
      });

      test('trims whitespace in code and state from URL', () {
        final result = OAuthCallbackParser.parse(
          'https://app.example.com/oauth/callback?code=%20abc%20&state=%20xyz%20',
          null,
        );
        expect(result, isNotNull);
        expect(result!.code, 'abc');
        expect(result.state, 'xyz');
      });
    });

    group('parse — query string', () {
      test('parses query string with leading ?', () {
        final result = OAuthCallbackParser.parse(
          '?code=abc123&state=xyz789',
          null,
        );
        expect(result, isNotNull);
        expect(result!.code, 'abc123');
        expect(result.state, 'xyz789');
      });

      test('parses query string without leading ?', () {
        final result = OAuthCallbackParser.parse(
          'code=abc123&state=xyz789',
          null,
        );
        expect(result, isNotNull);
        expect(result!.code, 'abc123');
        expect(result.state, 'xyz789');
      });

      test('uses fallbackState for query string without state', () {
        final result = OAuthCallbackParser.parse(
          '?code=abc123',
          'fallback-state',
        );
        expect(result, isNotNull);
        expect(result!.code, 'abc123');
        expect(result.state, 'fallback-state');
      });

      test('returns null for query string with empty code', () {
        final result = OAuthCallbackParser.parse(
          '?code=&state=xyz',
          null,
        );
        expect(result, isNull);
      });
    });

    group('parse — bare code token', () {
      test('parses bare code with fallbackState', () {
        final result = OAuthCallbackParser.parse('abc123', 'fallback-state');
        expect(result, isNotNull);
        expect(result!.code, 'abc123');
        expect(result.state, 'fallback-state');
      });

      test('returns null for bare code without fallbackState', () {
        final result = OAuthCallbackParser.parse('abc123', null);
        expect(result, isNull);
      });

      test('returns null for bare code with empty fallbackState', () {
        final result = OAuthCallbackParser.parse('abc123', '');
        expect(result, isNull);
      });

      test('returns null for bare code with whitespace', () {
        final result = OAuthCallbackParser.parse('abc 123', 'fallback-state');
        // Contains whitespace → not a single token
        expect(result, isNull);
      });
    });

    group('parse — edge cases', () {
      test('returns null for empty string', () {
        expect(OAuthCallbackParser.parse('', null), isNull);
      });

      test('returns null for whitespace-only string', () {
        expect(OAuthCallbackParser.parse('   ', null), isNull);
      });

      test('returns null for non-URL, non-query string without fallback', () {
        expect(OAuthCallbackParser.parse('just-a-string', null), isNull);
      });

      test('URL with extra params parses correctly', () {
        final result = OAuthCallbackParser.parse(
          'https://app.example.com/cb?foo=bar&code=abc&state=xyz&extra=1',
          null,
        );
        expect(result, isNotNull);
        expect(result!.code, 'abc');
        expect(result.state, 'xyz');
      });

      test('prefers URL state over fallbackState', () {
        final result = OAuthCallbackParser.parse(
          'https://app.example.com/cb?code=abc&state=real-state',
          'fallback-state',
        );
        expect(result, isNotNull);
        expect(result!.state, 'real-state');
      });

      test('query string prefers state over fallbackState', () {
        final result = OAuthCallbackParser.parse(
          '?code=abc&state=real-state',
          'fallback-state',
        );
        expect(result, isNotNull);
        expect(result!.state, 'real-state');
      });

      test('trims input before parsing', () {
        final result = OAuthCallbackParser.parse(
          '  ?code=abc&state=xyz  ',
          null,
        );
        expect(result, isNotNull);
        expect(result!.code, 'abc');
        expect(result.state, 'xyz');
      });
    });

    group('OAuthCallback', () {
      test('stores code and state', () {
        const callback = OAuthCallback(code: 'test-code', state: 'test-state');
        expect(callback.code, 'test-code');
        expect(callback.state, 'test-state');
      });
    });
  });
}
