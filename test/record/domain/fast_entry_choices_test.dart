import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/domain/constants/fast_entry_choices.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  group('RecordFastChoice', () {
    test('can be constructed with required label only', () {
      const choice = RecordFastChoice(label: 'Test');
      expect(choice.label, 'Test');
      expect(choice.prefix, isNull);
      expect(choice.title, isNull);
      expect(choice.value, isNull);
      expect(choice.unit, isNull);
      expect(choice.note, isNull);
      expect(choice.payload, isNull);
    });

    test('can be constructed with all fields', () {
      const choice = RecordFastChoice(
        label: 'Test',
        prefix: SizedBox(),
        title: 'Title',
        value: '100',
        unit: 'ml',
        note: 'A note',
        payload: {'key': 'value'},
      );
      expect(choice.label, 'Test');
      expect(choice.title, 'Title');
      expect(choice.value, '100');
      expect(choice.unit, 'ml');
      expect(choice.note, 'A note');
      expect(choice.payload, {'key': 'value'});
    });
  });

  group('recordFastEntryChoicesFor', () {
    group('DailyRecordKind.water', () {
      test('returns 4 choices', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.water, l10n);
        expect(choices, hasLength(4));
      });

      test('choices have correct values and units', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.water, l10n);
        expect(choices[0].value, '250');
        expect(choices[0].unit, 'ml');
        expect(choices[1].value, '500');
        expect(choices[1].unit, 'ml');
        expect(choices[2].value, '1');
        expect(choices[2].unit, 'cup');
        expect(choices[3].value, '1');
        expect(choices[3].unit, 'times');
      });

      test('labels contain unit information', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.water, l10n);
        expect(choices[0].label, '250 ml');
        expect(choices[1].label, '500 ml');
      });
    });

    group('DailyRecordKind.meal', () {
      test('returns 4 meal type choices', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.meal, l10n);
        expect(choices, hasLength(4));
      });

      test('labels match l10n strings', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.meal, l10n);
        expect(choices[0].label, l10n.recordFastChoiceMealBreakfast);
        expect(choices[1].label, l10n.recordFastChoiceMealLunch);
        expect(choices[2].label, l10n.recordFastChoiceMealDinner);
        expect(choices[3].label, l10n.recordFastChoiceMealSnack);
      });

      test('title matches label for meal choices', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.meal, l10n);
        for (final c in choices) {
          expect(c.title, c.label);
        }
      });
    });

    group('DailyRecordKind.symptom', () {
      test('returns 4 symptom choices', () {
        final choices = recordFastEntryChoicesFor(
          DailyRecordKind.symptom,
          l10n,
        );
        expect(choices, hasLength(4));
      });

      test('labels match l10n strings', () {
        final choices = recordFastEntryChoicesFor(
          DailyRecordKind.symptom,
          l10n,
        );
        expect(choices[0].label, l10n.recordFastChoiceSymptomHeadache);
        expect(choices[1].label, l10n.recordFastChoiceSymptomStomachache);
        expect(choices[2].label, l10n.recordFastChoiceSymptomDizzy);
        expect(choices[3].label, l10n.recordFastChoiceSymptomFever);
      });

      test('default severity is mild', () {
        final choices = recordFastEntryChoicesFor(
          DailyRecordKind.symptom,
          l10n,
        );
        for (final c in choices) {
          expect(c.value, l10n.recordFastChoiceSeverityMild);
        }
      });
    });

    group('DailyRecordKind.note', () {
      test('returns 4 note choices', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.note, l10n);
        expect(choices, hasLength(4));
      });

      test('note field matches label', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.note, l10n);
        for (final c in choices) {
          expect(c.note, c.label);
        }
      });

      test('labels match l10n strings', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.note, l10n);
        expect(choices[0].label, l10n.recordFastChoiceNoteStable);
        expect(choices[1].label, l10n.recordFastChoiceNoteTired);
        expect(choices[2].label, l10n.recordFastChoiceNoteBusy);
        expect(choices[3].label, l10n.recordFastChoiceNoteRecovered);
      });
    });

    group('DailyRecordKind.sleep', () {
      test('returns 4 sleep duration choices', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.sleep, l10n);
        expect(choices, hasLength(4));
      });

      test('labels are in hours format (6h, 7h, 8h, 9h)', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.sleep, l10n);
        expect(choices[0].label, '6h');
        expect(choices[1].label, '7h');
        expect(choices[2].label, '8h');
        expect(choices[3].label, '9h');
      });

      test('payload contains durationMinutes', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.sleep, l10n);
        expect(choices[0].payload, {'durationMinutes': 360});
        expect(choices[1].payload, {'durationMinutes': 420});
        expect(choices[2].payload, {'durationMinutes': 480});
        expect(choices[3].payload, {'durationMinutes': 540});
      });
    });

    group('DailyRecordKind.mood', () {
      test('returns 5 mood choices', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.mood, l10n);
        expect(choices, hasLength(5));
      });

      test('labels match l10n strings', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.mood, l10n);
        expect(choices[0].label, l10n.recordFastChoiceMoodGreat);
        expect(choices[1].label, l10n.recordFastChoiceMoodGood);
        expect(choices[2].label, l10n.recordFastChoiceMoodOkay);
        expect(choices[3].label, l10n.recordFastChoiceMoodBad);
        expect(choices[4].label, l10n.recordFastChoiceMoodTerrible);
      });

      test('payload contains moodLevel from 5 down to 1', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.mood, l10n);
        expect(choices[0].payload?['moodLevel'], 5);
        expect(choices[1].payload?['moodLevel'], 4);
        expect(choices[2].payload?['moodLevel'], 3);
        expect(choices[3].payload?['moodLevel'], 2);
        expect(choices[4].payload?['moodLevel'], 1);
      });

      test('payload contains moodLabel string', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.mood, l10n);
        expect(choices[0].payload?['moodLabel'], 'great');
        expect(choices[1].payload?['moodLabel'], 'good');
        expect(choices[2].payload?['moodLabel'], 'okay');
        expect(choices[3].payload?['moodLabel'], 'bad');
        expect(choices[4].payload?['moodLabel'], 'terrible');
      });

      test('prefix is a Text widget (emoji)', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.mood, l10n);
        for (final c in choices) {
          expect(c.prefix, isA<Text>());
        }
      });
    });

    group('unmapped kinds return empty list', () {
      test('vital returns empty', () {
        final choices = recordFastEntryChoicesFor(DailyRecordKind.vital, l10n);
        expect(choices, isEmpty);
      });

      test('activity returns empty', () {
        final choices = recordFastEntryChoicesFor(
          DailyRecordKind.activity,
          l10n,
        );
        expect(choices, isEmpty);
      });
    });
  });
}
