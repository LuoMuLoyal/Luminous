import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences keys for quick-entry preferences.
const _kDynamicSortEnabled = PrefKeys.recordQuickEntryDynamicSort;
const _kCustomOrder = PrefKeys.recordQuickEntryCustomOrder;
const _kCollapsed = PrefKeys.recordQuickEntryCollapsed;
const _kWaterDefaultAmountMl = PrefKeys.recordQuickEntryWaterDefaultAmountMl;
const _kWaterCustomMl = PrefKeys.recordQuickEntryWaterCustomMl;
const _kWaterBadgeMode = PrefKeys.recordQuickEntryWaterBadgeMode;
const _kSleepInProgressBadgeEnabled =
    PrefKeys.recordQuickEntrySleepInProgressBadgeEnabled;
const _kSleepDefaultDurationMinutes =
    PrefKeys.recordQuickEntrySleepDefaultDurationMinutes;
const _kSymptomDefaultSeverity =
    PrefKeys.recordQuickEntrySymptomDefaultSeverity;
const _kSymptomEnabledChoices = PrefKeys.recordQuickEntrySymptomEnabledChoices;
const _kMoodBadgeMode = PrefKeys.recordQuickEntryMoodBadgeMode;
const _kMoodDefaultLevel = PrefKeys.recordQuickEntryMoodDefaultLevel;
const _kMedicationAutoRecordSingle =
    PrefKeys.recordQuickEntryMedicationAutoRecordSingle;
const _kMedicationShowAlreadyRecordedHint =
    PrefKeys.recordQuickEntryMedicationShowAlreadyRecordedHint;
const _kCustomIcons = PrefKeys.recordQuickEntryCustomIcons;
const _kFrequencyPrefix = PrefKeys.recordQuickEntryFrequencyPrefix;

/// Maximum number of recent taps to keep for frequency-based sorting.
const _maxFrequencyEntries = 50;

enum QuickEntryWaterBadgeMode { dailyTotal, dailyCount, hidden }

/// How the mood quick-entry tile should summarize today's mood.
enum QuickEntryMoodBadgeMode { latest, hidden }

/// Water quick-entry default amount choices, mirroring the fast-entry water
/// options: 250 ml / 500 ml / 1 杯 / 1 次, plus a user-defined custom amount.
enum QuickEntryWaterDefault {
  ml250('250', 'ml'),
  ml500('500', 'ml'),
  cup('1', 'cup'),
  times('1', 'times'),

  /// Custom amount in ml; the actual value comes from
  /// [QuickEntryPreferences.waterCustomMl].
  custom('', 'ml');

  const QuickEntryWaterDefault(this.value, this.unit);

  /// Value stored on a water daily record. Empty for [custom] — resolve via
  /// [QuickEntryPreferences.waterCustomMl] instead.
  final String value;

  /// Unit stored on a water daily record (`ml` / `cup` / `times`).
  final String unit;

  /// Resolves the value+unit pair for a record. For [custom] this reads
  /// [customMl]; otherwise it returns the enum's fixed value/unit.
  ({String value, String unit}) resolve({required int customMl}) {
    return this == QuickEntryWaterDefault.custom
        ? (value: customMl.toString(), unit: 'ml')
        : (value: value, unit: unit);
  }
}

/// State for quick-entry preferences.
class QuickEntryPreferences {
  const QuickEntryPreferences({
    this.dynamicSortEnabled = false,
    this.customOrder = const [],
    this.collapsed = false,
    this.frequency = const {},
    this.waterDefault = QuickEntryWaterDefault.ml250,
    this.waterCustomMl = 250,
    this.waterBadgeMode = QuickEntryWaterBadgeMode.dailyTotal,
    this.sleepInProgressBadgeEnabled = true,
    this.sleepDefaultDurationMinutes = 480,
    this.symptomDefaultSeverity = 'mild',
    this.symptomEnabledChoices = const [],
    this.moodBadgeMode = QuickEntryMoodBadgeMode.latest,
    this.moodDefaultLevel = 'good',
    this.medicationAutoRecordSingle = true,
    this.medicationShowAlreadyRecordedHint = true,
    this.customIcons = const {},
  });

  /// Whether dynamic frequency-based sorting is enabled.
  final bool dynamicSortEnabled;

  /// User-defined custom order of [RecordEntryType.name] values.
  /// Empty means use the default order.
  final List<String> customOrder;

  /// Whether the quick-entry panel is collapsed.
  final bool collapsed;

  /// Frequency map: entry type name → tap count.
  final Map<String, int> frequency;

  /// Default amount created by a single water quick-entry tap.
  final QuickEntryWaterDefault waterDefault;

  /// Custom ml amount used when [waterDefault] is [QuickEntryWaterDefault.custom].
  final int waterCustomMl;

