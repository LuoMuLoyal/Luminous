import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/nlp_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/test_helpers.dart';
import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('RecordNlpSheet renders', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        ],
        child: TestForuiApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showFSheet(
                  context: context,
                  side: FLayout.btt,
                  useSafeArea: true,
                  resizeToAvoidBottomInset: true,
                  mainAxisMaxRatio: 0.85,
                  builder: (_) =>
                      const RecordNlpSheet(occurredAt: '2026-06-10'),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(RecordNlpSheet), findsOneWidget);
  });
}
