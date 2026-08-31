import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/features/record/data/repositories/lucent.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';

// ── Fake DailyRecordRepository ──────────────────────────────────

class _FakeDailyRecordRepository implements DailyRecordRepository {
  DailyRecordListData? fetchRecordsResult;
  Object? fetchRecordsError;
  String? lastFetchDate;
  String? lastFetchKind;
  int? lastFetchPage;
  int? lastFetchPageSize;

  DailyRecordSummaryData? fetchSummaryResult;
  Object? fetchSummaryError;
  String? lastFetchSummaryDate;

  @override
  TaskEither<LucentFailure, DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) {
    lastFetchDate = date;
    lastFetchKind = kind;
    lastFetchPage = page;
    lastFetchPageSize = pageSize;
    if (fetchRecordsError != null) {
      return TaskEither.left(LucentErrorMapper.fromObject(fetchRecordsError!));
    }
    return TaskEither.right(
      fetchRecordsResult ?? const DailyRecordListData(items: [], total: 0),
    );
  }

  @override
  TaskEither<LucentFailure, DailyRecordSummaryData> fetchSummary(String date) {
    lastFetchSummaryDate = date;
    if (fetchSummaryError != null) {
      return TaskEither.left(LucentErrorMapper.fromObject(fetchSummaryError!));
    }
    return TaskEither.right(
      fetchSummaryResult ?? const DailyRecordSummaryData(summaries: []),
    );
  }

  @override
  TaskEither<LucentFailure, DailyRecordItem> get(String id) =>
      throw UnimplementedError();

  @override
  TaskEither<LucentFailure, DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, DailyRecordItem> create(
    DailyRecordCreateInput input,
  ) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, void> delete(String id) =>
      throw UnimplementedError();
}

DailyRecordItem _item({
  String id = 'rec-1',
  DailyRecordKind kind = DailyRecordKind.water,
  String occurredAt = '2026-07-14',
  String? occurredTime = '08:30',
  String? title,
  String? value,
  String? unit,
  String? note,
  Map<String, dynamic>? payload,
  String? mealAnalysisStatus,
  String? mealAnalysisCoverage,
  String? mealShortDescription,
  List<String> mealTopFoods = const [],
  List<DailyRecordAttachment> attachments = const [],
}) {
  return DailyRecordItem(
    id: id,
    kind: kind,
    occurredAt: occurredAt,
    occurredTime: occurredTime,
    title: title,
    value: value,
    unit: unit,
    note: note,
    payload: payload,
    mealAnalysisStatus: mealAnalysisStatus,
    mealAnalysisCoverage: mealAnalysisCoverage,
    mealShortDescription: mealShortDescription,
    mealTopFoods: mealTopFoods,
    attachments: attachments,
    createdAt: '2026-07-14T08:30:00Z',
    updatedAt: '2026-07-14T08:30:00Z',
  );
}

