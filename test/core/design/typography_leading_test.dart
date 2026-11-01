import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart' show Brightness;
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/family.dart';

/// 行高按平台分支：手机为了密度把 body 行高压成 1.0，桌面必须保留 Forui
/// 的宽松 leading。
///
/// 这条分支存在的理由：height 1.0 在手机上是「一行一个标签」的密度优化，
/// 到桌面上就是长段落的灾难——中文没有上下伸部余量，行距 0 时整段会糊成
/// 一块。若哪天有人为了「统一」把桌面也拍平，这里会拦下来。
void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('typography leading', () {
    test('phone body leading is flat (density)', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final theme = appThemeData(AppThemeFamily.blue, Brightness.light);
      expect(theme.typography.body.md.height, 1.0);
      expect(theme.typography.body.sm.height, 1.0);
    });

    test('desktop body leading stays readable', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final theme = appThemeData(AppThemeFamily.blue, Brightness.light);
      expect(theme.typography.body.md.height, isNot(1.0));
      expect(
        theme.typography.body.md.height ?? 1.0,
        greaterThan(1.2),
        reason: '桌面 body 行高必须留出可读的行距',
      );
    });

    test('display sizes are flat on both platforms', () {
      // 标题类字号短且是结构性的，压平在两端都成立。
      for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
        debugDefaultTargetPlatformOverride = platform;
        final theme = appThemeData(AppThemeFamily.blue, Brightness.light);
        expect(
          theme.typography.display.md.height,
          1.0,
          reason: 'display 行高在 $platform 上也应为 1.0',
        );
      }
    });
  });
}
