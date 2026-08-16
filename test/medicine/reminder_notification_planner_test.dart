import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/domain/entities/reminder_sound_preference.dart';
import 'package:luminous/features/medicine/domain/services/reminder_notification_planner.dart';

void main() {
  const texts = MedicineReminderNotificationTexts(
    defaultTitle: 'Medication reminder',
    defaultBody: 'It is time to take your medicine.',
    channelName: 'Medication reminders',
    channelDescription: 'On-device reminders for your medication schedule.',
  );
  final now = DateTime(2026, 6, 10, 9);

  test('daily future reminder produces seven upcoming notifications', () {
    const planner = MedicineReminderNotificationPlanner();

    final planned = planner.plan(
      reminders: <MedicineReminderItem>[
        _reminder(id: 'evening', hour: 21, minute: 30),
      ],
      remindersEnabled: true,
      sound: MedicineReminderSoundPreference.defaultTone,
      texts: texts,
      now: now,
    );

    expect(planned, hasLength(7));
    expect(planned.first.scheduledAt, DateTime(2026, 6, 10, 21, 30));
    expect(planned.last.scheduledAt, DateTime(2026, 6, 16, 21, 30));
  });

  test('today past times are skipped while future times remain scheduled', () {
    const planner = MedicineReminderNotificationPlanner();

    final planned = planner.plan(
      reminders: <MedicineReminderItem>[
        _reminder(id: 'morning', hour: 8, minute: 0),
        _reminder(id: 'evening', hour: 21, minute: 30),
      ],
      remindersEnabled: true,
      sound: MedicineReminderSoundPreference.defaultTone,
      texts: texts,
      now: now,
    );

    expect(planned, hasLength(13));
    expect(planned.where((item) => item.payload == 'morning'), hasLength(6));
    expect(planned.where((item) => item.payload == 'evening'), hasLength(7));
    expect(planned.first.scheduledAt, DateTime(2026, 6, 10, 21, 30));
  });

  test(
    'days of week and start end dates filter reminders with inclusive bounds',
    () {
      const planner = MedicineReminderNotificationPlanner();

      final planned = planner.plan(
        reminders: <MedicineReminderItem>[
          _reminder(
            id: 'weekly',
            hour: 10,
            minute: 15,
            daysOfWeek: const <int>[3, 5],
            startDate: '2026-06-10',
            endDate: '2026-06-12',
          ),
        ],
        remindersEnabled: true,
        sound: MedicineReminderSoundPreference.defaultTone,
        texts: texts,
        now: now,
      );

      expect(planned.map((item) => item.scheduledAt).toList(), <DateTime>[
        DateTime(2026, 6, 10, 10, 15),
        DateTime(2026, 6, 12, 10, 15),
      ]);
    },
  );

  test(
    'inactive reminders or disabled scheduling produce no notifications',
    () {
      const planner = MedicineReminderNotificationPlanner();

      expect(
        planner.plan(
          reminders: <MedicineReminderItem>[
            _reminder(id: 'inactive', isActive: false),
          ],
          remindersEnabled: true,
          sound: MedicineReminderSoundPreference.defaultTone,
          texts: texts,
          now: now,
        ),
        isEmpty,
      );

      expect(
        planner.plan(
          reminders: <MedicineReminderItem>[_reminder(id: 'active')],
          remindersEnabled: false,
          sound: MedicineReminderSoundPreference.defaultTone,
          texts: texts,
          now: now,
        ),
        isEmpty,
      );
    },
  );

  test('planner truncates to the earliest sixty notifications', () {
    const planner = MedicineReminderNotificationPlanner();
    final reminders = List<MedicineReminderItem>.generate(
      9,
      (index) => _reminder(
        id: 'reminder-$index',
        hour: 10 + (index ~/ 3),
        minute: (index % 3) * 10,
      ),
      growable: false,
    );

    final planned = planner.plan(
      reminders: reminders,
      remindersEnabled: true,
      sound: MedicineReminderSoundPreference.defaultTone,
      texts: texts,
      now: now,
    );

    expect(planned, hasLength(60));
    expect(planned.first.scheduledAt, DateTime(2026, 6, 10, 10));
    expect(planned.last.scheduledAt, DateTime(2026, 6, 16, 11, 20));
  });

  test(
    'notification ids are deterministic, positive, and resolve collisions',
    () {
      final planner = MedicineReminderNotificationPlanner(
        horizonDays: 1,
        hashValue: (_) => 42,
      );

      final once = planner.plan(
        reminders: <MedicineReminderItem>[
          _reminder(id: 'alpha', hour: 10),
          _reminder(id: 'beta', hour: 10),
        ],
        remindersEnabled: true,
        sound: MedicineReminderSoundPreference.defaultTone,
        texts: texts,
        now: now,
      );
      final twice = planner.plan(
        reminders: <MedicineReminderItem>[
          _reminder(id: 'alpha', hour: 10),
          _reminder(id: 'beta', hour: 10),
        ],
        remindersEnabled: true,
        sound: MedicineReminderSoundPreference.defaultTone,
        texts: texts,
        now: now,
      );

      expect(once.map((item) => item.id).toList(), <int>[42, 43]);
      expect(twice.map((item) => item.id).toList(), <int>[42, 43]);
      expect(once.every((item) => item.id > 0), isTrue);
    },
  );

  test('sound preference and label note fallbacks are applied', () {
    const planner = MedicineReminderNotificationPlanner(horizonDays: 1);

    final silent = planner.plan(
      reminders: <MedicineReminderItem>[
        _reminder(
          id: 'silent',
          hour: 10,
          label: 'Take vitamin D',
          note: 'After breakfast',
        ),
      ],
      remindersEnabled: true,
      sound: MedicineReminderSoundPreference.silent,
      texts: texts,
      now: now,
    );
    final gentle = planner.plan(
      reminders: <MedicineReminderItem>[
        _reminder(id: 'fallback', hour: 10, label: ' ', note: '   '),
      ],
      remindersEnabled: true,
      sound: MedicineReminderSoundPreference.gentle,
      texts: texts,
      now: now,
    );

    expect(silent.single.playSound, isFalse);
    expect(silent.single.title, 'Take vitamin D');
    expect(silent.single.body, 'After breakfast');
    expect(gentle.single.playSound, isTrue);
    expect(gentle.single.title, texts.defaultTitle);
    expect(gentle.single.body, texts.defaultBody);
  });

  test('advanceMinutes shifts scheduled time earlier', () {
    const planner = MedicineReminderNotificationPlanner(horizonDays: 1);

    final planned = planner.plan(
      reminders: <MedicineReminderItem>[
        _reminder(id: 'advance', hour: 10, minute: 30),
      ],
      remindersEnabled: true,
      sound: MedicineReminderSoundPreference.defaultTone,
      texts: texts,
      now: now,
      advanceMinutes: 15,
    );

    expect(planned, hasLength(1));
    expect(planned.single.scheduledAt, DateTime(2026, 6, 10, 10, 15));
  });

  test('DND cross-midnight window filters notifications', () {
    const planner = MedicineReminderNotificationPlanner(horizonDays: 1);

    // DND 22:00 → 07:00 should filter a 23:00 reminder but allow a 10:00 one.
    final planned = planner.plan(
      reminders: <MedicineReminderItem>[
        _reminder(id: 'night', hour: 23, minute: 0),
        _reminder(id: 'morning', hour: 10, minute: 0),
      ],
      remindersEnabled: true,
      sound: MedicineReminderSoundPreference.defaultTone,
      texts: texts,
      now: now,
      dndEnabled: true,
      dndStartHour: 22,
      dndStartMinute: 0,
      dndEndHour: 7,
      dndEndMinute: 0,
    );

    expect(planned, hasLength(1));
    expect(planned.single.payload, 'morning');
  });

  test('DND same-day window filters notifications', () {
    const planner = MedicineReminderNotificationPlanner(horizonDays: 1);

    // DND 09:00 → 12:00 should filter the 10:00 reminder but allow 14:00.
    final planned = planner.plan(
      reminders: <MedicineReminderItem>[
        _reminder(id: 'filtered', hour: 10, minute: 0),
        _reminder(id: 'kept', hour: 14, minute: 0),
      ],
      remindersEnabled: true,
      sound: MedicineReminderSoundPreference.defaultTone,
      texts: texts,
      now: now,
      dndEnabled: true,
      dndStartHour: 9,
      dndStartMinute: 0,
      dndEndHour: 12,
      dndEndMinute: 0,
    );

    expect(planned, hasLength(1));
    expect(planned.single.payload, 'kept');
  });

  test('soundEnabled false overrides non-silent sound preference', () {
    const planner = MedicineReminderNotificationPlanner(horizonDays: 1);

    final planned = planner.plan(
      reminders: <MedicineReminderItem>[_reminder(id: 'muted', hour: 10)],
      remindersEnabled: true,
      sound: MedicineReminderSoundPreference.defaultTone,
      texts: texts,
      now: now,
      soundEnabled: false,
    );

    expect(planned.single.playSound, isFalse);
    expect(planned.single.enableVibration, isFalse);
  });

  test(
    'id probe exhaustion returns allocated notifications instead of throwing',
    () {
      final planner = MedicineReminderNotificationPlanner(
        horizonDays: 1,
        hashValue: (_) => 42,
      );
      // 全部提醒落在同一时刻 → 全部撞同一个 hash,第 1002 条起线性探测
      // 超过上限;plan() 应跳过并记录日志,而不是向上抛 StateError。
      final reminders = List<MedicineReminderItem>.generate(
        1005,
        (index) => _reminder(id: 'r$index', hour: 10, minute: 0),
        growable: false,
      );

      final planned = planner.plan(
        reminders: reminders,
        remindersEnabled: true,
        sound: MedicineReminderSoundPreference.defaultTone,
        texts: texts,
        now: now,
      );

      expect(planned, isNotEmpty);
      expect(planned.length, lessThanOrEqualTo(60));
    },
  );

  test('enableVibration false disables vibration while keeping sound', () {
    const planner = MedicineReminderNotificationPlanner(horizonDays: 1);

    final planned = planner.plan(
      reminders: <MedicineReminderItem>[_reminder(id: 'no-vibrate', hour: 10)],
      remindersEnabled: true,
      sound: MedicineReminderSoundPreference.defaultTone,
      texts: texts,
      now: now,
      enableVibration: false,
    );

    expect(planned.single.playSound, isTrue);
    expect(planned.single.enableVibration, isFalse);
  });
}

MedicineReminderItem _reminder({
  required String id,
  int hour = 10,
  int minute = 0,
  List<int>? daysOfWeek,
  String? startDate,
  String? endDate,
  bool isActive = true,
  String? label,
  String? note,
}) {
  return MedicineReminderItem(
    id: id,
    currentMedicineId: 'med-1',
    label: label,
    scheduledHour: hour,
    scheduledMinute: minute,
    daysOfWeek: daysOfWeek,
    startDate: startDate,
    endDate: endDate,
    isActive: isActive,
    note: note,
    createdAt: '2026-06-01T00:00:00.000Z',
    updatedAt: '2026-06-01T00:00:00.000Z',
  );
}
