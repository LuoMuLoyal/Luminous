import 'package:luminous/features/record/domain/entities/dashboard.dart';

/// User preferences that shape the record page's quick-entry surface.
///
/// Key names, (de)serialisation and the controller that persists them live in
/// `data/datasources/quick_entry_preferences.dart`; the value model itself is a
/// domain concern so use cases and the dashboard can consume it without
/// depending on the data layer.
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
    this.symptomDefaultSeverity = 'mild',
    this.symptomEnabledChoices = const [],
    this.moodBadgeMode = QuickEntryMoodBadgeMode.latest,
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

  /// Default severity applied to symptom quick-entry choices.
  /// One of `'mild'`, `'moderate'`, `'severe'`, `'unknown'`.
  final String symptomDefaultSeverity;

  /// Symptom **catalog codes** that are enabled in the fast-entry dialog
  /// (payload `symptom` values, e.g. `'headache'`).
  /// Empty list means all catalog entries are enabled.
  ///
  /// Codes, not localized labels: storing labels broke the dialog whenever the
  /// app language changed.
  final List<String> symptomEnabledChoices;

  /// How the mood quick-entry tile should summarize today's mood.
  final QuickEntryMoodBadgeMode moodBadgeMode;

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
    String? symptomDefaultSeverity,
    List<String>? symptomEnabledChoices,
    QuickEntryMoodBadgeMode? moodBadgeMode,
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
      symptomDefaultSeverity:
          symptomDefaultSeverity ?? this.symptomDefaultSeverity,
      symptomEnabledChoices:
          symptomEnabledChoices ?? this.symptomEnabledChoices,
      moodBadgeMode: moodBadgeMode ?? this.moodBadgeMode,
      medicationAutoRecordSingle:
          medicationAutoRecordSingle ?? this.medicationAutoRecordSingle,
      medicationShowAlreadyRecordedHint:
          medicationShowAlreadyRecordedHint ??
          this.medicationShowAlreadyRecordedHint,
      customIcons: customIcons ?? this.customIcons,
    );
  }
}
