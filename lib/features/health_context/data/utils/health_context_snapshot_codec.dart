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
        'bloodType': snapshot.profile.bloodType,
        'locale': snapshot.profile.locale,
        'timezone': snapshot.profile.timezone,
        'unitSystem': snapshot.profile.unitSystem,
        'onboardingCompletedAt': snapshot.profile.onboardingCompletedAt,
        'emergencyContactName': snapshot.profile.emergencyContactName,
        'emergencyContactPhone': snapshot.profile.emergencyContactPhone,
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
  static HealthContextSnapshot decode(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    final s = map['summary'] as Map<String, dynamic>;
    final p = map['profile'] as Map<String, dynamic>;
    return HealthContextSnapshot(
      summary: HealthSummary(
        age: s['age'] as int?,
        onboardingCompleted: s['onboardingCompleted'] as bool,
        activeAllergyCount: s['activeAllergyCount'] as int,
        conditionCount: s['conditionCount'] as int,
        currentMedicineCount: s['currentMedicineCount'] as int,
        missingCoreProfileFields:
            (s['missingCoreProfileFields'] as List<dynamic>).cast<String>(),
      ),
      profile: HealthProfile(
        birthDate: p['birthDate'] as String?,
        sexAtBirth: p['sexAtBirth'] as String?,
        heightCm: p['heightCm'] as double?,
        weightKg: p['weightKg'] is num
            ? (p['weightKg'] as num).toDouble()
            : null,
        bloodType: p['bloodType'] as String?,
        locale: p['locale'] as String?,
        timezone: p['timezone'] as String?,
        unitSystem: p['unitSystem'] as String?,
        onboardingCompletedAt: p['onboardingCompletedAt'] as String?,
        emergencyContactName: p['emergencyContactName'] as String?,
        emergencyContactPhone: p['emergencyContactPhone'] as String?,
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
