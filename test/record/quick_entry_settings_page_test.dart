import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/presentation/pages/quick_entry_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('quick-entry settings exposes first-version settings sections', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      const ProviderScope(child: TestForuiApp(home: QuickEntrySettingsPage())),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('record-quick-settings-page')), findsOneWidget);
    expect(
      find.byKey(const Key('record-quick-settings-dynamic-sort')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('record-quick-settings-reorder')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('record-quick-settings-reset-order')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('record-quick-settings-water-default')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('record-quick-settings-water-badge')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('record-quick-settings-sleep-badge')),
      findsOneWidget,
    );
  });
}
