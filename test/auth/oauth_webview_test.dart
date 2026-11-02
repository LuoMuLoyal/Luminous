import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/presentation/controllers/oauth_webview.dart';

void main() {
  final callback = Uri.parse('https://api.luminous.app/login/oauth/qq');

  group('isOAuthCallbackNavigation', () {
    test('matches the callback URL with code/state appended', () {
      expect(
        isOAuthCallbackNavigation(
          Uri.parse('https://api.luminous.app/login/oauth/qq?code=c&state=s'),
          callback,
        ),
        isTrue,
      );
    });

    test('matches host case-insensitively', () {
      expect(
        isOAuthCallbackNavigation(
          Uri.parse('https://API.Luminous.App/login/oauth/qq?code=c&state=s'),
          callback,
        ),
        isTrue,
      );
    });

    test('ignores query parameters', () {
      expect(
        isOAuthCallbackNavigation(
          Uri.parse('https://api.luminous.app/login/oauth/qq'),
          callback,
        ),
        isTrue,
      );
    });

    test('rejects a different path', () {
      expect(
        isOAuthCallbackNavigation(
          Uri.parse('https://api.luminous.app/login/oauth/google?code=c'),
          callback,
        ),
        isFalse,
      );
    });

    test('rejects a different host', () {
      expect(
        isOAuthCallbackNavigation(
          Uri.parse('https://evil.example.com/login/oauth/qq?code=c'),
          callback,
        ),
        isFalse,
      );
    });

    test('rejects a different scheme', () {
      expect(
        isOAuthCallbackNavigation(
          Uri.parse('http://api.luminous.app/login/oauth/qq?code=c'),
          callback,
        ),
        isFalse,
      );
    });

    test('does not match the authorize page itself', () {
      expect(
        isOAuthCallbackNavigation(
          Uri.parse('https://graph.qq.com/oauth2.0/authorize?client_id=x'),
          callback,
        ),
        isFalse,
      );
    });
  });
}
