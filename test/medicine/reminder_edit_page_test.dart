import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/medicine/presentation/pages/reminder/edit.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/loading.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_forui_app.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    String? currentMedicineId,
    String? initialMedicineId,
    AuthSessionState session = const AuthSessionState(),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => _FakeSessionProvider(session)),
        ],
        child: TestForuiApp(
          home: MedicineReminderEditPage(
            currentMedicineId: currentMedicineId,
            initialMedicineId: initialMedicineId,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  group('MedicineReminderEditPage — signed-out state', () {
    testWidgets('renders loading skeleton when session is loading', (
      tester,
    ) async {
      await pumpPage(tester, session: const AuthSessionState(isLoading: true));

      expect(find.byType(ReminderLoading), findsOneWidget);
    });

    testWidgets('renders auth gate when signed out', (tester) async {
      await pumpPage(tester);

      expect(find.byType(AuthRequiredDialogGate), findsOneWidget);
    });
  });

  group('MedicineReminderEditPage — titles', () {
    testWidgets('renders new title when currentMedicineId is null', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester);

      expect(find.text(l10n.medicineReminderNewTitle), findsOneWidget);
    });

    testWidgets('renders edit title when currentMedicineId is provided', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, currentMedicineId: 'med-1');

      expect(find.text(l10n.medicineReminderEditTitle), findsOneWidget);
    });
  });
}

class _FakeSessionProvider extends AuthSessionNotifier {
  _FakeSessionProvider(this._initial);

  final AuthSessionState _initial;

  @override
  AuthSessionState build() => _initial;
}
