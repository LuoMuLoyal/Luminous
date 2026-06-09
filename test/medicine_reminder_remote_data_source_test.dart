import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart' show MedicineRemindersApi;
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';

void main() {
  group('MedicineReminderRemoteDataSource', () {
    late _FakeReminderAdapter adapter;
    late MedicineReminderRemoteDataSource dataSource;

    setUp(() {
      adapter = _FakeReminderAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
      dio.httpClientAdapter = adapter;
      dataSource = MedicineReminderRemoteDataSource(
        api: MedicineRemindersApi(dio),
        dio: dio,
      );
    });

    test(
      'fetchActive requests active reminders and maps schedule fields',
      () async {
        adapter.items = [
          _reminderJson(
            id: 'reminder-1',
            currentMedicineId: 'med-1',
            scheduledHour: 7,
            scheduledMinute: 5,
            daysOfWeek: [1, 3, 5],
          ),
        ];

        final reminders = await dataSource.fetchActive();

        final request = adapter.requestAt(
          'GET',
          '/api/v1/me/medicine-reminders',
        );
        expect(request.queryParameters, containsPair('activeOnly', 'true'));
        expect(reminders, hasLength(1));
        expect(reminders.single.id, 'reminder-1');
        expect(reminders.single.currentMedicineId, 'med-1');
        expect(reminders.single.timeLabel, '07:05');
        expect(reminders.single.daysOfWeek, [1, 3, 5]);
        expect(reminders.single.matchesDate(DateTime(2026, 6, 8)), isTrue);
        expect(reminders.single.matchesDate(DateTime(2026, 6, 9)), isFalse);
      },
    );

    test('null daysOfWeek matches every day', () async {
      adapter.items = [
        _reminderJson(
          id: 'reminder-2',
          currentMedicineId: 'med-1',
          scheduledHour: 20,
          scheduledMinute: 0,
          daysOfWeek: null,
        ),
      ];

      final reminder = (await dataSource.fetchActive()).single;

      expect(reminder.timeLabel, '20:00');
      expect(reminder.daysOfWeek, isNull);
      expect(reminder.matchesDate(DateTime(2026, 6, 8)), isTrue);
      expect(reminder.matchesDate(DateTime(2026, 6, 14)), isTrue);
    });

    test('fetchAll omits activeOnly filter', () async {
      adapter.items = [
        _reminderJson(
          id: 'reminder-3',
          currentMedicineId: 'med-1',
          scheduledHour: 9,
          scheduledMinute: 0,
          daysOfWeek: null,
        ),
      ];

      final reminders = await dataSource.fetchAll();

      final request = adapter.requestAt('GET', '/api/v1/me/medicine-reminders');
      expect(request.queryParameters, isNot(contains('activeOnly')));
      expect(reminders.single.id, 'reminder-3');
    });

    test('create sends reminder payload and maps response', () async {
      final reminder = await dataSource.create(
        const MedicineReminderWriteInput(
          currentMedicineId: 'med-1',
          label: 'Morning',
          scheduledHour: 8,
          scheduledMinute: 30,
          daysOfWeek: [1, 2, 3],
          note: 'After breakfast',
        ),
      );

      final request = adapter.requestAt(
        'POST',
        '/api/v1/me/medicine-reminders',
      );
      expect(request.body, containsPair('currentMedicineId', 'med-1'));
      expect(request.body, containsPair('label', 'Morning'));
      expect(request.body, containsPair('scheduledHour', 8));
      expect(request.body, containsPair('scheduledMinute', 30));
      expect(request.body, containsPair('daysOfWeek', [1, 2, 3]));
      expect(request.body, containsPair('isActive', true));
      expect(request.body, containsPair('note', 'After breakfast'));
      expect(reminder.id, 'reminder-new');
      expect(reminder.timeLabel, '08:30');
    });

    test('update can send null daysOfWeek for every day schedule', () async {
      final reminder = await dataSource.update(
        'reminder-1',
        const MedicineReminderWriteInput(
          currentMedicineId: 'med-1',
          label: 'Daily',
          scheduledHour: 20,
          scheduledMinute: 0,
          daysOfWeek: null,
          note: null,
        ),
      );

      final request = adapter.requestAt(
        'PATCH',
        '/api/v1/me/medicine-reminders/reminder-1',
      );
      expect(request.body, containsPair('currentMedicineId', 'med-1'));
      expect(request.body, containsPair('scheduledHour', 20));
      expect(request.body, containsPair('scheduledMinute', 0));
      expect(request.body!.containsKey('daysOfWeek'), isTrue);
      expect(request.body, containsPair('daysOfWeek', null));
      expect(reminder.id, 'reminder-1');
      expect(reminder.daysOfWeek, isNull);
    });

    test('delete calls reminder endpoint', () async {
      await dataSource.delete('reminder-1');

      final request = adapter.requestAt(
        'DELETE',
        '/api/v1/me/medicine-reminders/reminder-1',
      );
      expect(request.body, isNull);
    });
  });
}

