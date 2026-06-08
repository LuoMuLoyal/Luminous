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
      ),
    );

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
}

class _CapturedReminderRequest {
  const _CapturedReminderRequest({
    required this.method,
    required this.path,
    required this.queryParameters,
  });

  final String method;
  final String path;
  final Map<String, Object?> queryParameters;
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
