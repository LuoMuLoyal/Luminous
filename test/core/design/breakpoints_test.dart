import 'package:fluid_adaptive/fluid_adaptive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';

void main() {
  group('Breakpoints', () {
    test('mobile breakpoint is 600', () {
      expect(Breakpoints.mobile, equals(600));
    });

    test('expanded breakpoint is the M3 standard 840', () {
      expect(Breakpoints.expanded, equals(840));
    });

    test('main tiers match ResponsiveBreakpoints.standard', () {
      // 布局分档直接消费包的标准断点；本仓库常量必须与它一致，
      // 否则组件内的宽度判断会与页面分档各说各的。
      const standard = ResponsiveBreakpoints.standard;
      expect(Breakpoints.mobile, standard.compactMax);
      expect(Breakpoints.expanded, standard.mediumMax);
      expect(Breakpoints.desktop, standard.expandedMax);
    });

    test('desktop breakpoint is 1200', () {
      expect(Breakpoints.desktop, equals(1200));
    });

    test('wide breakpoint is 1400', () {
      expect(Breakpoints.wide, equals(1400));
    });
  });
}
