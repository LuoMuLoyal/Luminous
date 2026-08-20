import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/domain/entities/device_session.dart';
import 'package:luminous/features/auth/presentation/pages/account_settings_sections.dart';
import 'package:luminous/features/auth/presentation/providers/sessions.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AccountSessionsPage extends ConsumerWidget {
  const AccountSessionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sessions = ref.watch(authSessionsControllerProvider);

    return PageScaffold(
      title: l10n.authSessionsPageTitle,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.level6),
            child: sessions.when(
              loading: () => const _SessionsLoading(),
              error: (error, stackTrace) => StateErrorView(
                title: l10n.authSessionsLoadFailed,
                description: l10n.authSessionsRetryDescription,
                icon: SemanticIcons.statusError,
                actionLabel: l10n.authSessionsRetry,
                onAction: () =>
                    ref.read(authSessionsControllerProvider.notifier).retry(),
              ),
              data: (items) => items.isEmpty
                  ? StateMessageView(
                      title: l10n.authSessionsEmpty,
                      icon: SemanticIcons.statusInfo,
                    )
                  : FCard(
                      child: FTileGroup(
                        children: [
                          for (final session in items)
                            _SessionTile(
                              session: session,
                              onRevoke: () => _revoke(context, ref, session),
                            ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _revoke(
    BuildContext context,
    WidgetRef ref,
    AuthDeviceSession session,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDangerConfirmationDialog(
      context: context,
      title: l10n.authSessionsRevokeConfirmTitle,
      message: session.isCurrent
          ? l10n.authSessionsRevokeCurrentMessage
          : l10n.authSessionsRevokeConfirmMessage,
      confirmLabel: l10n.authSessionsRevoke,
    );
    if (!confirmed || !context.mounted) return;

    final ok = await ref
        .read(authSessionsControllerProvider.notifier)
        .revokeSession(session);
    if (!context.mounted) return;
    if (!ok) {
      await Toast.show(context, l10n.authSessionsRevokeFailed);
      return;
    }
    if (session.isCurrent) {
      context.go(Routes.login);
      return;
    }
    await Toast.show(context, l10n.authSessionsRevokeSuccess);
  }
}

class _SessionTile extends StatelessWidget with FTileMixin {
  const _SessionTile({required this.session, required this.onRevoke});

  final AuthDeviceSession session;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = _deviceLabel(session, l10n);
    final details = [
      if (session.isCurrent) l10n.authSessionsCurrent,
      l10n.authSessionsLastSeen(
        formatDateTime(session.lastUsedAt ?? session.createdAt),
      ),
    ].join(' · ');

    return FTile(
      prefix: Icon(
        SemanticIcons.actionSettings,
        color: context.theme.colors.mutedForeground,
      ),
      title: Text(title),
      subtitle: Text(details),
      suffix: FButton(
        variant: session.isCurrent
            ? FButtonVariant.destructive
            : FButtonVariant.ghost,
        size: FButtonSizeVariant.sm,
        mainAxisSize: MainAxisSize.min,
        onPress: onRevoke,
        child: Text(l10n.authSessionsRevoke),
      ),
    );
  }

  String _deviceLabel(AuthDeviceSession session, AppLocalizations l10n) {
    final name = session.deviceName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return switch (session.platform?.toLowerCase()) {
      'android' => l10n.authSessionsPlatformAndroid,
      'ios' => l10n.authSessionsPlatformIos,
      'web' => l10n.authSessionsPlatformWeb,
      'windows' => l10n.authSessionsPlatformWindows,
      'macos' => l10n.authSessionsPlatformMacos,
      _ =>
        session.deviceType?.trim().isNotEmpty == true
            ? session.deviceType!
            : l10n.authSessionsDeviceUnknown,
    };
  }
}

class _SessionsLoading extends StatelessWidget {
  const _SessionsLoading();

  @override
  Widget build(BuildContext context) {
    return const InlineSkeleton(
      children: [
        InlineSkeletonBlock(height: 68),
        InlineSkeletonBlock(height: 68),
        InlineSkeletonBlock(height: 68),
      ],
    );
  }
}
