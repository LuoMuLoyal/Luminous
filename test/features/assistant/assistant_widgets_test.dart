import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/assistant/presentation/providers/assistant_controller.dart';
import 'package:luminous/features/assistant/presentation/widgets/assistant_chips.dart';
import 'package:luminous/features/assistant/presentation/widgets/assistant_conversation_drawer.dart';
import 'package:luminous/features/assistant/presentation/widgets/assistant_loading_view.dart';
import 'package:luminous/features/assistant/presentation/widgets/assistant_state_card.dart';
import 'package:luminous/l10n/app_localizations.dart';

Widget _shell(Widget child) {
  return MaterialApp(
    theme: ThemeData.light().copyWith(
      extensions: const <ThemeExtension<dynamic>>[AppThemeSurface.light],
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('AssistantToolChip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        _shell(const AssistantToolChip(label: 'Today Records')),
      );
      expect(find.text('Today Records'), findsOneWidget);
    });
  });

  group('AssistantLoadingView', () {
    testWidgets('renders', (tester) async {
      await tester.pumpWidget(
        _shell(
          const SizedBox(
            height: 800,
            child: SingleChildScrollView(child: AssistantLoadingView()),
          ),
        ),
      );
      expect(find.byType(AssistantLoadingView), findsOneWidget);
    });
  });

  group('AssistantConversationDrawer', () {
    testWidgets('renders with empty state', (tester) async {
      await tester.pumpWidget(
        _shell(
          AssistantConversationDrawer(
            state: const AssistantState(),
            title: 'History',
            emptyTitle: 'No conversations',
            emptyDescription: 'Start a new chat',
            onRetry: () {},
            onSelect: (_) {},
          ),
        ),
      );
      expect(find.text('No conversations'), findsOneWidget);
    });
  });

  group('AssistantStateCard', () {
    testWidgets('renders title and description', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantStateCard(
            title: 'Ready',
            description: 'Assistant is active',
            icon: Icons.check_circle,
          ),
        ),
      );
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Assistant is active'), findsOneWidget);
    });

    testWidgets('renders action button', (tester) async {
      await tester.pumpWidget(
        _shell(
          AssistantStateCard(
            title: 'Error',
            description: 'Something went wrong',
            icon: Icons.error,
            actionLabel: 'Retry',
            onAction: () {},
            tone: AppStateTone.danger,
          ),
        ),
      );
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