void main() {
  late _FakeDailyRecordRepository dailyRepo;
  late LucentRecordRepository repo;

  setUp(() {
    dailyRepo = _FakeDailyRecordRepository();
    repo = LucentRecordRepository(dailyRecordRepo: dailyRepo);
  });

  /// Runs the repository's dashboard task, failing the test on Left.
  Future<RecordDashboard> fetchDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) async {
    final result = await repo
        .fetchDashboard(selectedDate, filterType: filterType)
        .run();
    return result.fold(
      (failure) => fail('expected Right, got Left: $failure'),
      (dashboard) => dashboard,
    );
  }

  // ── fetchDashboard — basic orchestration ─────────────────────
  group('fetchDashboard', () {
    test('returns dashboard with empty timeline when no records', () async {
      dailyRepo.fetchRecordsResult = const DailyRecordListData(
        items: [],
        total: 0,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.selectedDate, DateTime(2026, 7, 14));
      expect(dashboard.selectedDay, 14);
      expect(dashboard.timeline, isEmpty);
      expect(dashboard.summary.items, isEmpty);
    });

    test(
      'returns dashboard with timeline entries when records exist',
      () async {
        dailyRepo.fetchRecordsResult = DailyRecordListData(
          items: [
            _item(
              id: 'r1',
              kind: DailyRecordKind.water,
              value: '500',
              unit: 'ml',
            ),
            _item(id: 'r2', kind: DailyRecordKind.meal, title: 'Lunch'),
          ],
          total: 2,
        );

        final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

        expect(dashboard.timeline, hasLength(2));
        expect(dashboard.timeline[0].recordId, 'r1');
        expect(dashboard.timeline[1].recordId, 'r2');
      },
    );

    test('passes correct date string to dailyRepo', () async {
      dailyRepo.fetchRecordsResult = const DailyRecordListData(
        items: [],
        total: 0,
      );

      await fetchDashboard(DateTime(2026, 3, 5));

      expect(dailyRepo.lastFetchDate, '2026-03-05');
    });

    test('passes kind filter when filterType is provided', () async {
      dailyRepo.fetchRecordsResult = const DailyRecordListData(
        items: [],
        total: 0,
      );

      await fetchDashboard(
        DateTime(2026, 7, 14),
        filterType: RecordEntryType.water,
      );

      expect(dailyRepo.lastFetchKind, 'water');
    });

    test('does not pass kind filter when filterType is null', () async {
      dailyRepo.fetchRecordsResult = const DailyRecordListData(
        items: [],
        total: 0,
      );

      await fetchDashboard(DateTime(2026, 7, 14));

      expect(dailyRepo.lastFetchKind, isNull);
    });

    test(
      'returns empty timeline for medication filterType (no matching kind)',
      () async {
        dailyRepo.fetchRecordsResult = const DailyRecordListData(
          items: [],
          total: 0,
        );

        await fetchDashboard(
          DateTime(2026, 7, 14),
          filterType: RecordEntryType.medication,
        );

        // medication has no matching DailyRecordKind, so no fetch should occur
        expect(dailyRepo.lastFetchDate, isNull);
      },
    );

    test('returns empty timeline when fetchRecords throws', () async {
      dailyRepo.fetchRecordsError = Exception('Network error');

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline, isEmpty);
    });

    test('fetches records and summary with the same date string', () async {
      dailyRepo.fetchRecordsResult = const DailyRecordListData(
        items: [],
        total: 0,
      );

      await fetchDashboard(DateTime(2026, 7, 14));

      expect(dailyRepo.lastFetchDate, '2026-07-14');
      expect(dailyRepo.lastFetchSummaryDate, '2026-07-14');
    });

    test('maps summaries to items with water ml aggregation', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(
            id: 'w1',
            kind: DailyRecordKind.water,
            value: '250',
            unit: 'ml',
          ),
          _item(
            id: 'w2',
            kind: DailyRecordKind.water,
            value: '300',
            unit: 'ml',
          ),
          _item(id: 'w3', kind: DailyRecordKind.water, value: '1', unit: 'cup'),
        ],
        total: 3,
      );
      dailyRepo.fetchSummaryResult = DailyRecordSummaryData(
        summaries: [
          DailyRecordSummary(
            kind: DailyRecordKind.water,
            count: 3,
            latest: _item(
              kind: DailyRecordKind.water,
              value: '250',
              unit: 'ml',
            ),
          ),
          const DailyRecordSummary(kind: DailyRecordKind.meal, count: 2),
        ],
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      final water = dashboard.summary.items.firstWhere(
        (item) => item.type == RecordEntryType.water,
      );
      expect(water.value, '550');
      expect(water.unitKey, RecordCopyKey.summaryMlUnit);
      expect(water.titleKey, RecordCopyKey.summaryWaterTitle);
      expect(water.icon, SemanticIcons.recordWater);

      final meal = dashboard.summary.items.firstWhere(
        (item) => item.type == RecordEntryType.meal,
      );
      expect(meal.value, '2');
      expect(meal.unitKey, RecordCopyKey.summaryTimesUnit);
    });

    test('water item falls back to count when no ml records exist', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(id: 'w1', kind: DailyRecordKind.water, value: '1', unit: 'cup'),
          _item(
            id: 'w2',
            kind: DailyRecordKind.water,
            value: '2',
            unit: 'times',
          ),
        ],
        total: 2,
      );
      dailyRepo.fetchSummaryResult = const DailyRecordSummaryData(
        summaries: [DailyRecordSummary(kind: DailyRecordKind.water, count: 3)],
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      final water = dashboard.summary.items.single;
      expect(water.value, '3');
      expect(water.unitKey, RecordCopyKey.summaryTimesUnit);
    });

    test('vital item shows the latest record value when present', () async {
      dailyRepo.fetchRecordsResult = const DailyRecordListData(
        items: [],
        total: 0,
      );
      dailyRepo.fetchSummaryResult = DailyRecordSummaryData(
        summaries: [
          DailyRecordSummary(
            kind: DailyRecordKind.vital,
            count: 3,
            latest: _item(
              kind: DailyRecordKind.vital,
              value: '72',
              unit: 'bpm',
            ),
          ),
        ],
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      final vital = dashboard.summary.items.single;
      expect(vital.type, RecordEntryType.vitals);
      expect(vital.value, '72 bpm');
      expect(vital.unitKey, isNull);
      expect(vital.titleKey, RecordCopyKey.summaryLatestVitalTitle);
      expect(vital.icon, SemanticIcons.profileCondition);
    });

    test(
      'vital item falls back to count when no latest value exists',
      () async {
        dailyRepo.fetchRecordsResult = const DailyRecordListData(
          items: [],
          total: 0,
        );
        dailyRepo.fetchSummaryResult = const DailyRecordSummaryData(
          summaries: [
            DailyRecordSummary(kind: DailyRecordKind.vital, count: 2),
          ],
        );

        final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

        final vital = dashboard.summary.items.single;
        expect(vital.value, '2');
        expect(vital.unitKey, RecordCopyKey.summaryTimesUnit);
        expect(vital.titleKey, RecordCopyKey.summaryLatestVitalTitle);
      },
    );

    test('skips summary kinds with zero count', () async {
      dailyRepo.fetchRecordsResult = const DailyRecordListData(
        items: [],
        total: 0,
      );
      dailyRepo.fetchSummaryResult = const DailyRecordSummaryData(
        summaries: [
          DailyRecordSummary(kind: DailyRecordKind.water, count: 0),
          DailyRecordSummary(kind: DailyRecordKind.meal, count: 2),
        ],
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.summary.items, hasLength(1));
      expect(dashboard.summary.items.first.type, RecordEntryType.meal);
    });

    test('does not generate items for kinds without summary copy', () async {
      dailyRepo.fetchRecordsResult = const DailyRecordListData(
        items: [],
        total: 0,
      );
      dailyRepo.fetchSummaryResult = const DailyRecordSummaryData(
        summaries: [
          DailyRecordSummary(kind: DailyRecordKind.symptom, count: 1),
          DailyRecordSummary(kind: DailyRecordKind.sleep, count: 1),
          DailyRecordSummary(kind: DailyRecordKind.note, count: 1),
          DailyRecordSummary(kind: DailyRecordKind.activity, count: 1),
        ],
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.summary.items, isEmpty);
    });

    test('degrades to empty summary when fetchSummary throws', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(
            id: 'r1',
            kind: DailyRecordKind.water,
            value: '500',
            unit: 'ml',
          ),
        ],
        total: 1,
      );
      dailyRepo.fetchSummaryError = Exception('Summary error');

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.summary.items, isEmpty);
      // Timeline is not affected by a summary failure.
      expect(dashboard.timeline, hasLength(1));
    });
  });

  // ── _toTimelineEntry — icon mapping ──────────────────────────
  group('timeline icon mapping', () {
    // vital and activity are active record entry types; their icons are
    // asserted separately below.
    final cases = [
      (DailyRecordKind.water, SemanticIcons.recordWater),
      (DailyRecordKind.meal, SemanticIcons.recordMeal),
      (DailyRecordKind.mood, SemanticIcons.recordMood),
      (DailyRecordKind.symptom, SemanticIcons.safetyDanger),
      (DailyRecordKind.note, SemanticIcons.tabRecord),
      (DailyRecordKind.sleep, SemanticIcons.recordMoon),
    ];

    for (final (kind, expectedIcon) in cases) {
      test('maps ${kind.name} to correct icon', () async {
        dailyRepo.fetchRecordsResult = DailyRecordListData(
          items: [_item(kind: kind)],
          total: 1,
        );

        final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

        expect(dashboard.timeline.first.icon, expectedIcon);
      });
    }
  });

  // ── _toTimelineEntry — title resolution ──────────────────────
  group('timeline title resolution', () {
    test('uses record.title when present', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [_item(kind: DailyRecordKind.water, title: 'Morning Water')],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.rawTitle, 'Morning Water');
    });

    test('uses mealShortDescription for meal when title is null', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(
            kind: DailyRecordKind.meal,
            title: null,
            mealShortDescription: 'Rice with chicken',
          ),
        ],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.rawTitle, 'Rice with chicken');
    });

    test(
      'uses kind+value fallback for non-meal/non-note/non-mood kinds',
      () async {
        dailyRepo.fetchRecordsResult = DailyRecordListData(
          items: [
            _item(
              kind: DailyRecordKind.water,
              title: null,
              value: '500',
              unit: 'ml',
            ),
          ],
          total: 1,
        );

        final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

        // rawTitle falls back to "kind value" format
        expect(dashboard.timeline.first.rawTitle, isNotNull);
        expect(dashboard.timeline.first.rawTitle, contains('water'));
        expect(dashboard.timeline.first.rawTitle, contains('500'));
      },
    );

    test('sets rawTitle to null for note kind when title is null', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [_item(kind: DailyRecordKind.note, title: null)],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.rawTitle, isNull);
    });

    test('sets rawTitle to null for mood kind when title is null', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [_item(kind: DailyRecordKind.mood, title: null)],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.rawTitle, isNull);
    });
  });

  // ── _toTimelineEntry — value formatting ──────────────────────
  group('timeline value formatting', () {
    test('formats value with unit for non-meal kinds', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [_item(kind: DailyRecordKind.water, value: '500', unit: 'ml')],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.value, '500 ml');
    });

    test('uses note as value when value is null for non-meal kinds', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(
            kind: DailyRecordKind.note,
            value: null,
            note: 'Feeling good today',
          ),
        ],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.value, 'Feeling good today');
    });

    test('formats sleep duration from payload', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(
            kind: DailyRecordKind.sleep,
            value: null,
            payload: {'durationMinutes': 450}, // 7h 30m
          ),
        ],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.value, '7h 30m');
    });

    test('sleep duration only hours when minutes are zero', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(
            kind: DailyRecordKind.sleep,
            value: null,
            payload: {'durationMinutes': 420}, // 7h 0m
          ),
        ],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.value, '7h');
    });

    test('sleep duration only minutes when hours are zero', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(
            kind: DailyRecordKind.sleep,
            value: null,
            payload: {'durationMinutes': 30}, // 0h 30m
          ),
        ],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.value, '30m');
    });

    test('sleep payload ignored when durationMinutes is not a num', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(
            kind: DailyRecordKind.sleep,
            value: null,
            payload: {'durationMinutes': 'abc'},
          ),
        ],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.value, isNull);
    });

    test(
      'sleep payload ignored when durationMinutes is zero or negative',
      () async {
        dailyRepo.fetchRecordsResult = DailyRecordListData(
          items: [
            _item(
              kind: DailyRecordKind.sleep,
              value: null,
              payload: {'durationMinutes': 0},
            ),
          ],
          total: 1,
        );

        final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

        expect(dashboard.timeline.first.value, isNull);
      },
    );

    test('sleep payload ignored for non-sleep kinds', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(
            kind: DailyRecordKind.water,
            value: null,
            payload: {'durationMinutes': 450},
          ),
        ],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.value, isNull);
    });

    test('uses mealShortDescription for meal value', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(
            kind: DailyRecordKind.meal,
            mealShortDescription: 'Light breakfast',
          ),
        ],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.value, 'Light breakfast');
    });
  });

  // ── _toTimelineEntry — mood value key mapping ────────────────
  group('mood value key mapping', () {
    final cases = [
      ('great', RecordCopyKey.timelineMoodGreat),
      ('good', RecordCopyKey.timelineMoodGood),
      ('okay', RecordCopyKey.timelineMoodOkay),
      ('bad', RecordCopyKey.timelineMoodBad),
      ('terrible', RecordCopyKey.timelineMoodTerrible),
    ];

    for (final (label, expectedKey) in cases) {
      test('maps mood label "$label" to correct key', () async {
        dailyRepo.fetchRecordsResult = DailyRecordListData(
          items: [
            _item(kind: DailyRecordKind.mood, payload: {'moodLabel': label}),
          ],
          total: 1,
        );

        final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

        expect(dashboard.timeline.first.valueKey, expectedKey);
      });
    }

    test('returns null valueKey for unknown mood label', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(
            kind: DailyRecordKind.mood,
            payload: {'moodLabel': 'unknown_mood'},
          ),
        ],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.valueKey, isNull);
    });

    test('returns null valueKey when moodLabel is not a String', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(kind: DailyRecordKind.mood, payload: {'moodLabel': 123}),
        ],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.valueKey, isNull);
    });

    test('returns null valueKey for non-mood kinds', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(kind: DailyRecordKind.water, payload: {'moodLabel': 'great'}),
        ],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.valueKey, isNull);
    });

    test('returns null valueKey when payload is null', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [_item(kind: DailyRecordKind.mood, payload: null)],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.valueKey, isNull);
    });
  });

  // ── _toTimelineEntry — meal badge key mapping ────────────────
  group('meal badge key mapping', () {
    final cases = [
      ('confirmed', RecordCopyKey.timelineMealConfirmedBadge),
      ('analysis_failed', RecordCopyKey.timelineMealFailedBadge),
      ('analyzing', RecordCopyKey.timelineMealAnalyzingBadge),
      ('unconfirmed', RecordCopyKey.timelineMealEstimateBadge),
      ('', RecordCopyKey.timelineMealEstimateBadge),
      ('unknown_status', RecordCopyKey.timelineMealEstimateBadge),
    ];

    for (final (status, expectedKey) in cases) {
      test('maps mealAnalysisStatus "$status" to correct badge key', () async {
        dailyRepo.fetchRecordsResult = DailyRecordListData(
          items: [
            _item(kind: DailyRecordKind.meal, mealAnalysisStatus: status),
          ],
          total: 1,
        );

        final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

        expect(dashboard.timeline.first.badgeKey, expectedKey);
      });
    }

    test('returns null badgeKey for non-meal kinds', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(kind: DailyRecordKind.water, mealAnalysisStatus: 'confirmed'),
        ],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.badgeKey, isNull);
    });
  });

  // ── _toTimelineEntry — image URL extraction ─────────────────
  group('image URL extraction', () {
    test('extracts first image attachment URL', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(
            attachments: [
              const DailyRecordAttachment(
                id: 'att-1',
                kind: DailyRecordAttachmentKind.image,
                objectKey: 'uploads/1.jpg',
                publicUrl: 'https://cdn.example.com/1.jpg',
                createdAt: '2026-07-14T10:00:00Z',
              ),
            ],
          ),
        ],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(
        dashboard.timeline.first.imageUrl,
        'https://cdn.example.com/1.jpg',
      );
    });

    test('returns null imageUrl when attachment has no publicUrl', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(
            attachments: [
              const DailyRecordAttachment(
                id: 'att-1',
                kind: DailyRecordAttachmentKind.image,
                objectKey: 'uploads/1.jpg',
                publicUrl: null,
                createdAt: '2026-07-14T10:00:00Z',
              ),
            ],
          ),
        ],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.imageUrl, isNull);
    });

    test('returns null imageUrl when no attachments', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [_item()],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.imageUrl, isNull);
    });
  });

  // ── _toTimelineEntry — meal detail (topFoods) ────────────────
  group('meal topFoods detail', () {
    test('builds rawDetail from mealTopFoods', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(
            kind: DailyRecordKind.meal,
            mealTopFoods: ['Rice', 'Chicken', 'Vegetables'],
          ),
        ],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.rawDetail, isNotNull);
      expect(dashboard.timeline.first.rawDetail, contains('Rice'));
      expect(dashboard.timeline.first.rawDetail, contains('Chicken'));
      expect(dashboard.timeline.first.rawDetail, contains('Vegetables'));
    });

    test('rawDetail is null when mealTopFoods is empty', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [_item(kind: DailyRecordKind.meal, mealTopFoods: [])],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.rawDetail, isNull);
    });

    test('vital records are included by _isActiveRecordEntryType', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [_item(kind: DailyRecordKind.vital)],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline, hasLength(1));
      expect(dashboard.timeline.first.type, RecordEntryType.vitals);
    });

    test('activity records are included by _isActiveRecordEntryType', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [_item(kind: DailyRecordKind.activity)],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline, hasLength(1));
      expect(dashboard.timeline.first.type, RecordEntryType.activity);
    });

    test('rawDetail is null for non-meal kinds even with topFoods', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [
          _item(kind: DailyRecordKind.water, mealTopFoods: ['Rice']),
        ],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.rawDetail, isNull);
    });
  });

  // ── _toTimelineEntry — time label formatting ─────────────────
  group('time label', () {
    test('uses occurredTime when present', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [_item(occurredTime: '14:30')],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.time, '14:30');
    });

    test('returns em dash when occurredTime is null', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [_item(occurredTime: null)],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.time, '—');
    });

    test('returns em dash when occurredTime is empty', () async {
      dailyRepo.fetchRecordsResult = DailyRecordListData(
        items: [_item(occurredTime: '')],
        total: 1,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline.first.time, '—');
    });
  });

  // ── static data: monthDays ───────────────────────────────────
  group('monthDays generation', () {
    test('generates correct number of days for July 2026', () async {
      dailyRepo.fetchRecordsResult = const DailyRecordListData(
        items: [],
        total: 0,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      // July 2026: July 1 is Wednesday (weekday=3), so 2 offset days
      // 2 offset + 31 days = 33 total
      expect(dashboard.monthDays, hasLength(33));
    });

    test('first days are padding (day=0, inMonth=false)', () async {
      dailyRepo.fetchRecordsResult = const DailyRecordListData(
        items: [],
        total: 0,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      // July 1, 2026 is Wednesday, so offset = 2
      expect(dashboard.monthDays[0].day, 0);
      expect(dashboard.monthDays[0].inMonth, isFalse);
      expect(dashboard.monthDays[1].day, 0);
      expect(dashboard.monthDays[1].inMonth, isFalse);
    });

    test('marks the selected day as selected', () async {
      dailyRepo.fetchRecordsResult = const DailyRecordListData(
        items: [],
        total: 0,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      final selectedDays = dashboard.monthDays.where((d) => d.selected);
      expect(selectedDays, hasLength(1));
      expect(selectedDays.first.day, 14);
    });

    test('all in-month days have correct day numbers', () async {
      dailyRepo.fetchRecordsResult = const DailyRecordListData(
        items: [],
        total: 0,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      final inMonthDays = dashboard.monthDays.where((d) => d.inMonth);
      expect(inMonthDays, hasLength(31));
      var expectedDay = 1;
      for (final day in inMonthDays) {
        expect(day.day, expectedDay);
        expectedDay++;
      }
    });
  });

  // ── static data: filters ─────────────────────────────────────
  group('filters generation', () {
    test(
      'generates filters with all selected when filterType is null',
      () async {
        dailyRepo.fetchRecordsResult = const DailyRecordListData(
          items: [],
          total: 0,
        );

        final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

        expect(dashboard.filters, isNotEmpty);
        for (final filter in dashboard.filters) {
          expect(filter.selected, isTrue);
        }
      },
    );

    test(
      'only matching filter is selected when filterType is provided',
      () async {
        dailyRepo.fetchRecordsResult = const DailyRecordListData(
          items: [],
          total: 0,
        );

        final dashboard = await fetchDashboard(
          DateTime(2026, 7, 14),
          filterType: RecordEntryType.water,
        );

        final waterFilter = dashboard.filters.firstWhere(
          (f) => f.type == RecordEntryType.water,
        );
        expect(waterFilter.selected, isTrue);

        final otherFilters = dashboard.filters.where(
          (f) => f.type != RecordEntryType.water,
        );
        for (final filter in otherFilters) {
          expect(filter.selected, isFalse);
        }
      },
    );
  });

  // ── static data: quickActions ────────────────────────────────
  group('quickActions generation', () {
    test('generates non-empty list of quick actions', () async {
      dailyRepo.fetchRecordsResult = const DailyRecordListData(
        items: [],
        total: 0,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      expect(dashboard.quickActions, isNotEmpty);
    });

    test('all quick actions have active entry types', () async {
      dailyRepo.fetchRecordsResult = const DailyRecordListData(
        items: [],
        total: 0,
      );

      final dashboard = await fetchDashboard(DateTime(2026, 7, 14));

      for (final action in dashboard.quickActions) {
        expect(action.type, isNot(RecordEntryType.heartRate));
        expect(action.type, isNot(RecordEntryType.weight));
      }
    });
  });

  // ── signedOutDashboard ───────────────────────────────────────
  group('signedOutDashboard', () {
    test('returns dashboard with empty timeline', () async {
      final dashboard = await repo.signedOutDashboard(DateTime(2026, 7, 14));

      expect(dashboard.timeline, isEmpty);
      expect(dashboard.summary.items, isEmpty);
      expect(dashboard.trends, isEmpty);
      expect(dashboard.monthDays, isEmpty);
    });

    test('returns dashboard with selectedDate and selectedDay', () async {
      final dashboard = await repo.signedOutDashboard(DateTime(2026, 7, 14));

      expect(dashboard.selectedDate, DateTime(2026, 7, 14));
      expect(dashboard.selectedDay, 14);
    });

    test('returns dashboard with quickActions', () async {
      final dashboard = await repo.signedOutDashboard(DateTime(2026, 7, 14));

      expect(dashboard.quickActions, isNotEmpty);
    });

    test('returns dashboard with filters', () async {
      final dashboard = await repo.signedOutDashboard(DateTime(2026, 7, 14));

      expect(dashboard.filters, isNotEmpty);
    });
  });
}
