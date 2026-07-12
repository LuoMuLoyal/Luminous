import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/today/presentation/widgets/shared/suggestion_icon_mapping.dart';

void main() {
  group('SuggestionIconMapping.resolve', () {
    test('returns droplets icon for "droplets"', () {
      expect(SuggestionIconMapping.resolve('droplets'), FLucideIcons.droplets);
    });

    test('returns moon icon for "moon"', () {
      expect(SuggestionIconMapping.resolve('moon'), FLucideIcons.moon);
    });

    test('returns activity icon for "activity"', () {
      expect(SuggestionIconMapping.resolve('activity'), FLucideIcons.activity);
    });

    test('returns coffee icon for "coffee"', () {
      expect(SuggestionIconMapping.resolve('coffee'), FLucideIcons.coffee);
    });

    test('returns user icon for "user"', () {
      expect(SuggestionIconMapping.resolve('user'), FLucideIcons.userRound);
    });

    test('returns clipboard icon for "clipboard"', () {
      expect(
        SuggestionIconMapping.resolve('clipboard'),
        FLucideIcons.clipboardList,
      );
    });

    test('returns alert-triangle icon for "alert-triangle"', () {
      expect(
        SuggestionIconMapping.resolve('alert-triangle'),
        FLucideIcons.triangleAlert,
      );
    });

    test('returns pill icon for "pill"', () {
      expect(SuggestionIconMapping.resolve('pill'), FLucideIcons.pill);
    });

    test('returns trending-up icon for "trending-up"', () {
      expect(
        SuggestionIconMapping.resolve('trending-up'),
        FLucideIcons.trendingUp,
      );
    });

    test('returns lightbulb icon for "lightbulb"', () {
      expect(
        SuggestionIconMapping.resolve('lightbulb'),
        FLucideIcons.lightbulb,
      );
    });

    test('returns info icon for "info"', () {
      expect(SuggestionIconMapping.resolve('info'), FLucideIcons.info);
    });

    test('returns fallback sparkles icon for unknown icon name', () {
      expect(
        SuggestionIconMapping.resolve('unknown-icon'),
        FLucideIcons.sparkles,
      );
    });

    test('returns fallback sparkles icon for empty string', () {
      expect(SuggestionIconMapping.resolve(''), FLucideIcons.sparkles);
    });

    test('fallback is consistent', () {
      final first = SuggestionIconMapping.resolve('nonexistent');
      final second = SuggestionIconMapping.resolve('also-nonexistent');
      expect(first, same(second));
    });
  });
}
