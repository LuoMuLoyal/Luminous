import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';

void main() {
  group('Breakpoints', () {
    test('mobile breakpoint is 600', () {
      expect(Breakpoints.mobile, equals(600));
    });

    test('tablet breakpoint is 960', () {
      expect(Breakpoints.tablet, equals(960));
    });

    test('desktop breakpoint is 1200', () {
      expect(Breakpoints.desktop, equals(1200));
    });

    test('wide breakpoint is 1400', () {
      expect(Breakpoints.wide, equals(1400));
    });
  });
}
