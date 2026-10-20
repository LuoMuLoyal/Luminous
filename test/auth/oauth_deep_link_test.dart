import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/oauth_deep_link.dart';

void main() {
  group('parseOAuthDeepLink', () {
    test('parses an https callback link', () {
      final link = parseOAuthDeepLink(
        Uri.parse('https://api.luminous.app/login/oauth/qq?code=c1&state=s1'),
      );

      expect(link, isNotNull);
      expect(link!.provider, OAuthDeepLinkProvider.qq);
      expect(link.code, 'c1');
      expect(link.state, 's1');
    });

    test('parses a custom-scheme callback link (single slash)', () {
      final link = parseOAuthDeepLink(
        Uri.parse('com.devluo.luminous://login/oauth/wechat?code=c2&state=s2'),
      );

      expect(link, isNotNull);
      expect(link!.provider, OAuthDeepLinkProvider.wechat);
      expect(link.code, 'c2');
      expect(link.state, 's2');
    });

    test('parses a custom-scheme callback link (triple slash)', () {
      final link = parseOAuthDeepLink(
        Uri.parse('com.devluo.luminous:///login/oauth/wechat?code=c2&state=s2'),
      );

      expect(link, isNotNull);
      expect(link!.provider, OAuthDeepLinkProvider.wechat);
      expect(link.code, 'c2');
    });

    test('parses google callbacks', () {
      final link = parseOAuthDeepLink(
        Uri.parse(
          'https://api.luminous.app/login/oauth/google?code=c3&state=s3',
        ),
      );

      expect(link?.provider, OAuthDeepLinkProvider.google);
    });

    test('tolerates a trailing slash on the path', () {
      final link = parseOAuthDeepLink(
        Uri.parse('com.devluo.luminous://login/oauth/qq/?code=c1&state=s1'),
      );

      expect(link?.provider, OAuthDeepLinkProvider.qq);
    });

    test('carries returnTo when present', () {
      final link = parseOAuthDeepLink(
        Uri.parse(
          'https://api.luminous.app/login/oauth/qq'
          '?code=c1&state=s1&returnTo=%2Frecord%2F123',
        ),
      );

      expect(link?.returnTo, '/record/123');
    });

    test('returns null for a non-OAuth path', () {
      expect(
        parseOAuthDeepLink(Uri.parse('https://api.luminous.app/record/123')),
        isNull,
      );
    });

    test('returns null when code is missing', () {
      expect(
        parseOAuthDeepLink(
          Uri.parse('https://api.luminous.app/login/oauth/qq?state=s1'),
        ),
        isNull,
      );
    });

    test('uses fallbackState for a bare-code payload', () {
      final link = parseOAuthDeepLink(
        Uri.parse('https://api.luminous.app/login/oauth/wechat?code=c9'),
        fallbackState: 'fallback',
      );

      expect(link?.code, 'c9');
      expect(link?.state, 'fallback');
    });
  });
}
