import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/config/pref_keys.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/quick_entry_preferences.dart';

export 'package:luminous/features/record/domain/entities/quick_entry_preferences.dart';

/// KvStore keys for quick-entry preferences.
const _kDynamicSortEnabled = PrefKeys.recordQuickEntryDynamicSort;
const _kCustomOrder = PrefKeys.recordQuickEntryCustomOrder;
const _kCollapsed = PrefKeys.recordQuickEntryCollapsed;
const _kWaterDefaultAmountMl = PrefKeys.recordQuickEntryWaterDefaultAmountMl;
const _kWaterCustomMl = PrefKeys.recordQuickEntryWaterCustomMl;
const _kWaterBadgeMode = PrefKeys.recordQuickEntryWaterBadgeMode;
const _kSymptomDefaultSeverity =
    PrefKeys.recordQuickEntrySymptomDefaultSeverity;
const _kSymptomEnabledChoices = PrefKeys.recordQuickEntrySymptomEnabledChoices;
const _kMoodBadgeMode = PrefKeys.recordQuickEntryMoodBadgeMode;
const _kMedicationAutoRecordSingle =
    PrefKeys.recordQuickEntryMedicationAutoRecordSingle;
const _kMedicationShowAlreadyRecordedHint =
    PrefKeys.recordQuickEntryMedicationShowAlreadyRecordedHint;
const _kCustomIcons = PrefKeys.recordQuickEntryCustomIcons;
const _kFrequencyPrefix = PrefKeys.recordQuickEntryFrequencyPrefix;

/// Maximum number of recent taps to keep for frequency-based sorting.
const _maxFrequencyEntries = 50;

