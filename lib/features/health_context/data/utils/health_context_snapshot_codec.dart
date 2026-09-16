import 'dart:convert';

import 'package:luminous/features/health_context/domain/entities/snapshot.dart';

/// Manual JSON serialization for [HealthContextSnapshot].
///
/// Used by the Drift cache layer to persist health-context snapshots.
/// Extracted from [LucentHealthContextRepository] so that the SyncWorker
/// replay handler can also encode/decode snapshots without depending on
/// the repository instance.
abstract final class HealthContextSnapshotCodec {
  HealthContextSnapshotCodec._();

  /// Encodes a [HealthContextSnapshot] into a JSON string for cache storage.
  static String encode(HealthContextSnapshot snapshot) {
    return jsonEncode({
      'summary': {
        'age': snapshot.summary.age,
        'onboardingCompleted': snapshot.summary.onboardingCompleted,
        'activeAllergyCount': snapshot.summary.activeAllergyCount,
        'conditionCount': snapshot.summary.conditionCount,
        'currentMedicineCount': snapshot.summary.currentMedicineCount,
        'missingCoreProfileFields': snapshot.summary.missingCoreProfileFields,
      },
      'profile': {
        'birthDate': snapshot.profile.birthDate,
        'sexAtBirth': snapshot.profile.sexAtBirth,
        'heightCm': snapshot.profile.heightCm,
        'weightKg': snapshot.profile.weightKg,
        'activityLevel': snapshot.profile.activityLevel,
        'dietaryPreferences': snapshot.profile.dietaryPreferences,
        'locale': snapshot.profile.locale,
        'timezone': snapshot.profile.timezone,
        'unitSystem': snapshot.profile.unitSystem,
        'onboardingCompletedAt': snapshot.profile.onboardingCompletedAt,
        'extras': snapshot.profile.extras,
      },
      'allergies': snapshot.allergies.map(_allergyToJson).toList(),
      'conditions': snapshot.conditions.map(_conditionToJson).toList(),
      'currentMedicines': snapshot.currentMedicines
          .map(_medicineToJson)
          .toList(),
    });
  }

