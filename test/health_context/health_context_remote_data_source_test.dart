import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart' show UserHealthContextApi;
import 'package:luminous/features/health_context/data/datasources/health_context_remote_data_source.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';

void main() {
  late _FakeHealthContextAdapter adapter;
  late HealthContextRemoteDataSource dataSource;

  setUp(() {
    adapter = _FakeHealthContextAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    dio.httpClientAdapter = adapter;
    dataSource = HealthContextRemoteDataSource(
      api: _NoopUserHealthContextApi(),
      dio: dio,
    );
  });

  group('updateProfile', () {
    test('sends PATCH with correct path and explicit fields', () async {
      final result = await dataSource.updateProfile(
        const HealthProfileUpdateInput(
          sexAtBirth: HealthSexAtBirth.female,
          heightCm: 168,
          birthDate: null,
        ),
      );

      final req = adapter.requestAt(
        'PATCH',
        '/api/v1/user/health-context/profile',
      );
      expect(req.jsonBody, <String, dynamic>{
        'sexAtBirth': 'female',
        'heightCm': 168,
        'birthDate': null,
      });
      expect(result.allergies, isEmpty);
    });

    test('omits noChange fields from payload', () async {
      await dataSource.updateProfile(
        const HealthProfileUpdateInput(
          locale: 'zh-CN',
          // All others left as healthContextNoChange (default).
        ),
      );

      final req = adapter.requestAt(
        'PATCH',
        '/api/v1/user/health-context/profile',
      );
      expect(req.jsonBody, <String, dynamic>{'locale': 'zh-CN'});
      expect(req.jsonBody.containsKey('heightCm'), isFalse);
      expect(req.jsonBody.containsKey('sexAtBirth'), isFalse);
    });
  });

  group('allergy CRUD', () {
    test('createAllergy sends POST with correct path and body', () async {
      final result = await dataSource.createAllergy(
        const HealthAllergyWriteInput(
          kind: HealthAllergyKind.drug,
          label: '青霉素',
          severity: HealthAllergySeverity.severe,
          reaction: '皮疹',
        ),
      );

      final req = adapter.requestAt(
        'POST',
        '/api/v1/user/health-context/allergies',
      );
      expect(req.jsonBody, <String, dynamic>{
        'kind': 'drug',
        'label': '青霉素',
        'severity': 'severe',
        'reaction': '皮疹',
      });
      expect(result.allergies, hasLength(1));
    });

    test('createAllergy omits null optional fields', () async {
      await dataSource.createAllergy(
        const HealthAllergyWriteInput(
          kind: HealthAllergyKind.food,
          label: '花生',
        ),
      );

      final req = adapter.requestAt(
        'POST',
        '/api/v1/user/health-context/allergies',
      );
      expect(req.jsonBody, <String, dynamic>{'kind': 'food', 'label': '花生'});
      expect(req.jsonBody.containsKey('reaction'), isFalse);
      expect(req.jsonBody.containsKey('severity'), isFalse);
      expect(req.jsonBody.containsKey('note'), isFalse);
    });

    test(
      'updateAllergy sends PATCH with id in path and changed fields',
      () async {
        final result = await dataSource.updateAllergy(
          'allergy-1',
          const HealthAllergyUpdateInput(
            severity: HealthAllergySeverity.moderate,
            isActive: false,
          ),
        );

        final req = adapter.requestAt(
          'PATCH',
          '/api/v1/user/health-context/allergies/allergy-1',
        );
        expect(req.jsonBody, <String, dynamic>{
          'severity': 'moderate',
          'isActive': false,
        });
        expect(req.jsonBody.containsKey('kind'), isFalse);
        expect(req.jsonBody.containsKey('label'), isFalse);
        expect(result.allergies, hasLength(1));
      },
    );

    test('deleteAllergy sends DELETE with id in path', () async {
      final result = await dataSource.deleteAllergy('allergy-1');

      final req = adapter.requestAt(
        'DELETE',
        '/api/v1/user/health-context/allergies/allergy-1',
      );
      expect(req.jsonBody, isEmpty);
      expect(result.allergies, isEmpty);
    });
  });

  group('condition CRUD', () {
    test('createCondition sends POST with correct path and body', () async {
      final result = await dataSource.createCondition(
        const HealthConditionWriteInput(
          label: '高血压',
          status: HealthConditionStatus.active,
        ),
      );

      final req = adapter.requestAt(
        'POST',
        '/api/v1/user/health-context/conditions',
      );
      expect(req.jsonBody, <String, dynamic>{
        'label': '高血压',
        'status': 'active',
      });
      expect(result.conditions, hasLength(1));
    });

    test('createCondition omits null optional fields', () async {
      await dataSource.createCondition(
        const HealthConditionWriteInput(label: '糖尿病'),
      );

      final req = adapter.requestAt(
        'POST',
        '/api/v1/user/health-context/conditions',
      );
      expect(req.jsonBody, <String, dynamic>{'label': '糖尿病'});
      expect(req.jsonBody.containsKey('status'), isFalse);
      expect(req.jsonBody.containsKey('diagnosedAt'), isFalse);
    });

    test(
      'updateCondition sends PATCH with id in path and changed fields',
      () async {
        final result = await dataSource.updateCondition(
          'cond-1',
          const HealthConditionUpdateInput(
            status: HealthConditionStatus.resolved,
          ),
        );

        final req = adapter.requestAt(
          'PATCH',
          '/api/v1/user/health-context/conditions/cond-1',
        );
        expect(req.jsonBody, <String, dynamic>{'status': 'resolved'});
        expect(req.jsonBody.containsKey('label'), isFalse);
        expect(result.conditions, hasLength(1));
      },
    );

    test('deleteCondition sends DELETE with id in path', () async {
      final result = await dataSource.deleteCondition('cond-1');

      final req = adapter.requestAt(
        'DELETE',
        '/api/v1/user/health-context/conditions/cond-1',
      );
      expect(req.jsonBody, isEmpty);
      expect(result.conditions, isEmpty);
    });
  });

  group('currentMedicine CRUD', () {
    test(
      'createCurrentMedicine sends POST with correct path and body',
      () async {
        final result = await dataSource.createCurrentMedicine(
          const CurrentMedicineWriteInput(
            source: HealthMedicineSource.cn,
            sourceRefId: 'cn_1',
            displayName: '布洛芬片',
            doseText: '200mg bid',
          ),
        );

        final req = adapter.requestAt(
          'POST',
          '/api/v1/user/health-context/current-medicines',
        );
        expect(req.jsonBody, <String, dynamic>{
          'source': 'cn',
          'sourceRefId': 'cn_1',
          'displayName': '布洛芬片',
          'doseText': '200mg bid',
        });
        expect(result.currentMedicines, hasLength(1));
      },
    );

    test('createCurrentMedicine omits null optional fields', () async {
      await dataSource.createCurrentMedicine(
        const CurrentMedicineWriteInput(
          source: HealthMedicineSource.manual,
          displayName: '维生素 D',
        ),
      );

      final req = adapter.requestAt(
        'POST',
        '/api/v1/user/health-context/current-medicines',
      );
      expect(req.jsonBody, <String, dynamic>{
        'source': 'manual',
        'displayName': '维生素 D',
      });
      expect(req.jsonBody.containsKey('sourceRefId'), isFalse);
      expect(req.jsonBody.containsKey('doseText'), isFalse);
      expect(req.jsonBody.containsKey('note'), isFalse);
    });

    test(
      'updateCurrentMedicine sends PATCH with id in path and changed fields',
      () async {
        final result = await dataSource.updateCurrentMedicine(
          'med-1',
          const CurrentMedicineUpdateInput(
            doseText: '400mg bid',
            isCurrent: false,
          ),
        );

        final req = adapter.requestAt(
          'PATCH',
          '/api/v1/user/health-context/current-medicines/med-1',
        );
        expect(req.jsonBody, <String, dynamic>{
          'doseText': '400mg bid',
          'isCurrent': false,
        });
        expect(req.jsonBody.containsKey('source'), isFalse);
        expect(req.jsonBody.containsKey('displayName'), isFalse);
        expect(result.currentMedicines, hasLength(1));
      },
    );

    test('deleteCurrentMedicine sends DELETE with id in path', () async {
      final result = await dataSource.deleteCurrentMedicine('med-1');

      final req = adapter.requestAt(
        'DELETE',
        '/api/v1/user/health-context/current-medicines/med-1',
      );
      expect(req.jsonBody, isEmpty);
      expect(result.currentMedicines, isEmpty);
    });
  });

  group('error handling', () {
    test('throws DioException on empty response body', () async {
      adapter.emptyResponse = true;

      expect(
        () => dataSource.updateProfile(const HealthProfileUpdateInput()),
        throwsA(isA<DioException>()),
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Fake Dio adapter
// ---------------------------------------------------------------------------

class _FakeHealthContextAdapter implements HttpClientAdapter {
  final requests = <_CapturedRequest>[];
  bool emptyResponse = false;

  _CapturedRequest requestAt(String method, String path) {
    return requests.singleWhere((r) => r.method == method && r.path == path);
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bodyBytes = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        bodyBytes.addAll(chunk);
      }
    }

    requests.add(
      _CapturedRequest(
        method: options.method,
        path: options.path,
        bodyBytes: bodyBytes,
      ),
    );

    if (emptyResponse) {
      return ResponseBody.fromString('', 200);
    }

    // Determine what kind of resource is being operated on for the response.
    final path = options.path;
    final method = options.method;
    final bool isDelete = method == 'DELETE';
    final List<Map<String, Object?>> items;
    if (path.contains('/allergies')) {
      items = isDelete
          ? []
          : [
              <String, Object?>{
                'id': 'a-1',
                'kind': 'drug',
                'label': '测试过敏',
                'reaction': null,
                'severity': 'mild',
                'isActive': true,
                'note': null,
                'extras': <String, Object?>{},
                'recordedAt': null,
                'createdAt': '2026-06-12T00:00:00.000Z',
                'updatedAt': '2026-06-12T00:00:00.000Z',
              },
            ];
    } else if (path.contains('/conditions')) {
      items = isDelete
          ? []
          : [
              <String, Object?>{
                'id': 'c-1',
                'label': '测试病症',
                'status': 'active',
                'diagnosedAt': null,
                'resolvedAt': null,
                'note': null,
                'extras': <String, Object?>{},
                'createdAt': '2026-06-12T00:00:00.000Z',
                'updatedAt': '2026-06-12T00:00:00.000Z',
              },
            ];
    } else if (path.contains('/current-medicines')) {
      items = isDelete
          ? []
          : [
              <String, Object?>{
                'id': 'm-1',
                'source': 'cn',
                'sourceRefId': 'cn_1',
                'displayName': '测试药物',
                'strengthText': null,
                'doseText': null,
                'route': null,
                'startedAt': null,
                'endedAt': null,
                'isCurrent': true,
                'note': null,
                'sourcePayload': <String, Object?>{},
                'createdAt': '2026-06-12T00:00:00.000Z',
                'updatedAt': '2026-06-12T00:00:00.000Z',
              },
            ];
    } else {
      items = [];
    }

    return _jsonResponse(<String, Object?>{
      'code': 0,
      'message': 'ok',
      'data': _healthContextBody(items),
    });
  }

  @override
  void close({bool force = false}) {}

  ResponseBody _jsonResponse(Map<String, Object?> body) {
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: const <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }
}

Map<String, Object?> _healthContextBody(List<Map<String, Object?>> items) {
  // Determine list keys from the items for allergy/condition/medicine.
  final allergies = <Map<String, Object?>>[];
  final conditions = <Map<String, Object?>>[];
  final currentMedicines = <Map<String, Object?>>[];

  for (final item in items) {
    if (item.containsKey('kind')) {
      allergies.add(item);
    } else if (item.containsKey('status') && item.containsKey('diagnosedAt')) {
      conditions.add(item);
    } else {
      currentMedicines.add(item);
    }
  }

  return <String, Object?>{
    'summary': <String, Object?>{
      'age': null,
      'onboardingCompleted': false,
      'activeAllergyCount': allergies.length,
      'conditionCount': conditions.length,
      'currentMedicineCount': currentMedicines.length,
      'missingCoreProfileFields': <Object?>[],
    },
    'profile': <String, Object?>{
      'birthDate': null,
      'sexAtBirth': null,
      'heightCm': null,
      'bloodType': null,
      'locale': null,
      'timezone': null,
      'unitSystem': null,
      'onboardingCompletedAt': null,
      'extras': <String, Object?>{},
    },
    'allergies': allergies,
    'conditions': conditions,
    'currentMedicines': currentMedicines,
  };
}

class _CapturedRequest {
  const _CapturedRequest({
    required this.method,
    required this.path,
    required this.bodyBytes,
  });

  final String method;
  final String path;
  final List<int> bodyBytes;

  Map<String, dynamic> get jsonBody {
    if (bodyBytes.isEmpty) return const <String, dynamic>{};
    return jsonDecode(utf8.decode(bodyBytes)) as Map<String, dynamic>;
  }
}

/// Minimal no-op stub for [UserHealthContextApi] – the data source only uses
/// the raw `Dio` instance for writes, so the generated API is unused here.
class _NoopUserHealthContextApi extends UserHealthContextApi {
  _NoopUserHealthContextApi() : super(Dio());
}
