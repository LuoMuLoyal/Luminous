import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_controller.freezed.dart';

enum FontSizePreference {
  small('small', 0.85),
  standard('standard', 1.0),
  large('large', 1.15),
  extraLarge('extraLarge', 1.3);

  const FontSizePreference(this.storageValue, this.scaleFactor);

  final String storageValue;
  final double scaleFactor;

  static FontSizePreference fromStorage(String? value) {
    for (final preference in FontSizePreference.values) {
      if (preference.storageValue == value) {
        return preference;
      }
    }
    return FontSizePreference.standard;
  }
}

@freezed
abstract class AccessibilitySettingsState with _$AccessibilitySettingsState {
  const factory AccessibilitySettingsState({
    @Default(FontSizePreference.standard) FontSizePreference fontSize,
    @Default(false) bool reduceAnimations,
    @Default(false) bool highContrast,
  }) = _AccessibilitySettingsState;
}

class AccessibilitySettingsController
    extends AsyncNotifier<AccessibilitySettingsState> {
  static const _fontSizeKey = 'accessibility.fontSize';
  static const _reduceAnimationsKey = 'accessibility.reduceAnimations';
  static const _highContrastKey = 'accessibility.highContrast';

  @override
  Future<AccessibilitySettingsState> build() async {
    final preferences = await SharedPreferences.getInstance();
    return AccessibilitySettingsState(
      fontSize: FontSizePreference.fromStorage(
        preferences.getString(_fontSizeKey),
      ),
      reduceAnimations: preferences.getBool(_reduceAnimationsKey) ?? false,
      highContrast: preferences.getBool(_highContrastKey) ?? false,
    );
  }

  Future<void> setFontSize(FontSizePreference preference) async {
    final next = (state.asData?.value ?? const AccessibilitySettingsState())
        .copyWith(fontSize: preference);
    state = AsyncData(next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_fontSizeKey, preference.storageValue);
  }

  Future<void> setReduceAnimations(bool enabled) async {
    final next = (state.asData?.value ?? const AccessibilitySettingsState())
        .copyWith(reduceAnimations: enabled);
    state = AsyncData(next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_reduceAnimationsKey, enabled);
  }

  Future<void> setHighContrast(bool enabled) async {
    final next = (state.asData?.value ?? const AccessibilitySettingsState())
        .copyWith(highContrast: enabled);
    state = AsyncData(next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_highContrastKey, enabled);
  }

  Future<void> reset() async {
    state = const AsyncData(AccessibilitySettingsState());
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_fontSizeKey);
    await preferences.remove(_reduceAnimationsKey);
    await preferences.remove(_highContrastKey);
  }
}

final accessibilitySettingsControllerProvider =
    AsyncNotifierProvider<
      AccessibilitySettingsController,
      AccessibilitySettingsState
    >(AccessibilitySettingsController.new);