class _FakeReminderAdapter implements HttpClientAdapter {
  final requests = <_CapturedReminderRequest>[];
  List<Map<String, Object?>> items = const <Map<String, Object?>>[];

  _CapturedReminderRequest requestAt(String method, String path) {
    return requests.singleWhere(
      (request) => request.method == method && request.path == path,
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(
      _CapturedReminderRequest(
        method: options.method,
        path: options.path,
        queryParameters: Map<String, Object?>.from(options.queryParameters),
        body: await _readJsonBody(requestStream),
      ),
    );

    if (options.method == 'DELETE') {
      return ResponseBody.fromString('', 204);
    }

    final body = requests.last.body;
    if (options.method == 'POST' || options.method == 'PATCH') {
      return ResponseBody.fromString(
        jsonEncode(<String, Object?>{
          'code': 0,
          'message': '',
          'data': <String, Object?>{
            'id': options.method == 'PATCH' ? 'reminder-1' : 'reminder-new',
            'currentMedicineId': body?['currentMedicineId'],
            'label': body?['label'],
            'scheduledHour': body?['scheduledHour'],
            'scheduledMinute': body?['scheduledMinute'],
            'daysOfWeek': body?.containsKey('daysOfWeek') == true
                ? body!['daysOfWeek']
                : null,
            'isActive': body?['isActive'] ?? true,
            'note': body?['note'],
            'createdAt': '2026-06-08T07:00:00.000Z',
            'updatedAt': '2026-06-09T07:00:00.000Z',
          },
        }),
        200,
        headers: const <String, List<String>>{
          Headers.contentTypeHeader: <String>['application/json'],
        },
      );
    }

    return ResponseBody.fromString(
      jsonEncode(<String, Object?>{
        'code': 0,
        'message': '',
        'data': <String, Object?>{'items': items},
      }),
      200,
      headers: const <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}

  Future<Map<String, Object?>?> _readJsonBody(
    Stream<Uint8List>? requestStream,
  ) async {
    if (requestStream == null) return null;
    final chunks = await requestStream.toList();
    if (chunks.isEmpty) return null;
    final bytes = chunks.expand((chunk) => chunk).toList(growable: false);
    if (bytes.isEmpty) return null;
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry('$key', value));
    }
    return null;
  }
}

class _CapturedReminderRequest {
  const _CapturedReminderRequest({
    required this.method,
    required this.path,
    required this.queryParameters,
    required this.body,
  });

  final String method;
  final String path;
  final Map<String, Object?> queryParameters;
  final Map<String, Object?>? body;
}

Map<String, Object?> _reminderJson({
  required String id,
  required String currentMedicineId,
  required int scheduledHour,
  required int scheduledMinute,
  required List<int>? daysOfWeek,
}) {
  return <String, Object?>{
    'id': id,
    'currentMedicineId': currentMedicineId,
    'label': 'Morning reminder',
    'scheduledHour': scheduledHour,
    'scheduledMinute': scheduledMinute,
    'daysOfWeek': daysOfWeek,
    'isActive': true,
    'note': null,
    'createdAt': '2026-06-08T07:00:00.000Z',
    'updatedAt': '2026-06-08T07:00:00.000Z',
  };
}
