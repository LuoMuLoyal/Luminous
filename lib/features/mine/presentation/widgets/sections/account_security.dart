import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/shared.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineAccountSecuritySection extends ConsumerWidget {
  const MineAccountSecuritySection({super.key, required this.account});

  final MineAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final session = ref.watch(authSessionProvider);
    final signedIn = session.canAccessProtectedData;
    final accountSubtitle = account.isAuthenticated
        ? (account.email.isNotEmpty
              ? account.email
              : mineCopy(l10n, account.statusKey))
        : l10n.mineAccountSignedOutMeta;

    return Column(
      key: const Key('mine-account-security-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MineSectionTitle(title: l10n.settingsAccountSecuritySectionTitle),
        const SizedBox(height: Spacing.level3),
        FTileGroup(
          divider: FItemDivider.full,
          children: [
            FTile(
              key: const Key('mine-account-settings-tile'),
              prefix: Icon(
                FLucideIcons.userCheck,
                color: colors.primary,
                size: Spacing.level5,
              ),
              title: Text(l10n.mineSettingsAccountTitle),
              subtitle: Text(
                accountSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => pushAuthRequiredRoute(context, AppRoutes.account),
            ),
            FTile(
              key: const Key('mine-security-pin-tile'),
              prefix: Icon(
                FLucideIcons.lockKeyhole,
                color: colors.primary,
                size: Spacing.level5,
              ),
              title: Text(l10n.settingsSecurityPinTitle),
              subtitle: Text(
                l10n.settingsSecurityPinSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () =>
                  pushAuthRequiredRoute(context, AppRoutes.settingsSecurityPin),
            ),
            FTile(
              key: const Key('mine-sign-out-tile'),
              prefix: Icon(
                FLucideIcons.logOut,
                color: colors.error,
                size: Spacing.level5,
              ),
              title: Text(
                signedIn ? l10n.authSignOut : l10n.authGoLogin,
                style: TypographyToken.level5
                    .body(context)
                    .copyWith(color: colors.error),
              ),
              enabled: !session.isLoading,
              onPress: session.isLoading
                  ? null
                  : () async {
                      if (!signedIn) {
                        context.go(loginRouteForCurrentLocation(context));
                        return;
                      }
                      await ref.read(authSessionProvider.notifier).logout();
                      if (!context.mounted) return;
                      context.go(AppRoutes.login);
                    },
            ),
          ],
        ),
      ],
    );
  }
}
