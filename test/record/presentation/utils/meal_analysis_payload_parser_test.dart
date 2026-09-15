import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/presentation/utils/meal_analysis_payload_parser.dart';

/// v2 分析结果的 payload 形状(服务端 `mealAnalysis` 全字段)。
Map<String, dynamic> mealPayload({
  String status = 'analyzed',
  Map<String, dynamic>? calorieRange = const {
    'min': 520,
    'max': 780,
    'unit': 'kcal',
    'bucket': 'medium',
  },
  List<Map<String, dynamic>> dishes = const [
    {'name': '红烧肉', 'source': 'model'},
    {'name': '青菜', 'source': 'user'},
  ],
  List<Map<String, dynamic>> items = const [
    {
      'rank': 1,
      'kind': 'fried',
      'polarity': 'watch',
      'headline': '油炸偏多',
      'detail': '午饭油炸食品摄入偏多',
    },
  ],
  String? failureReason,
}) {
  return <String, dynamic>{
    'mealAnalysis': <String, dynamic>{
      'version': 2,
      'analysisStatus': status,
      'analyzedAt': '2026-09-15T12:31:04.000Z',
      'sourceRevision': 3,
      'model': 'vision-model',
      'promptVersion': 'meal-analysis.v2',
      'locale': 'zh-CN',
      'failureReason': failureReason,
      'calorieRange': calorieRange,
      'dishes': dishes,
      'items': items,
      'facets': <String, dynamic>{'fried': 'high'},
    },
  };
}

void main() {
  group('parseMealAnalysisViewData', () {
    test('returns null without a mealAnalysis object', () {
      expect(parseMealAnalysisViewData(null), isNull);
      expect(parseMealAnalysisViewData(const {}), isNull);
      expect(parseMealAnalysisViewData(const {'mealInput': {}}), isNull);
      expect(
        parseMealAnalysisViewData(const {
          'mealAnalysis': {'analysisStatus': null},
        }),
        isNull,
      );
    });

    test('parses status, failure reason, range, dishes and findings', () {
      final data = parseMealAnalysisViewData(mealPayload())!;

      expect(data.status, 'analyzed');
      expect(data.isAnalyzed, isTrue);
      expect(data.failureReason, isNull);
      expect(data.calorieRange, isNotNull);
      expect(data.calorieRange!.min, 520);
      expect(data.calorieRange!.max, 780);
      expect(data.calorieRange!.bucket, 'medium');
      expect(data.dishes, hasLength(2));
      expect(data.dishes.first.name, '红烧肉');
      expect(data.dishes.first.isUserEdited, isFalse);
      expect(data.dishes.last.isUserEdited, isTrue);
      expect(data.items, hasLength(1));
      expect(data.items.first.headline, '油炸偏多');
      expect(data.items.first.polarity, 'watch');
      expect(data.headline, '油炸偏多');
    });

    test('sorts findings by rank', () {
      final data = parseMealAnalysisViewData(
        mealPayload(
          items: const [
            {
              'rank': 3,
              'kind': 'carb',
              'polarity': 'watch',
              'headline': '碳水偏少',
              'detail': '晚饭碳水较少',
            },
            {
              'rank': 1,
              'kind': 'fried',
              'polarity': 'watch',
              'headline': '油炸偏多',
              'detail': '午饭油炸偏多',
            },
          ],
        ),
      )!;

      expect(data.items.map((item) => item.headline).toList(), [
        '油炸偏多',
        '碳水偏少',
      ]);
    });

    test('keeps the failure state and its reason code', () {
      final data = parseMealAnalysisViewData(
        mealPayload(
          status: 'analysis_failed',
          calorieRange: null,
          dishes: const [],
          items: const [],
          failureReason: 'model_timeout',
        ),
      )!;

      expect(data.hasFailed, isTrue);
      expect(data.failureReason, 'model_timeout');
      expect(data.calorieRange, isNull);
      expect(data.dishes, isEmpty);
      expect(data.headline, isNull);
    });

    test('drops findings without both headline and detail', () {
      final data = parseMealAnalysisViewData(
        mealPayload(
          items: const [
            {
              'rank': 1,
              'kind': 'fried',
              'polarity': 'watch',
              'headline': '油炸偏多',
              'detail': '   ',
            },
            {
              'rank': 2,
              'kind': 'carb',
              'polarity': 'watch',
              'headline': '碳水偏少',
              'detail': '晚饭碳水较少',
            },
          ],
        ),
      )!;

      expect(data.items, hasLength(1));
      expect(data.items.first.headline, '碳水偏少');
    });

    test('drops dish entries without a usable name', () {
      final data = parseMealAnalysisViewData(
        mealPayload(
          dishes: const [
            {'name': '  ', 'source': 'model'},
            {'source': 'model'},
            {'name': ' 青菜 ', 'source': 'user'},
          ],
        ),
      )!;

      expect(data.dishes, hasLength(1));
      expect(data.dishes.first.name, '青菜');
    });

    test('ignores a malformed range and non-map array entries', () {
      final data = parseMealAnalysisViewData(<String, dynamic>{
        'mealAnalysis': <String, dynamic>{
          'analysisStatus': 'analyzed',
          'calorieRange': <String, dynamic>{'min': 520},
          'dishes': <dynamic>[
            'nonsense',
            <String, dynamic>{'name': '红烧肉'},
          ],
          'items': <dynamic>['nonsense'],
        },
      })!;

      expect(data.calorieRange, isNull);
      expect(data.dishes, hasLength(1));
      expect(data.items, isEmpty);
    });

    test('reads the analyzing placeholder as an empty result', () {
      final data = parseMealAnalysisViewData(
        mealPayload(
          status: 'analyzing',
          calorieRange: null,
          dishes: const [],
          items: const [],
        ),
      )!;

      expect(data.isAnalyzing, isTrue);
      expect(data.calorieRange, isNull);
      expect(data.headline, isNull);
    });
  });

  group('parseMealDishNames', () {
    test('returns the dish names in order', () {
      expect(parseMealDishNames(mealPayload()), ['红烧肉', '青菜']);
    });

    test('returns an empty list without an analysis', () {
      expect(parseMealDishNames(null), isEmpty);
      expect(parseMealDishNames(const {}), isEmpty);
    });
  });
}