  /// How the water quick-entry tile should summarize today's water.
  final QuickEntryWaterBadgeMode waterBadgeMode;

  /// Whether the sleep tile should show an in-progress badge.
  final bool sleepInProgressBadgeEnabled;

  /// Default sleep duration in minutes for the fast-entry dialog.
  final int sleepDefaultDurationMinutes;

  /// Default severity applied to symptom quick-entry choices.
  /// One of `'mild'`, `'moderate'`, `'severe'`.
  final String symptomDefaultSeverity;

  /// Symptom choice titles that are enabled in the fast-entry dialog.
  /// Empty list means all preset choices are enabled.
  final List<String> symptomEnabledChoices;

  /// How the mood quick-entry tile should summarize today's mood.
  final QuickEntryMoodBadgeMode moodBadgeMode;

  /// Default mood level applied when highlighting a choice in the fast-entry
  /// dialog. One of `'great'`, `'good'`, `'okay'`, `'bad'`, `'terrible'`.
  final String moodDefaultLevel;

  /// Whether a single current medicine should be auto-recorded on tap.
  final bool medicationAutoRecordSingle;

  /// Whether to show a toast when nearby dose is already recorded.
  final bool medicationShowAlreadyRecordedHint;

  /// User-customized icons per entry type.
  /// Key: `RecordEntryType.name` (e.g. `'water'`, `'meal'`).
  /// Value: Lucide icon name in kebab-case (e.g. `'droplets'`).
  final Map<String, String> customIcons;

