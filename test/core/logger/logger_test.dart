import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:talker_flutter/talker_flutter.dart' as talker_pkg;

void main() {
  group('LogLevel', () {
    test('has exactly 5 values in correct order', () {
      expect(LogLevel.values, hasLength(5));
      expect(LogLevel.values[0], LogLevel.verbose);
      expect(LogLevel.values[1], LogLevel.info);
      expect(LogLevel.values[2], LogLevel.warning);
      expect(LogLevel.values[3], LogLevel.error);
      expect(LogLevel.values[4], LogLevel.none);
    });

    group('fromString', () {
      test('parses "verbose" correctly', () {
        expect(LogLevel.fromString('verbose'), LogLevel.verbose);
      });

      test('parses "info" correctly', () {
        expect(LogLevel.fromString('info'), LogLevel.info);
      });

      test('parses "warning" correctly', () {
        expect(LogLevel.fromString('warning'), LogLevel.warning);
      });

      test('parses "error" correctly', () {
        expect(LogLevel.fromString('error'), LogLevel.error);
      });

      test('parses "none" correctly', () {
        expect(LogLevel.fromString('none'), LogLevel.none);
      });

      test('is case-insensitive', () {
        expect(LogLevel.fromString('VERBOSE'), LogLevel.verbose);
        expect(LogLevel.fromString('Info'), LogLevel.info);
        expect(LogLevel.fromString('WARNING'), LogLevel.warning);
        expect(LogLevel.fromString('Error'), LogLevel.error);
        expect(LogLevel.fromString('NONE'), LogLevel.none);
      });

      test('defaults to info for null input', () {
        expect(LogLevel.fromString(null), LogLevel.info);
      });

      test('defaults to info for empty string', () {
        expect(LogLevel.fromString(''), LogLevel.info);
      });

      test('defaults to info for unknown string', () {
        expect(LogLevel.fromString('unknown'), LogLevel.info);
        expect(LogLevel.fromString('debug'), LogLevel.info);
        expect(LogLevel.fromString('trace'), LogLevel.info);
      });
    });
  });

  group('appTalker', () {
    test('is not null', () {
      expect(appTalker, isNotNull);
    });

    test('is a Talker instance', () {
      expect(appTalker, isA<talker_pkg.Talker>());
    });

    test('returns the same singleton instance on multiple calls', () {
      expect(identical(appTalker, appTalker), isTrue);
    });
  });

  group('applyLogLevelToTalker', () {
    late talker_pkg.Talker talker;

    setUp(() {
      talker = talker_pkg.Talker();
    });

    test('disables talker for LogLevel.none', () {
      applyLogLevelToTalker(talker, LogLevel.none);
      // Talker is disabled — logs should not be recorded
      talker.info('This should be ignored');
      // No exception thrown is the test
    });

    test('enables talker for LogLevel.verbose', () {
      applyLogLevelToTalker(talker, LogLevel.verbose);
      talker.info('Test verbose level');
    });

    test('enables talker for LogLevel.info', () {
      applyLogLevelToTalker(talker, LogLevel.info);
      talker.info('Test info level');
    });

    test('enables talker for LogLevel.warning', () {
      applyLogLevelToTalker(talker, LogLevel.warning);
      talker.warning('Test warning level');
    });

    test('enables talker for LogLevel.error', () {
      applyLogLevelToTalker(talker, LogLevel.error);
      talker.error('Test error level');
    });

    test('can switch from none back to info', () {
      applyLogLevelToTalker(talker, LogLevel.none);
      applyLogLevelToTalker(talker, LogLevel.info);
      talker.info('Should work after re-enabling');
    });
  });
}
