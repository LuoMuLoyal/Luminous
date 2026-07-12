import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/accessibility/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  ProviderContainer buildContainer({Map<String, Object>? initialValues}) {
    SharedPreferences.setMockInitialValues(
      initialValues ?? const <String, Object>{},
    );
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  group('FontSizePreference', () {
    test('fromStorage returns correct preference for known values', () {
      expect(FontSizePreference.fromStorage('small'), FontSizePreference.small);
      expect(
        FontSizePreference.fromStorage('standard'),
        FontSizePreference.standard,
      );
      expect(FontSizePreference.fromStorage('large'), FontSizePreference.large);
      expect(
        FontSizePreference.fromStorage('extraLarge'),
        FontSizePreference.extraLarge,
      );
    });

    test('fromStorage returns standard for null', () {
      expect(FontSizePreference.fromStorage(null), FontSizePreference.standard);
    });

    test('fromStorage returns standard for unknown value', () {
      expect(
        FontSizePreference.fromStorage('unknown'),
        FontSizePreference.standard,
      );
    });

    test('scaleFactor values are correct', () {
      expect(FontSizePreference.small.scaleFactor, 0.85);
      expect(FontSizePreference.standard.scaleFactor, 1.0);
      expect(FontSizePreference.large.scaleFactor, 1.15);
      expect(FontSizePreference.extraLarge.scaleFactor, 1.3);
    });

    test('storageValue values are correct', () {
      expect(FontSizePreference.small.storageValue, 'small');
      expect(FontSizePreference.standard.storageValue, 'standard');
      expect(FontSizePreference.large.storageValue, 'large');
      expect(FontSizePreference.extraLarge.storageValue, 'extraLarge');
    });
  });

  group('AccessibilitySettingsController.build', () {
    test('uses default values when no preferences are stored', () async {
      container = buildContainer();

      final state = await container.read(
        accessibilitySettingsControllerProvider.future,
      );

      expect(state.fontSize, FontSizePreference.standard);
      expect(state.reduceAnimations, isFalse);
      expect(state.highContrast, isFalse);
    });

    test('loads persisted font size', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'accessibility.fontSize': 'large',
        },
      );

      final state = await container.read(
        accessibilitySettingsControllerProvider.future,
      );

      expect(state.fontSize, FontSizePreference.large);
    });

    test('loads persisted reduceAnimations', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'accessibility.reduceAnimations': true,
        },
      );

      final state = await container.read(
        accessibilitySettingsControllerProvider.future,
      );

      expect(state.reduceAnimations, isTrue);
    });

    test('loads persisted highContrast', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'accessibility.highContrast': true,
        },
      );

      final state = await container.read(
        accessibilitySettingsControllerProvider.future,
      );

      expect(state.highContrast, isTrue);
    });
  });

  group('setFontSize', () {
    test('updates state and persists the value', () async {
      container = buildContainer();

      await container.read(accessibilitySettingsControllerProvider.future);

      await container
          .read(accessibilitySettingsControllerProvider.notifier)
          .setFontSize(FontSizePreference.extraLarge);

      final state = container.read(accessibilitySettingsControllerProvider);
      expect(state.value?.fontSize, FontSizePreference.extraLarge);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('accessibility.fontSize'), 'extraLarge');
    });
  });

  group('setReduceAnimations', () {
    test('updates state and persists the value', () async {
      container = buildContainer();

      await container.read(accessibilitySettingsControllerProvider.future);

      await container
          .read(accessibilitySettingsControllerProvider.notifier)
          .setReduceAnimations(true);

      final state = container.read(accessibilitySettingsControllerProvider);
      expect(state.value?.reduceAnimations, isTrue);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getBool('accessibility.reduceAnimations'), isTrue);
    });
  });

  group('setHighContrast', () {
    test('updates state and persists the value', () async {
      container = buildContainer();

      await container.read(accessibilitySettingsControllerProvider.future);

      await container
          .read(accessibilitySettingsControllerProvider.notifier)
          .setHighContrast(true);

      final state = container.read(accessibilitySettingsControllerProvider);
      expect(state.value?.highContrast, isTrue);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getBool('accessibility.highContrast'), isTrue);
    });
  });

  group('reset', () {
    test('clears all accessibility preference keys', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'accessibility.fontSize': 'large',
          'accessibility.reduceAnimations': true,
          'accessibility.highContrast': true,
        },
      );

      await container.read(accessibilitySettingsControllerProvider.future);

      await container
          .read(accessibilitySettingsControllerProvider.notifier)
          .reset();

      final state = container.read(accessibilitySettingsControllerProvider);
      expect(state.value?.fontSize, FontSizePreference.standard);
      expect(state.value?.reduceAnimations, isFalse);
      expect(state.value?.highContrast, isFalse);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.containsKey('accessibility.fontSize'), isFalse);
      expect(
        preferences.containsKey('accessibility.reduceAnimations'),
        isFalse,
      );
      expect(preferences.containsKey('accessibility.highContrast'), isFalse);
    });
  });
}
