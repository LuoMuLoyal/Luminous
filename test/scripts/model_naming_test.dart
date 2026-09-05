import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../scripts/contract/bootstrap.dart';

/// Anchors the [generatedModelFileName] heuristic to the actual generator
/// output under `generated/lucent_api/lib/src/model/`. This catches silent
/// failures when the openapi-generator-cli version or naming rules change —
/// the exact scenario that historically caused bootstrap to fail-fast with
/// misleading "all lists are missing" errors.
///
/// 依赖 openapi-generator-cli 7.25.0 dart-dio 输出（见 openapitools.json）；
/// 升级生成器后此测试会自动暴露 naming 与实际产物的漂移（条目缺失 → fail
/// 而非静默漏过）。
void main() {
  // Resolve the repo root by walking up from the script location to
  // pubspec.yaml (mirrors ToolContext.fromScript in scripts/support.dart) —
  // Platform.script is not guaranteed to be the test file under `flutter
  // test`, so positional dirname math is unreliable.
  var repoRoot = p.dirname(p.fromUri(Platform.script));
  while (!File(p.join(repoRoot, 'pubspec.yaml')).existsSync()) {
    final parent = p.dirname(repoRoot);
    if (parent == repoRoot) {
      throw StateError('pubspec.yaml not found above $repoRoot');
    }
    repoRoot = parent;
  }
  final modelDir = Directory(
    p.join(repoRoot, 'generated', 'lucent_api', 'lib', 'src', 'model'),
  );

  final existingModelBasenames = <String>{};
  if (modelDir.existsSync()) {
    for (final entity in modelDir.listSync()) {
      if (entity is File && entity.path.endsWith('.dart')) {
        existingModelBasenames.add(p.basenameWithoutExtension(entity.path));
      }
    }
  }

  final slices = <String, List<String>>{
    'TodayAnalysis': todayAnalysisModels,
    'Reports': reviewModels,
    'ProductEvents': productEventsModels,
    'Notifications': notificationsModels,
    'UserSettings': userSettingsModels,
    'ReminderDeliveries': reminderDeliveriesModels,
  };

  group('generatedModelFileName heuristic', () {
    test('produces distinct snake_case basenames within each slice', () {
      // 跨切片允许重复（如 ProblemDetailsDto 被多个切片引用，属正常）——
      // 只需保证单个切片内不碰撞。
      for (final entry in slices.entries) {
        final seen = <String>{};
        for (final rawName in entry.value) {
          final fileBase = generatedModelFileName(rawName);
          expect(
            seen.add(fileBase),
            isTrue,
            reason:
                'Duplicate file base "$fileBase" generated in '
                '${entry.key} slice for raw schema name "$rawName" '
                '(already seen).',
          );
        }
      }
    });

    test('result is always lowercase snake_case with no trailing dots', () {
      for (final sliceModels in slices.values) {
        for (final rawName in sliceModels) {
          final fileBase = generatedModelFileName(rawName);
          expect(fileBase, matches(RegExp(r'^[a-z][a-z0-9_]*$')));
          expect(fileBase, isNot(endsWith('.')));
        }
      }
    });
  });

  group('filtered model list ↔ generated model corpus', () {
    for (final entry in slices.entries) {
      test('${entry.key} — every listed schema has a generated model file', () {
        // Guard: the test is meaningless without the generated corpus.
        expect(
          existingModelBasenames,
          isNotEmpty,
          reason:
              'generated/lucent_api/lib/src/model/ is empty or missing — '
              'run dart run scripts/contract/bootstrap.dart first.',
        );

        final missing = <String>[];
        for (final rawName in entry.value) {
          final expected = generatedModelFileName(rawName);
          if (!existingModelBasenames.contains(expected)) {
            missing.add('$rawName → $expected.dart');
          }
        }

        expect(
          missing,
          isEmpty,
          reason:
              '${entry.key} slice lists ${entry.value.length} schema(s) but '
              '${missing.length} have no matching model file in the '
              'generated corpus:\n  ${missing.join('\n  ')}\n'
              'If the contract changed, run pnpm export:openapi + '
              'dart run scripts/contract/bootstrap.dart to regenerate, '
              'then update the list in bootstrap.dart.',
        );
      });
    }
  });
}
