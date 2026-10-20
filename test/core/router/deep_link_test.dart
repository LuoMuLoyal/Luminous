import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/router/deep_link.dart';
import 'package:luminous/core/router/deep_link_source.dart';

/// Collects the non-null URIs emitted by [deepLinkStreamProvider].
List<Uri> _uris(ProviderContainer container) {
  final events = <Uri>[];
  container.listen<AsyncValue<Uri>>(deepLinkStreamProvider, (_, next) {
    final uri = next.value;
    if (uri != null) events.add(uri);
  }, fireImmediately: true);
  return events;
}

void main() {
  group('isAcceptedDeepLink', () {
    test('accepts any host when none is configured', () {
      expect(
        isAcceptedDeepLink(Uri.parse('luminous://login/oauth/qq'), host: ''),
        isTrue,
      );
    });

    test('matches the configured host case-insensitively', () {
      expect(
        isAcceptedDeepLink(
          Uri.parse('https://api.luminous.app/login/oauth/qq'),
          host: 'API.Luminous.App',
        ),
        isTrue,
      );
    });

    test('rejects a different host', () {
      expect(
        isAcceptedDeepLink(
          Uri.parse('https://evil.example.com/login/oauth/qq'),
          host: 'api.luminous.app',
        ),
        isFalse,
      );
    });

    test('accepts the configured custom scheme regardless of host', () {
      // `scheme://login/oauth/qq` parses with host == 'login', so the host rule
      // alone would reject the custom-scheme fallback.
      expect(
        isAcceptedDeepLink(
          Uri.parse('com.devluo.luminous://login/oauth/qq'),
          host: 'api.luminous.app',
          scheme: 'com.devluo.luminous',
        ),
        isTrue,
      );
    });

    test('rejects an unconfigured scheme when a host is set', () {
      expect(
        isAcceptedDeepLink(
          Uri.parse('evil://login/oauth/qq'),
          host: 'api.luminous.app',
          scheme: 'com.devluo.luminous',
        ),
        isFalse,
      );
    });

    test('ignores the scheme rule when no scheme is configured', () {
      expect(
        isAcceptedDeepLink(
          Uri.parse('com.devluo.luminous://login/oauth/qq'),
          host: 'api.luminous.app',
          scheme: '',
        ),
        isFalse,
      );
    });
  });

  group('deepLinkStream', () {
    test('replays the cold-start link as the first event', () async {
      final source = FakeDeepLinkSource(
        initial: Uri.parse('https://api.luminous.app/login/oauth/qq?code=c1'),
      );
      addTearDown(source.dispose);

      final container = ProviderContainer(
        overrides: [deepLinkSourceProvider.overrideWithValue(source)],
      );
      addTearDown(container.dispose);

      final events = _uris(container);
      await pumpEventQueue();

      expect(events, hasLength(1));
      expect(events.single.queryParameters['code'], 'c1');
    });

    test('forwards hot-start links', () async {
      final source = FakeDeepLinkSource();
      addTearDown(source.dispose);

      final container = ProviderContainer(
        overrides: [deepLinkSourceProvider.overrideWithValue(source)],
      );
      addTearDown(container.dispose);

      final events = _uris(container);
      await pumpEventQueue();

      source.emit(Uri.parse('https://api.luminous.app/login/oauth/google'));
      await pumpEventQueue();

      expect(events, hasLength(1));
      expect(events.single.path, '/login/oauth/google');
    });

    test('drops links whose host is not configured', () async {
      final source = FakeDeepLinkSource();
      addTearDown(source.dispose);

      final container = ProviderContainer(
        overrides: [
          deepLinkSourceProvider.overrideWithValue(source),
          deepLinkHostProvider.overrideWithValue('api.luminous.app'),
        ],
      );
      addTearDown(container.dispose);

      final events = _uris(container);
      await pumpEventQueue();

      source.emit(Uri.parse('https://evil.example.com/login/oauth/qq'));
      source.emit(Uri.parse('https://api.luminous.app/login/oauth/qq'));
      await pumpEventQueue();

      expect(events, hasLength(1));
      expect(events.single.host, 'api.luminous.app');
    });

    test(
      'emits nothing when there is no initial link and no activity',
      () async {
        final source = FakeDeepLinkSource();
        addTearDown(source.dispose);

        final container = ProviderContainer(
          overrides: [deepLinkSourceProvider.overrideWithValue(source)],
        );
        addTearDown(container.dispose);

        final events = _uris(container);
        await pumpEventQueue();

        expect(events, isEmpty);
      },
    );
  });

  group('NoopDeepLinkSource', () {
    test('never emits and has no initial link', () async {
      const source = NoopDeepLinkSource();

      expect(await source.getInitialLink(), isNull);
      expect(await source.uriLinkStream.toList(), isEmpty);
    });
  });
}
