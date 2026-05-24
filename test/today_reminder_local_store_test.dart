import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/reminders/data/today_reminder_local_store.dart';

void main() {
  group('TodayReminderLocalStore helpers', () {
    test(
      'resolveDateKey uses explicit date and falls back to today dateKey',
      () {
        final fallbackDate = todayReminderLocalStore.todayRange().dateKey;

        expect(
          todayReminderLocalStore.resolveDateKey('2026-03-22'),
          '2026-03-22',
        );
        expect(todayReminderLocalStore.resolveDateKey(), fallbackDate);
        expect(todayReminderLocalStore.resolveDateKey('   '), fallbackDate);
      },
    );

    test(
      'resolveDoneState prioritizes override before local checkin and server state',
      () {
        final store = todayReminderLocalStore;

        expect(
          store.resolveDoneState(
            remoteId: 'override-false',
            doneSet: {'override-false'},
            overrides: const {'override-false': false},
            serverDone: true,
          ),
          isFalse,
        );
        expect(
          store.resolveDoneState(
            remoteId: 'local-done',
            doneSet: {'local-done'},
            overrides: const {},
            serverDone: false,
          ),
          isTrue,
        );
        expect(
          store.resolveDoneState(
            remoteId: 'server-done',
            doneSet: const {},
            overrides: const {},
            serverDone: true,
          ),
          isTrue,
        );
        expect(
          store.resolveDoneState(
            remoteId: '',
            doneSet: {'ignored'},
            overrides: const {'ignored': false},
            serverDone: true,
          ),
          isTrue,
        );
      },
    );
  });
}