/// Controller for quick-entry preferences backed by [SharedPreferences].
///
/// Uses [AsyncNotifier] because [SharedPreferences.getInstance] is asynchronous.
/// Consumers should read the synchronous data value via
/// `ref.watch(provider).asData?.value ?? const QuickEntryPreferences()`.
class QuickEntryPreferencesController
    extends AsyncNotifier<QuickEntryPreferences> {
  @override
  Future<QuickEntryPreferences> build() async {
    return _load();
  }

  Future<QuickEntryPreferences> _load() async {
    final prefs = KvStore.instance;
    final dynamicSortEnabled = prefs.get<bool>(
      _kDynamicSortEnabled,
      fallback: false,
    );
    final customOrder =
        prefs.getOrNull<List<String>>(_kCustomOrder) ?? const [];
    final collapsed = prefs.get<bool>(_kCollapsed, fallback: false);
    final waterDefault = _parseWaterDefault(prefs);
    final waterCustomMl = prefs.get<int>(_kWaterCustomMl, fallback: 250);
    final waterBadgeMode = _parseWaterBadgeMode(
      prefs.getOrNull<String>(_kWaterBadgeMode),
    );
    final symptomDefaultSeverity =
        prefs.getOrNull<String>(_kSymptomDefaultSeverity) ?? 'mild';
    final symptomEnabledChoices =
        prefs.getOrNull<List<String>>(_kSymptomEnabledChoices) ?? const [];
    final moodBadgeMode = _parseMoodBadgeMode(
      prefs.getOrNull<String>(_kMoodBadgeMode),
    );
    final medicationAutoRecordSingle = prefs.get<bool>(
      _kMedicationAutoRecordSingle,
      fallback: true,
    );
    final medicationShowAlreadyRecordedHint = prefs.get<bool>(
      _kMedicationShowAlreadyRecordedHint,
      fallback: true,
    );

    // Load custom icons: stored as ['water:droplets', 'meal:utensils', ...].
    final customIcons = <String, String>{};
    final rawIcons = prefs.getOrNull<List<String>>(_kCustomIcons);
    if (rawIcons != null) {
      for (final entry in rawIcons) {
        final colonIndex = entry.indexOf(':');
        if (colonIndex > 0 && colonIndex < entry.length - 1) {
          customIcons[entry.substring(0, colonIndex)] = entry.substring(
            colonIndex + 1,
          );
        }
      }
    }

    // Load frequency counts for all known entry types.
    final frequency = <String, int>{};
    for (final type in RecordEntryType.values) {
      final count = prefs.get<int>(
        '$_kFrequencyPrefix${type.name}',
        fallback: 0,
      );
      if (count > 0) {
        frequency[type.name] = count;
      }
    }

    return QuickEntryPreferences(
      dynamicSortEnabled: dynamicSortEnabled,
      customOrder: customOrder,
      collapsed: collapsed,
      frequency: frequency,
      waterDefault: waterDefault,
      waterCustomMl: waterCustomMl,
      waterBadgeMode: waterBadgeMode,
      symptomDefaultSeverity: symptomDefaultSeverity,
      symptomEnabledChoices: symptomEnabledChoices,
      moodBadgeMode: moodBadgeMode,
      medicationAutoRecordSingle: medicationAutoRecordSingle,
      medicationShowAlreadyRecordedHint: medicationShowAlreadyRecordedHint,
      customIcons: customIcons,
    );
  }

  QuickEntryWaterBadgeMode _parseWaterBadgeMode(String? value) {
    return QuickEntryWaterBadgeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => QuickEntryWaterBadgeMode.dailyTotal,
    );
  }

  QuickEntryMoodBadgeMode _parseMoodBadgeMode(String? value) {
    return QuickEntryMoodBadgeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => QuickEntryMoodBadgeMode.latest,
    );
  }

  /// Parses the stored water default. Supports both the current enum-name
  /// format and the legacy int (ml) format stored under the same key.
  QuickEntryWaterDefault _parseWaterDefault(KvStore prefs) {
    final stored = prefs.getOrNull<Object>(_kWaterDefaultAmountMl);
    if (stored is String) {
      for (final option in QuickEntryWaterDefault.values) {
        if (option.name == stored) return option;
      }
    }
    return prefs.get<int>(_kWaterDefaultAmountMl, fallback: 0) == 500
        ? QuickEntryWaterDefault.ml500
        : QuickEntryWaterDefault.ml250;
  }

  Future<void> setDynamicSortEnabled(bool enabled) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(dynamicSortEnabled: enabled));
    final prefs = KvStore.instance;
    await prefs.set(_kDynamicSortEnabled, enabled);
  }

  Future<void> setCustomOrder(List<String> order) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(customOrder: order));
    final prefs = KvStore.instance;
    await prefs.set(_kCustomOrder, order);
  }

  Future<void> resetCustomOrder() async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(customOrder: const []));
    final prefs = KvStore.instance;
    await prefs.remove(_kCustomOrder);
  }

  Future<void> setCollapsed(bool collapsed) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(collapsed: collapsed));
    final prefs = KvStore.instance;
    await prefs.set(_kCollapsed, collapsed);
  }

  Future<void> setWaterDefault(QuickEntryWaterDefault option) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(waterDefault: option));
    final prefs = KvStore.instance;
    await prefs.set(_kWaterDefaultAmountMl, option.name);
  }

  Future<void> setWaterCustomMl(int ml) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(waterCustomMl: ml));
    final prefs = KvStore.instance;
    await prefs.set(_kWaterCustomMl, ml);
  }

  Future<void> setWaterBadgeMode(QuickEntryWaterBadgeMode mode) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(waterBadgeMode: mode));
    final prefs = KvStore.instance;
    await prefs.set(_kWaterBadgeMode, mode.name);
  }

  Future<void> setSymptomDefaultSeverity(String severity) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(symptomDefaultSeverity: severity));
    final prefs = KvStore.instance;
    await prefs.set(_kSymptomDefaultSeverity, severity);
  }

  Future<void> setSymptomEnabledChoices(List<String> choices) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(symptomEnabledChoices: choices));
    final prefs = KvStore.instance;
    await prefs.set(_kSymptomEnabledChoices, choices);
  }

  Future<void> setMoodBadgeMode(QuickEntryMoodBadgeMode mode) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(moodBadgeMode: mode));
    final prefs = KvStore.instance;
    await prefs.set(_kMoodBadgeMode, mode.name);
  }

  Future<void> setMedicationAutoRecordSingle(bool enabled) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(medicationAutoRecordSingle: enabled));
    final prefs = KvStore.instance;
    await prefs.set(_kMedicationAutoRecordSingle, enabled);
  }

  Future<void> setMedicationShowAlreadyRecordedHint(bool enabled) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(
      current.copyWith(medicationShowAlreadyRecordedHint: enabled),
    );
    final prefs = KvStore.instance;
    await prefs.set(_kMedicationShowAlreadyRecordedHint, enabled);
  }

  /// Sets a custom icon name for the given entry [type].
  /// Pass `iconName = null` to remove the custom icon.
  Future<void> setCustomIcon(String type, String? iconName) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    final updated = Map<String, String>.from(current.customIcons);
    if (iconName != null) {
      updated[type] = iconName;
    } else {
      updated.remove(type);
    }
    state = AsyncData(current.copyWith(customIcons: updated));
    final prefs = KvStore.instance;
    await prefs.set(
      _kCustomIcons,
      updated.entries.map((e) => '${e.key}:${e.value}').toList(),
    );
  }

  /// Removes the custom icon for the given entry [type].
  Future<void> resetCustomIcon(String type) => setCustomIcon(type, null);

  /// Clears all custom icons.
  Future<void> resetAllCustomIcons() async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(customIcons: const {}));
    final prefs = KvStore.instance;
    await prefs.remove(_kCustomIcons);
  }

  /// Records a tap on the given [type] for frequency-based sorting.
  /// Keeps at most [_maxFrequencyEntries] total taps by trimming proportionally.
  Future<void> recordTap(RecordEntryType type) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    final frequency = Map<String, int>.from(current.frequency);
    frequency[type.name] = (frequency[type.name] ?? 0) + 1;

    // Trim: if total exceeds cap, scale down all counts proportionally.
    final total = frequency.values.fold(0, (a, b) => a + b);
    if (total > _maxFrequencyEntries) {
      final factor = _maxFrequencyEntries / total;
      frequency.updateAll((key, value) => (value * factor).floor());
      frequency.removeWhere((key, value) => value == 0);
    }

    state = AsyncData(current.copyWith(frequency: frequency));
    final prefs = KvStore.instance;
    await prefs.set(
      '$_kFrequencyPrefix${type.name}',
      frequency[type.name] ?? 0,
    );
  }

  Future<void> reset() async {
    state = const AsyncData(QuickEntryPreferences());
    final prefs = KvStore.instance;
    await prefs.remove(_kDynamicSortEnabled);
    await prefs.remove(_kCustomOrder);
    await prefs.remove(_kCollapsed);
    await prefs.remove(_kWaterDefaultAmountMl);
    await prefs.remove(_kWaterCustomMl);
    await prefs.remove(_kWaterBadgeMode);
    await prefs.remove(_kSymptomDefaultSeverity);
    await prefs.remove(_kSymptomEnabledChoices);
    await prefs.remove(_kMoodBadgeMode);
    await prefs.remove(_kMedicationAutoRecordSingle);
    await prefs.remove(_kMedicationShowAlreadyRecordedHint);
    await prefs.remove(_kCustomIcons);
    for (final type in RecordEntryType.values) {
      await prefs.remove('$_kFrequencyPrefix${type.name}');
    }
  }
}

final quickEntryPreferencesProvider =
    AsyncNotifierProvider<
      QuickEntryPreferencesController,
      QuickEntryPreferences
    >(QuickEntryPreferencesController.new);
