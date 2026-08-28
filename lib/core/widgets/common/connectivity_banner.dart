import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// A non-blocking banner shown at the top of the shell when the session
/// restore has timed out. It signals "network recovery in progress" so
/// the user understands the app is waiting, not permanently signed out.
///
/// Tapping "Retry" re-triggers [AuthSessionNotifier.restore].
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    if (!session.isTimeout) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final warningPalette = context.theme.colors.semantic.warning;

    return Material(
      color: warningPalette.solid,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.level3,
            vertical: Spacing.level2,
          ),
          child: Row(
            children: [
              Icon(
                SemanticIcons.statusWarning,
                size: IconSizeTokens.level3,
                color: warningPalette.foreground,
              ),
              const SizedBox(width: Spacing.level2),
              Expanded(
                child: Text(
                  l10n.authSessionRestoreTimeout,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: warningPalette.foreground,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              FButton(
                variant: FButtonVariant.ghost,
                onPress: () =>
                    ref.read(authSessionProvider.notifier).restore(),
                child: Text(
                  l10n.commonRetry,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: warningPalette.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
