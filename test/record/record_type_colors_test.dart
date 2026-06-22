import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/domain/entities/record_type_colors.dart';

void main() {
  group('RecordTypeColors.forKind', () {
    test('water', () {
      final (fg, bg) = RecordTypeColors.forKind(DailyRecordKind.water);
      expect(fg, const Color(0xFF428BFF));
      expect(bg, const Color(0xFFEFF5FF));
    });
    test('meal', () {
      final (fg, bg) = RecordTypeColors.forKind(DailyRecordKind.meal);
      expect(fg, const Color(0xFFFF8A00));
      expect(bg, const Color(0xFFFFF2E0));
    });
    test('sleep', () {
      final (fg, bg) = RecordTypeColors.forKind(DailyRecordKind.sleep);
      expect(fg, const Color(0xFF7D67E8));
      expect(bg, const Color(0xFFF0ECFF));
    });
    test('all kinds return non-null', () {
      for (final k in DailyRecordKind.values) {
        final (fg, bg) = RecordTypeColors.forKind(k);
        expect(fg, isA<Color>());
        expect(bg, isA<Color>());
      }
    });
  });

  group('RecordTypeColors.foreground', () {
    test('medication is orange (#FF7A1A)', () {
      expect(
        RecordTypeColors.foreground(RecordEntryType.medication),
        const Color(0xFFFF7A1A),
      );
    });
    test('all types return non-null', () {
      for (final t in RecordEntryType.values) {
        expect(RecordTypeColors.foreground(t), isA<Color>());
      }
    });
  });

  group('meal is NOT green', () {
    test('meal foreground is orange not old green', () {
      final c = RecordTypeColors.foreground(RecordEntryType.meal);
      expect(c, isNot(const Color(0xFF149B5A)));
      expect(c, const Color(0xFFFF8A00));
    });
  });
}
