import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/app_breakpoints.dart';

void main() {
  group('AppBreakpoints', () {
    test('mobile breakpoint is 600', () {
      expect(AppBreakpoints.mobile, equals(600));
    });

    test('tablet breakpoint is 960', () {
      expect(AppBreakpoints.tablet, equals(960));
    });

    test('desktop breakpoint is 1200', () {
      expect(AppBreakpoints.desktop, equals(1200));
    });

    test('wide breakpoint is 1400', () {
      expect(AppBreakpoints.wide, equals(1400));
    });
  });
}
