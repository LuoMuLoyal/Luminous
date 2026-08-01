import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences keys for quick-entry preferences.
const _kDynamicSortEnabled = PrefKeys.recordQuickEntryDynamicSort;
const _kCustomOrder = PrefKeys.recordQuickEntryCustomOrder;
const _kCollapsed = PrefKeys.recordQuickEntryCollapsed;
const _kWaterDefaultAmountMl = PrefKeys.recordQuickEntryWaterDefaultAmountMl;
const _kWaterBadgeMode = PrefKeys.recordQuickEntryWaterBadgeMode;
const _kSleepInProgressBadgeEnabled =
    PrefKeys.recordQuickEntrySleepInProgressBadgeEnabled;
const _kCustomIcons = PrefKeys.recordQuickEntryCustomIcons;
const _kFrequencyPrefix = PrefKeys.recordQuickEntryFrequencyPrefix;

/// Maximum number of recent taps to keep for frequency-based sorting.
const _maxFrequencyEntries = 50;

enum QuickEntryWaterBadgeMode { dailyTotal, dailyCount, hidden }

/// Water quick-entry default amount choices, mirroring the fast-entry water
/// options: 250 ml / 500 ml / 1 杯 / 1 次.
enum QuickEntryWaterDefault {
  ml250('250', 'ml'),
  ml500('500', 'ml'),
  cup('1', 'cup'),
  times('1', 'times');

  const QuickEntryWaterDefault(this.value, this.unit);

  /// Value stored on a water daily record.
  final String value;

  /// Unit stored on a water daily record (`ml` / `cup` / `times`).
  final String unit;
}

/// State for quick-entry preferences.
class QuickEntryPreferences {
  const QuickEntryPreferences({
    this.dynamicSortEnabled = false,
    this.customOrder = const [],
    this.collapsed = false,
    this.frequency = const {},
    this.waterDefault = QuickEntryWaterDefault.ml250,
    this.waterBadgeMode = QuickEntryWaterBadgeMode.dailyTotal,
    this.sleepInProgressBadgeEnabled = true,
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

  /// How the water quick-entry tile should summarize today's water.
  final QuickEntryWaterBadgeMode waterBadgeMode;

  /// Whether the sleep tile should show an in-progress badge.
  final bool sleepInProgressBadgeEnabled;

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
    QuickEntryWaterBadgeMode? waterBadgeMode,
    bool? sleepInProgressBadgeEnabled,
    Map<String, String>? customIcons,
  }) {
    return QuickEntryPreferences(
      dynamicSortEnabled: dynamicSortEnabled ?? this.dynamicSortEnabled,
      customOrder: customOrder ?? this.customOrder,
      collapsed: collapsed ?? this.collapsed,
      frequency: frequency ?? this.frequency,
      waterDefault: waterDefault ?? this.waterDefault,
      waterBadgeMode: waterBadgeMode ?? this.waterBadgeMode,
      sleepInProgressBadgeEnabled:
          sleepInProgressBadgeEnabled ?? this.sleepInProgressBadgeEnabled,
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
    final waterBadgeMode = _parseWaterBadgeMode(
      prefs.getString(_kWaterBadgeMode),
    );
    final sleepInProgressBadgeEnabled =
        prefs.getBool(_kSleepInProgressBadgeEnabled) ?? true;

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
      waterBadgeMode: waterBadgeMode,
      sleepInProgressBadgeEnabled: sleepInProgressBadgeEnabled,
      customIcons: customIcons,
    );
  }

  QuickEntryWaterBadgeMode _parseWaterBadgeMode(String? value) {
    return QuickEntryWaterBadgeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => QuickEntryWaterBadgeMode.dailyTotal,
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
    await prefs.remove(_kWaterBadgeMode);
    await prefs.remove(_kSleepInProgressBadgeEnabled);
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
