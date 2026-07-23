import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences keys for quick-entry preferences.
const _kDynamicSortEnabled = PrefKeys.recordQuickEntryDynamicSort;
const _kCustomOrder = PrefKeys.recordQuickEntryCustomOrder;
const _kCollapsed = PrefKeys.recordQuickEntryCollapsed;
const _kFrequencyPrefix = PrefKeys.recordQuickEntryFrequencyPrefix;

/// Maximum number of recent taps to keep for frequency-based sorting.
const _maxFrequencyEntries = 50;

/// State for quick-entry preferences.
class QuickEntryPreferences {
  const QuickEntryPreferences({
    this.dynamicSortEnabled = false,
    this.customOrder = const [],
    this.collapsed = false,
    this.frequency = const {},
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

  QuickEntryPreferences copyWith({
    bool? dynamicSortEnabled,
    List<String>? customOrder,
    bool? collapsed,
    Map<String, int>? frequency,
  }) {
    return QuickEntryPreferences(
      dynamicSortEnabled: dynamicSortEnabled ?? this.dynamicSortEnabled,
      customOrder: customOrder ?? this.customOrder,
      collapsed: collapsed ?? this.collapsed,
      frequency: frequency ?? this.frequency,
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
    );
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

  Future<void> setCollapsed(bool collapsed) async {
    final current = state.asData?.value ?? const QuickEntryPreferences();
    state = AsyncData(current.copyWith(collapsed: collapsed));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCollapsed, collapsed);
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
