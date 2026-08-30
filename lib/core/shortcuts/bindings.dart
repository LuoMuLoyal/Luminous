import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/shortcuts/intents.dart';
import 'package:luminous/core/widgets/common/command_palette.dart';

/// Wraps the app with global keyboard shortcuts and actions.
///
/// Internally it composes the native Flutter [Shortcuts] + [Actions] widgets.
class AppShortcuts extends StatelessWidget {
  const AppShortcuts({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        // ── Ctrl/Cmd+K → Command palette ──
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            const OpenCommandPaletteIntent(),
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            const OpenCommandPaletteIntent(),

        // ── Ctrl/Cmd+N → New record ──
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            const CreateRecordIntent(),
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true):
            const CreateRecordIntent(),

        // ── Ctrl/Cmd+, → Settings ──
        const SingleActivator(LogicalKeyboardKey.comma, control: true):
            const OpenSettingsIntent(),
        const SingleActivator(LogicalKeyboardKey.comma, meta: true):
            const OpenSettingsIntent(),

        // ── Ctrl/Cmd+Shift+A → Assistant ──
        const SingleActivator(
          LogicalKeyboardKey.keyA,
          control: true,
          shift: true,
        ): const OpenAssistantIntent(),
        const SingleActivator(LogicalKeyboardKey.keyA, meta: true, shift: true):
            const OpenAssistantIntent(),

        // ── Ctrl/Cmd+1..5 → Switch tabs ──
        const SingleActivator(LogicalKeyboardKey.digit1, control: true):
            const SwitchTabIntent(0),
        const SingleActivator(LogicalKeyboardKey.digit1, meta: true):
            const SwitchTabIntent(0),
        const SingleActivator(LogicalKeyboardKey.digit2, control: true):
            const SwitchTabIntent(1),
        const SingleActivator(LogicalKeyboardKey.digit2, meta: true):
            const SwitchTabIntent(1),
        const SingleActivator(LogicalKeyboardKey.digit3, control: true):
            const SwitchTabIntent(2),
        const SingleActivator(LogicalKeyboardKey.digit3, meta: true):
            const SwitchTabIntent(2),
        const SingleActivator(LogicalKeyboardKey.digit4, control: true):
            const SwitchTabIntent(3),
        const SingleActivator(LogicalKeyboardKey.digit4, meta: true):
            const SwitchTabIntent(3),
        const SingleActivator(LogicalKeyboardKey.digit5, control: true):
            const SwitchTabIntent(4),
        const SingleActivator(LogicalKeyboardKey.digit5, meta: true):
            const SwitchTabIntent(4),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          OpenCommandPaletteIntent: CallbackAction<OpenCommandPaletteIntent>(
            onInvoke: (_) => showCommandPalette(context),
          ),
          CreateRecordIntent: CallbackAction<CreateRecordIntent>(
            onInvoke: (_) {
              unawaited(context.push(Routes.recordCreate));
              return null;
            },
          ),
          OpenSettingsIntent: CallbackAction<OpenSettingsIntent>(
            onInvoke: (_) {
              unawaited(context.push(Routes.settings));
              return null;
            },
          ),
          OpenAssistantIntent: CallbackAction<OpenAssistantIntent>(
            onInvoke: (_) {
              unawaited(context.push(Routes.assistant));
              return null;
            },
          ),
          // Tab switching uses context.go to the tab root path, which
          // GoRouter resolves through the StatefulShellRoute.
          SwitchTabIntent: CallbackAction<SwitchTabIntent>(
            onInvoke: (intent) {
              const tabRoutes = [
                Routes.home,
                Routes.record,
                Routes.medicine,
                Routes.review,
                Routes.mine,
              ];
              final index = intent.index;
              if (index >= 0 && index < tabRoutes.length) {
                context.go(tabRoutes[index]);
              }
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}
