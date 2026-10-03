import 'package:flutter/widgets.dart';
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
///
/// Layout note: uses only Flutter framework widgets (`flutter/widgets.dart`)
/// plus Forui's `FButton`. No `Material` ancestor or `flutter/material.dart`
/// import — the background color comes from `ColoredBox` with the semantic
/// warning palette.
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final typography = context.theme.typography;
    if (!session.isTimeout) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final warningPalette = context.theme.colors.semantic.warning;

    return ColoredBox(
      color: warningPalette.solid,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                SemanticIcons.statusWarning,
                size: IconSizeTokens.md,
                color: warningPalette.foreground,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  l10n.authSessionRestoreTimeout,
                  style: typography.body.sm.copyWith(
                    color: warningPalette.foreground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // 重试按钮给宽度上限 + 标签省略:Row 先给非 flex 子节点无界主轴约束,
              // 裸 FButton 会按固有宽度把左侧提示文字挤没或自己右溢。
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: FButton(
                  variant: FButtonVariant.ghost,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () =>
                      ref.read(authSessionProvider.notifier).restore(),
                  child: Flexible(
                    child: Text(
                      l10n.commonRetry,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: typography.body.sm.copyWith(
                        color: warningPalette.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
