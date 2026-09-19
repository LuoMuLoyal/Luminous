import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/features/assistant/presentation/utils/ui_formatters.dart';

import '../helpers/test_forui_app.dart';

void main() {
  group('localizeToolName', () {
    testWidgets('maps every tool the server can advertise', (tester) async {
      // The tool list is server-driven (`ASSISTANT_TOOL_NAMES`, code-generated
      // into this enum) while display names live in a hand-written switch.
      // Anything the switch misses falls through to the raw identifier, which
      // put snake_case names on the capabilities panel. Asserting against the
      // generated enum keeps the two in lockstep as tools are added.
      late BuildContext context;
      await tester.pumpWidget(
        TestForuiApp(
          home: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final rawNames = lucent.AssistantCapabilitiesResponseToolsNameEnum.values
          .map((value) => value.value)
          // The codegen fallback for an unrecognized wire value, not a
          // real tool.
          .where((value) => value != 'unknown_default_open_api')
          .toList();

      expect(rawNames, isNotEmpty);

      final unmapped = <String>[];
      for (final raw in rawNames) {
        final localized = localizeToolName(raw, context);
        if (localized == raw) unmapped.add(raw);
      }

      expect(
        unmapped,
        isEmpty,
        reason:
            'These tools have no localized display name and would leak their '
            'internal identifier to the user: $unmapped',
      );
    });
  });
}