  /// Decodes a JSON string from cache storage into a [HealthContextSnapshot].
  ///
  /// Scalar reads are defensive: a cache row written by an older build (or a
  /// hand-corrupted one) can hold a different JSON type than the current shape.
  /// A hard `as` cast would throw on that single field and take the whole
  /// snapshot — and therefore the whole fetch — down with it, even though the
  /// entry is only a cache and the network copy is right there. Wrong-typed
  /// values are dropped instead; the caller refetches and rewrites the row.
  static HealthContextSnapshot decode(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    final s = map['summary'] as Map<String, dynamic>;
    final p = map['profile'] as Map<String, dynamic>;
    return HealthContextSnapshot(
      summary: HealthSummary(
        age: _asInt(s['age']),
        onboardingCompleted: s['onboardingCompleted'] as bool,
        activeAllergyCount: s['activeAllergyCount'] as int,
        conditionCount: s['conditionCount'] as int,
        currentMedicineCount: s['currentMedicineCount'] as int,
        missingCoreProfileFields: _asStringList(s['missingCoreProfileFields']),
      ),
      profile: HealthProfile(
        birthDate: _asString(p['birthDate']),
        sexAtBirth: _asString(p['sexAtBirth']),
        heightCm: _asDouble(p['heightCm']),
        weightKg: _asDouble(p['weightKg']),
        activityLevel: _asString(p['activityLevel']),
        dietaryPreferences: p['dietaryPreferences'] == null
            ? null
            : _asStringList(p['dietaryPreferences']),
        locale: _asString(p['locale']),
        timezone: _asString(p['timezone']),
        unitSystem: _asString(p['unitSystem']),
        onboardingCompletedAt: _asString(p['onboardingCompletedAt']),
        extras: Map<String, dynamic>.from(p['extras'] as Map? ?? const {}),
      ),
      allergies: (map['allergies'] as List<dynamic>)
          .map((e) => _allergyFromJson(e as Map<String, dynamic>))
          .toList(),
      conditions: (map['conditions'] as List<dynamic>)
          .map((e) => _conditionFromJson(e as Map<String, dynamic>))
          .toList(),
      currentMedicines: (map['currentMedicines'] as List<dynamic>)
          .map((e) => _medicineFromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static String? _asString(Object? value) => value is String ? value : null;

  static int? _asInt(Object? value) => value is int ? value : null;

  static double? _asDouble(Object? value) =>
      value is num ? value.toDouble() : null;

  /// Reads a string list, dropping any element that is not a string.
  ///
  /// `List.cast<String>()` defers the check to first element access, so the
  /// throw lands far from the offending value; mapping eagerly keeps a bad
  /// element local to itself.
  static List<String> _asStringList(Object? value) {
    if (value is! List) return const <String>[];
    return value
        .map((e) => e is String ? e : e?.toString())
        .whereType<String>()
        .toList();
  }

  static Map<String, dynamic> _allergyToJson(AllergyItem a) => {
    'id': a.id,
    'kind': a.kind,
    'label': a.label,
    'reaction': a.reaction,
    'severity': a.severity,
    'isActive': a.isActive,
    'note': a.note,
    'createdAt': a.createdAt,
    'updatedAt': a.updatedAt,
  };

  static AllergyItem _allergyFromJson(Map<String, dynamic> m) => AllergyItem(
    id: m['id'] as String,
    kind: m['kind'] as String,
    label: m['label'] as String,
    reaction: m['reaction'] as String?,
    severity: m['severity'] as String?,
    isActive: m['isActive'] as bool,
    note: m['note'] as String?,
    createdAt: m['createdAt'] as String,
    updatedAt: m['updatedAt'] as String,
  );

  static Map<String, dynamic> _conditionToJson(ConditionItem c) => {
    'id': c.id,
    'label': c.label,
    'status': c.status,
    'diagnosedAt': c.diagnosedAt,
    'resolvedAt': c.resolvedAt,
    'note': c.note,
    'createdAt': c.createdAt,
    'updatedAt': c.updatedAt,
  };

  static ConditionItem _conditionFromJson(Map<String, dynamic> m) =>
      ConditionItem(
        id: m['id'] as String,
        label: m['label'] as String,
        status: m['status'] as String,
        diagnosedAt: m['diagnosedAt'] as String?,
        resolvedAt: m['resolvedAt'] as String?,
        note: m['note'] as String?,
        createdAt: m['createdAt'] as String,
        updatedAt: m['updatedAt'] as String,
      );

  static Map<String, dynamic> _medicineToJson(CurrentMedicineItem m) => {
    'id': m.id,
    'source': m.source,
    'sourceRefId': m.sourceRefId,
    'displayName': m.displayName,
    'strengthText': m.strengthText,
    'doseText': m.doseText,
    'route': m.route,
    'startedAt': m.startedAt,
    'endedAt': m.endedAt,
    'isCurrent': m.isCurrent,
    'note': m.note,
    'createdAt': m.createdAt,
    'updatedAt': m.updatedAt,
  };

  static CurrentMedicineItem _medicineFromJson(Map<String, dynamic> m) =>
      CurrentMedicineItem(
        id: m['id'] as String,
        source: m['source'] as String,
        sourceRefId: m['sourceRefId'] as String?,
        displayName: m['displayName'] as String,
        strengthText: m['strengthText'] as String?,
        doseText: m['doseText'] as String?,
        route: m['route'] as String?,
        startedAt: m['startedAt'] as String?,
        endedAt: m['endedAt'] as String?,
        isCurrent: m['isCurrent'] as bool,
        note: m['note'] as String?,
        createdAt: m['createdAt'] as String,
        updatedAt: m['updatedAt'] as String,
      );
}
