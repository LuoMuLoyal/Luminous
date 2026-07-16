// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';

import 'package:luminous/core/database/cache_constants.dart';
import 'package:luminous/core/database/daos/health_context_dao.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/health_context/data/datasources/snapshot.dart';
import 'package:luminous/features/health_context/data/mappers/mapper.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';

/// Cache-first implementation of [HealthContextRepository].
///
/// Read: returns cached snapshot immediately + background refresh (throttled 30s).
/// If cache is empty, fetches from network and populates cache.
/// Write: after successful remote mutation, replaces the cached snapshot.
class LucentHealthContextRepository implements HealthContextRepository {
  LucentHealthContextRepository({
    required HealthContextRemoteDataSource dataSource,
    required HealthContextMapper mapper,
    required this.dao,
  }) : _dataSource = dataSource,
       _mapper = mapper;

  final HealthContextRemoteDataSource _dataSource;
  final HealthContextMapper _mapper;
  final HealthContextDao dao;

  DateTime? _lastRefreshAttempt;

  @override
  Future<HealthContextSnapshot> fetchHealthContext() async {
    // 1. Check cache
    final cachedJson = await dao.fetch();
    if (cachedJson != null) {
      final cached = _decodeSnapshot(cachedJson);
      // Background refresh (throttled)
      _refreshInBackground();
      return cached;
    }

    // 2. Cache empty → fetch from network
    final dto = await _dataSource.fetchHealthContext();
    final snapshot = _mapper.fromDto(dto);
    await dao.replace(_encodeSnapshot(snapshot));
    return snapshot;
  }

  @override
  Future<HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) async {
    final result = await _dataSource.updateProfile(input);
    final snapshot = _mapper.fromDto(result);
    await dao.replace(_encodeSnapshot(snapshot));
    return snapshot;
  }

  @override
  Future<HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) async {
    final result = await _dataSource.createAllergy(input);
    final snapshot = _mapper.fromDto(result);
    await dao.replace(_encodeSnapshot(snapshot));
    return snapshot;
  }

  @override
  Future<HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) async {
    final result = await _dataSource.updateAllergy(id, input);
    final snapshot = _mapper.fromDto(result);
    await dao.replace(_encodeSnapshot(snapshot));
    return snapshot;
  }

  @override
  Future<HealthContextSnapshot> deleteAllergy(String id) async {
    final result = await _dataSource.deleteAllergy(id);
    final snapshot = _mapper.fromDto(result);
    await dao.replace(_encodeSnapshot(snapshot));
    return snapshot;
  }

  @override
  Future<HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) async {
    final result = await _dataSource.createCondition(input);
    final snapshot = _mapper.fromDto(result);
    await dao.replace(_encodeSnapshot(snapshot));
    return snapshot;
  }

  @override
  Future<HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) async {
    final result = await _dataSource.updateCondition(id, input);
    final snapshot = _mapper.fromDto(result);
    await dao.replace(_encodeSnapshot(snapshot));
    return snapshot;
  }

  @override
  Future<HealthContextSnapshot> deleteCondition(String id) async {
    final result = await _dataSource.deleteCondition(id);
    final snapshot = _mapper.fromDto(result);
    await dao.replace(_encodeSnapshot(snapshot));
    return snapshot;
  }

  @override
  Future<HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) async {
    final result = await _dataSource.createCurrentMedicine(input);
    final snapshot = _mapper.fromDto(result);
    await dao.replace(_encodeSnapshot(snapshot));
    return snapshot;
  }

  @override
  Future<HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) async {
    final result = await _dataSource.updateCurrentMedicine(id, input);
    final snapshot = _mapper.fromDto(result);
    await dao.replace(_encodeSnapshot(snapshot));
    return snapshot;
  }

  @override
  Future<HealthContextSnapshot> deleteCurrentMedicine(String id) async {
    final result = await _dataSource.deleteCurrentMedicine(id);
    final snapshot = _mapper.fromDto(result);
    await dao.replace(_encodeSnapshot(snapshot));
    return snapshot;
  }

  void _refreshInBackground() {
    final now = DateTime.now();
    if (_lastRefreshAttempt != null &&
        now.difference(_lastRefreshAttempt!) < backgroundRefreshThrottle) {
      return;
    }
    _lastRefreshAttempt = now;

    unawaited(
      Future(() async {
        try {
          final dto = await _dataSource.fetchHealthContext();
          final snapshot = _mapper.fromDto(dto);
          await dao.replace(_encodeSnapshot(snapshot));
        } catch (e) {
          appTalker.warning('HealthContext background refresh failed: $e');
        }
      }),
    );
  }

  String _encodeSnapshot(HealthContextSnapshot snapshot) {
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
        'bloodType': snapshot.profile.bloodType,
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

  HealthContextSnapshot _decodeSnapshot(String json) {
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
        bloodType: p['bloodType'] as String?,
        locale: p['locale'] as String?,
        timezone: p['timezone'] as String?,
        unitSystem: p['unitSystem'] as String?,
        onboardingCompletedAt: p['onboardingCompletedAt'] as String?,
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

  Map<String, dynamic> _allergyToJson(AllergyItem a) => {
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

  AllergyItem _allergyFromJson(Map<String, dynamic> m) => AllergyItem(
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

  Map<String, dynamic> _conditionToJson(ConditionItem c) => {
    'id': c.id,
    'label': c.label,
    'status': c.status,
    'diagnosedAt': c.diagnosedAt,
    'resolvedAt': c.resolvedAt,
    'note': c.note,
    'createdAt': c.createdAt,
    'updatedAt': c.updatedAt,
  };

  ConditionItem _conditionFromJson(Map<String, dynamic> m) => ConditionItem(
    id: m['id'] as String,
    label: m['label'] as String,
    status: m['status'] as String,
    diagnosedAt: m['diagnosedAt'] as String?,
    resolvedAt: m['resolvedAt'] as String?,
    note: m['note'] as String?,
    createdAt: m['createdAt'] as String,
    updatedAt: m['updatedAt'] as String,
  );

  Map<String, dynamic> _medicineToJson(CurrentMedicineItem m) => {
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

  CurrentMedicineItem _medicineFromJson(Map<String, dynamic> m) =>
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
