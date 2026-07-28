import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/today/presentation/widgets/shared/suggestion_icon_mapping.dart';

void main() {
  group('SuggestionIconMapping.resolve', () {
    test('returns droplets icon for "droplets"', () {
      expect(
        SuggestionIconMapping.resolve('droplets'),
        SemanticIcons.recordWater,
      );
    });

    test('returns moon icon for "moon"', () {
      expect(SuggestionIconMapping.resolve('moon'), SemanticIcons.recordMoon);
    });

    test('returns activity icon for "activity"', () {
      expect(
        SuggestionIconMapping.resolve('activity'),
        SemanticIcons.recordActivity,
      );
    });

    test('returns coffee icon for "coffee"', () {
      expect(
        SuggestionIconMapping.resolve('coffee'),
        SemanticIcons.recordCaffeine,
      );
    });

    test('returns user icon for "user"', () {
      expect(SuggestionIconMapping.resolve('user'), SemanticIcons.profileUser);
    });

    test('returns clipboard icon for "clipboard"', () {
      expect(
        SuggestionIconMapping.resolve('clipboard'),
        SemanticIcons.recordClipboard,
      );
    });

    test('returns alert-triangle icon for "alert-triangle"', () {
      expect(
        SuggestionIconMapping.resolve('alert-triangle'),
        SemanticIcons.statusWarning,
      );
    });

    test('returns pill icon for "pill"', () {
      expect(
        SuggestionIconMapping.resolve('pill'),
        SemanticIcons.recordMedicine,
      );
    });

    test('returns trending-up icon for "trending-up"', () {
      expect(
        SuggestionIconMapping.resolve('trending-up'),
        SemanticIcons.reportTrend,
      );
    });

    test('returns lightbulb icon for "lightbulb"', () {
      expect(SuggestionIconMapping.resolve('lightbulb'), SemanticIcons.aiTip);
    });

    test('returns info icon for "info"', () {
      expect(SuggestionIconMapping.resolve('info'), SemanticIcons.statusInfo);
    });

    test('returns fallback sparkles icon for unknown icon name', () {
      expect(
        SuggestionIconMapping.resolve('unknown-icon'),
        SemanticIcons.aiEntry,
      );
    });

    test('returns fallback sparkles icon for empty string', () {
      expect(SuggestionIconMapping.resolve(''), SemanticIcons.aiEntry);
    });

    test('fallback is consistent', () {
      final first = SuggestionIconMapping.resolve('nonexistent');
      final second = SuggestionIconMapping.resolve('also-nonexistent');
      expect(first, same(second));
    });
  });
}
