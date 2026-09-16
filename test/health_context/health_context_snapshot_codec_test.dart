import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/health_context/data/utils/health_context_snapshot_codec.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';

/// A snapshot with every field populated, so encode/decode is exercised on the
/// full shape rather than a mostly-null one.
HealthContextSnapshot _snapshot() => const HealthContextSnapshot(
  summary: HealthSummary(
    age: 27,
    onboardingCompleted: true,
    activeAllergyCount: 1,
    conditionCount: 1,
    currentMedicineCount: 1,
    missingCoreProfileFields: ['birthDate', 'unitSystem'],
  ),
  profile: HealthProfile(
    birthDate: '1999-01-15',
    sexAtBirth: 'female',
    heightCm: 170.0,
    weightKg: 60.0,
    activityLevel: 'moderate',
    dietaryPreferences: ['vegetarian'],
    locale: 'zh-CN',
    timezone: 'Asia/Shanghai',
    unitSystem: 'metric',
    onboardingCompletedAt: '2026-01-01T00:00:00Z',
    extras: {'note': 'x'},
  ),
  allergies: [
    AllergyItem(
      id: 'a1',
      kind: 'drug',
      label: '青霉素',
      reaction: '皮疹',
      severity: 'moderate',
      isActive: true,
      note: null,
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-02T00:00:00Z',
    ),
  ],
  conditions: [
    ConditionItem(
      id: 'c1',
      label: '高血压',
      status: 'active',
      diagnosedAt: '2025-01-01',
      resolvedAt: null,
      note: null,
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-02T00:00:00Z',
    ),
  ],
  currentMedicines: [
    CurrentMedicineItem(
      id: 'm1',
      source: 'manual',
      sourceRefId: null,
      displayName: '阿司匹林',
      strengthText: '100mg',
      doseText: '1 片',
      route: 'oral',
      startedAt: '2026-01-01',
      endedAt: null,
      isCurrent: true,
      note: null,
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-02T00:00:00Z',
    ),
  ],
);

/// Encodes a snapshot, then rewrites one field of the JSON to a wrong type —
/// standing in for a cache row written by an older build.
String _jsonWith(Object? value, String key) {
  final map =
      jsonDecode(HealthContextSnapshotCodec.encode(_snapshot()))
          as Map<String, dynamic>;
  (map['profile'] as Map<String, dynamic>)[key] = value;
  return jsonEncode(map);
}

void main() {
  group('round-trip', () {
    test('preserves every field', () {
      final decoded = HealthContextSnapshotCodec.decode(
        HealthContextSnapshotCodec.encode(_snapshot()),
      );

      expect(decoded.summary.age, 27);
      expect(decoded.summary.missingCoreProfileFields, [
        'birthDate',
        'unitSystem',
      ]);
      expect(decoded.profile.heightCm, 170.0);
      expect(decoded.profile.activityLevel, 'moderate');
      expect(decoded.profile.dietaryPreferences, ['vegetarian']);
      expect(decoded.profile.extras, {'note': 'x'});
      expect(decoded.allergies.single.label, '青霉素');
      expect(decoded.conditions.single.label, '高血压');
      expect(decoded.currentMedicines.single.displayName, '阿司匹林');
    });
  });

  group('tolerant decoding', () {
    // 缓存只是缓存:某一字段类型不对时不该炸掉整份快照——那会连带整个
    // fetch 失败,而正确的数据就在网络上。宁可丢该字段,让调用方重新拉取。
    test('drops a wrong-typed string instead of throwing', () {
      final decoded = HealthContextSnapshotCodec.decode(
        _jsonWith(42, 'activityLevel'),
      );

      expect(decoded.profile.activityLevel, isNull);
      // 其余字段照常解出。
      expect(decoded.profile.locale, 'zh-CN');
    });

    test('accepts an int where a double is expected', () {
      final decoded = HealthContextSnapshotCodec.decode(
        _jsonWith(170, 'heightCm'),
      );

      // JSON 不区分 170 与 170.0,旧行写的是整数完全可能。
      expect(decoded.profile.heightCm, 170.0);
    });

    test('drops a wrong-typed height instead of throwing', () {
      final decoded = HealthContextSnapshotCodec.decode(
        _jsonWith('tall', 'heightCm'),
      );

      expect(decoded.profile.heightCm, isNull);
    });

    test('stringifies non-string list elements and drops the rest', () {
      final decoded = HealthContextSnapshotCodec.decode(
        _jsonWith(<Object?>['vegetarian', 7, null], 'dietaryPreferences'),
      );

      expect(decoded.profile.dietaryPreferences, ['vegetarian', '7']);
    });

    test('missing profile fields decode without throwing', () {
      final map =
          jsonDecode(HealthContextSnapshotCodec.encode(_snapshot()))
              as Map<String, dynamic>;
      (map['profile'] as Map<String, dynamic>).remove('dietaryPreferences');

      final decoded = HealthContextSnapshotCodec.decode(jsonEncode(map));

      expect(decoded.profile.dietaryPreferences, isNull);
    });

    test('a wrong-typed summary age is dropped', () {
      final map =
          jsonDecode(HealthContextSnapshotCodec.encode(_snapshot()))
              as Map<String, dynamic>;
      (map['summary'] as Map<String, dynamic>)['age'] = '27';

      final decoded = HealthContextSnapshotCodec.decode(jsonEncode(map));

      expect(decoded.summary.age, isNull);
      expect(decoded.summary.activeAllergyCount, 1);
    });
  });
}
