import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/settings/utils/version_check.dart';

void main() {
  group('compareSemver', () {
    group('basic ordering', () {
      test('equal versions return 0', () {
        expect(compareSemver('1.0.0', '1.0.0'), 0);
        expect(compareSemver('0.1.0', '0.1.0'), 0);
      });

      test('older < newer returns negative', () {
        expect(compareSemver('0.1.0', '0.2.0'), lessThan(0));
        expect(compareSemver('1.0.0', '2.0.0'), lessThan(0));
      });

      test('newer > older returns positive', () {
        expect(compareSemver('2.0.0', '1.0.0'), greaterThan(0));
        expect(compareSemver('0.2.0', '0.1.1'), greaterThan(0));
      });
    });

    group('multi-segment', () {
      test('patch version matters', () {
        expect(compareSemver('1.0.0', '1.0.1'), lessThan(0));
        expect(compareSemver('1.0.2', '1.0.1'), greaterThan(0));
      });

      test('minor version matters', () {
        expect(compareSemver('1.0.5', '1.1.0'), lessThan(0));
        expect(compareSemver('1.2.0', '1.1.9'), greaterThan(0));
      });
    });

    group('uneven segment counts', () {
      test('shorter version is zero-padded', () {
        expect(compareSemver('1.0', '1.0.0'), 0);
        expect(compareSemver('1', '1.0.0'), 0);
        expect(compareSemver('2.0', '1.9.9'), greaterThan(0));
      });

      test('longer version is also compared correctly', () {
        expect(compareSemver('1.0.0.1', '1.0.0'), greaterThan(0));
        expect(compareSemver('1.0.0', '1.0.0.1'), lessThan(0));
      });
    });

    group('pre-release and build metadata', () {
      test('pre-release suffix is stripped before comparison', () {
        expect(compareSemver('0.1.0-beta', '0.1.0'), 0);
        expect(compareSemver('1.0.0-alpha.1', '1.0.0-rc.1'), 0);
      });

      test('build metadata is stripped before comparison', () {
        expect(compareSemver('0.1.0+1', '0.1.0'), 0);
        expect(compareSemver('1.0.0+20230801', '1.0.0+build42'), 0);
      });

      test('both pre-release and build metadata are stripped', () {
        expect(compareSemver('0.1.0-beta+1', '0.1.0'), 0);
        expect(
          compareSemver('0.2.0-rc.1+42', '0.1.9-alpha+100'),
          greaterThan(0),
        );
      });
    });

    group('non-numeric segments', () {
      test('non-numeric segments are treated as 0', () {
        expect(compareSemver('abc.xyz', '0.0.0'), 0);
        expect(compareSemver('1.x.0', '1.0.0'), 0);
      });

      test('mixed numeric and non-numeric', () {
        expect(compareSemver('1.abc.3', '1.0.3'), 0);
      });
    });

    group('whitespace in segments', () {
      test('leading/trailing whitespace in segments is trimmed', () {
        expect(compareSemver('1. 0 .0', '1.0.0'), 0);
        expect(compareSemver(' 1 . 2 ', '1.2.0'), 0);
      });
    });
  });
}