  QuickEntryPreferences copyWith({
    bool? dynamicSortEnabled,
    List<String>? customOrder,
    bool? collapsed,
    Map<String, int>? frequency,
    QuickEntryWaterDefault? waterDefault,
    int? waterCustomMl,
    QuickEntryWaterBadgeMode? waterBadgeMode,
    bool? sleepInProgressBadgeEnabled,
    int? sleepDefaultDurationMinutes,
    String? symptomDefaultSeverity,
    List<String>? symptomEnabledChoices,
    QuickEntryMoodBadgeMode? moodBadgeMode,
    String? moodDefaultLevel,
    bool? medicationAutoRecordSingle,
    bool? medicationShowAlreadyRecordedHint,
    Map<String, String>? customIcons,
  }) {
    return QuickEntryPreferences(
      dynamicSortEnabled: dynamicSortEnabled ?? this.dynamicSortEnabled,
      customOrder: customOrder ?? this.customOrder,
      collapsed: collapsed ?? this.collapsed,
      frequency: frequency ?? this.frequency,
      waterDefault: waterDefault ?? this.waterDefault,
      waterCustomMl: waterCustomMl ?? this.waterCustomMl,
      waterBadgeMode: waterBadgeMode ?? this.waterBadgeMode,
      sleepInProgressBadgeEnabled:
          sleepInProgressBadgeEnabled ?? this.sleepInProgressBadgeEnabled,
      sleepDefaultDurationMinutes:
          sleepDefaultDurationMinutes ?? this.sleepDefaultDurationMinutes,
      symptomDefaultSeverity:
          symptomDefaultSeverity ?? this.symptomDefaultSeverity,
      symptomEnabledChoices:
          symptomEnabledChoices ?? this.symptomEnabledChoices,
      moodBadgeMode: moodBadgeMode ?? this.moodBadgeMode,
      moodDefaultLevel: moodDefaultLevel ?? this.moodDefaultLevel,
      medicationAutoRecordSingle:
          medicationAutoRecordSingle ?? this.medicationAutoRecordSingle,
      medicationShowAlreadyRecordedHint:
          medicationShowAlreadyRecordedHint ??
          this.medicationShowAlreadyRecordedHint,
      customIcons: customIcons ?? this.customIcons,
    );
  }
}

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
    final prefs = await SharedPreferences.getInstance();
    final dynamicSortEnabled = prefs.getBool(_kDynamicSortEnabled) ?? false;
    final customOrder = prefs.getStringList(_kCustomOrder) ?? const [];
    final collapsed = prefs.getBool(_kCollapsed) ?? false;
    final waterDefault = _parseWaterDefault(prefs);
    final waterCustomMl = prefs.getInt(_kWaterCustomMl) ?? 250;
    final waterBadgeMode = _parseWaterBadgeMode(
      prefs.getString(_kWaterBadgeMode),
    );
    final sleepInProgressBadgeEnabled =
        prefs.getBool(_kSleepInProgressBadgeEnabled) ?? true;
    final sleepDefaultDurationMinutes =
        prefs.getInt(_kSleepDefaultDurationMinutes) ?? 480;
    final symptomDefaultSeverity =
        prefs.getString(_kSymptomDefaultSeverity) ?? 'mild';
    final symptomEnabledChoices =
        prefs.getStringList(_kSymptomEnabledChoices) ?? const [];
    final moodBadgeMode = _parseMoodBadgeMode(prefs.getString(_kMoodBadgeMode));
    final moodDefaultLevel = prefs.getString(_kMoodDefaultLevel) ?? 'good';
    final medicationAutoRecordSingle =
        prefs.getBool(_kMedicationAutoRecordSingle) ?? true;
    final medicationShowAlreadyRecordedHint =
        prefs.getBool(_kMedicationShowAlreadyRecordedHint) ?? true;

    // Load custom icons: stored as ['water:droplets', 'meal:utensils', ...].
    final customIcons = <String, String>{};
    final rawIcons = prefs.getStringList(_kCustomIcons);
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
      final count = prefs.getInt('$_kFrequencyPrefix${type.name}') ?? 0;
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
      sleepInProgressBadgeEnabled: sleepInProgressBadgeEnabled,
      sleepDefaultDurationMinutes: sleepDefaultDurationMinutes,
      symptomDefaultSeverity: symptomDefaultSeverity,
      symptomEnabledChoices: symptomEnabledChoices,
      moodBadgeMode: moodBadgeMode,
      moodDefaultLevel: moodDefaultLevel,
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
  QuickEntryWaterDefault _parseWaterDefault(SharedPreferences prefs) {
    final stored = prefs.get(_kWaterDefaultAmountMl);
    if (stored is String) {
      for (final option in QuickEntryWaterDefault.values) {
        if (option.name == stored) return option;
      }
    }
    return prefs.getInt(_kWaterDefaultAmountMl) == 500
        ? QuickEntryWaterDefault.ml500
        : QuickEntryWaterDefault.ml250;
  }

  Future<void> setDynamicSortEnabled(bool enabled) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(dynamicSortEnabled: enabled));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDynamicSortEnabled, enabled);
  }

  Future<void> setCustomOrder(List<String> order) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(customOrder: order));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kCustomOrder, order);
  }

  Future<void> resetCustomOrder() async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(customOrder: const []));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCustomOrder);
  }

  Future<void> setCollapsed(bool collapsed) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(collapsed: collapsed));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCollapsed, collapsed);
  }

  Future<void> setWaterDefault(QuickEntryWaterDefault option) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(waterDefault: option));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kWaterDefaultAmountMl, option.name);
  }

  Future<void> setWaterCustomMl(int ml) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(waterCustomMl: ml));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kWaterCustomMl, ml);
  }

  Future<void> setWaterBadgeMode(QuickEntryWaterBadgeMode mode) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(waterBadgeMode: mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kWaterBadgeMode, mode.name);
  }

  Future<void> setSleepInProgressBadgeEnabled(bool enabled) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(sleepInProgressBadgeEnabled: enabled));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSleepInProgressBadgeEnabled, enabled);
  }

  Future<void> setSleepDefaultDurationMinutes(int minutes) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(sleepDefaultDurationMinutes: minutes));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSleepDefaultDurationMinutes, minutes);
  }

  Future<void> setSymptomDefaultSeverity(String severity) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(symptomDefaultSeverity: severity));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSymptomDefaultSeverity, severity);
  }

  Future<void> setSymptomEnabledChoices(List<String> choices) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(symptomEnabledChoices: choices));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kSymptomEnabledChoices, choices);
  }

  Future<void> setMoodDefaultLevel(String level) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(moodDefaultLevel: level));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMoodDefaultLevel, level);
  }

  Future<void> setMoodBadgeMode(QuickEntryMoodBadgeMode mode) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(moodBadgeMode: mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMoodBadgeMode, mode.name);
  }

  Future<void> setMedicationAutoRecordSingle(bool enabled) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(medicationAutoRecordSingle: enabled));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMedicationAutoRecordSingle, enabled);
  }

  Future<void> setMedicationShowAlreadyRecordedHint(bool enabled) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(
      current.copyWith(medicationShowAlreadyRecordedHint: enabled),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMedicationShowAlreadyRecordedHint, enabled);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
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
    final prefs = await SharedPreferences.getInstance();
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      '$_kFrequencyPrefix${type.name}',
      frequency[type.name] ?? 0,
    );
  }

  Future<void> reset() async {
    state = const AsyncData(QuickEntryPreferences());
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDynamicSortEnabled);
    await prefs.remove(_kCustomOrder);
    await prefs.remove(_kCollapsed);
    await prefs.remove(_kWaterDefaultAmountMl);
    await prefs.remove(_kWaterCustomMl);
    await prefs.remove(_kWaterBadgeMode);
    await prefs.remove(_kSleepInProgressBadgeEnabled);
    await prefs.remove(_kSleepDefaultDurationMinutes);
    await prefs.remove(_kSymptomDefaultSeverity);
    await prefs.remove(_kSymptomEnabledChoices);
    await prefs.remove(_kMoodBadgeMode);
    await prefs.remove(_kMoodDefaultLevel);
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
