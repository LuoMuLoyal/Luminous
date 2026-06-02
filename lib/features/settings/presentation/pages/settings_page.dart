import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_components.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_theme_sheet.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final session = ref.watch(authSessionProvider);
    final currentTheme =
        ref.watch(appThemeControllerProvider).value ??
        AppThemeModePreference.system;

    return PageScaffoldShell(
      title: l10n.desktopSidebarSettings,
      description: l10n.settingsPageDescription,
      children: [
        MineSectionSurface(
          key: const Key('settings-group-account'),
          typography: typography,
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              MineSettingRow(
                key: const Key('settings-row-account'),
                icon: Icons.verified_user_outlined,
                title: l10n.mineSettingsAccountTitle,
                value: session.user?.email ?? l10n.mineAccountSignedOut,
                typography: typography,
                surface: surface,
                onTap: () => context.push('/account'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacingTokens.md),
        MineSectionSurface(
          key: const Key('settings-group-preferences'),
          typography: typography,
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              MineSettingRow(
                key: const Key('settings-row-theme'),
                icon: Icons.dark_mode_outlined,
                title: l10n.mineSettingsThemeTitle,
                value: _themeModeLabel(l10n, currentTheme),
                typography: typography,
                surface: surface,
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (_) => const ThemeModeSheet(),
                  );
                },
                showDivider: true,
              ),
              MineSettingRow(
                key: const Key('settings-row-language'),
                icon: Icons.language_outlined,
                title: l10n.mineSettingsLanguageTitle,
                value: l10n.mineSettingsLanguageValue,
                typography: typography,
                surface: surface,
                onTap: () => showMineToast(
                  context,
                  l10n.mineSettingsLanguageTitle,
                ),
                showDivider: true,
              ),
              MineSettingRow(
                key: const Key('settings-row-notifications'),
                icon: Icons.notifications_none_rounded,
                title: l10n.mineSettingsNotificationsTitle,
                typography: typography,
                surface: surface,
                onTap: () => showMineToast(
                  context,
                  l10n.mineSettingsNotificationsTitle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacingTokens.md),
        MineSectionSurface(
          key: const Key('settings-group-more'),
          typography: typography,
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              MineSettingRow(
                key: const Key('settings-row-more'),
                icon: Icons.tune_rounded,
                title: l10n.mineSettingsMoreTitle,
                typography: typography,
                surface: surface,
                onTap: () => showMineToast(context, l10n.mineSettingsMoreTitle),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacingTokens.xl),
        _FooterActionButton(
          key: const Key('settings-footer-action'),
          label: session.isAuthenticated ? l10n.authSignOut : l10n.authGoLogin,
          destructive: session.isAuthenticated,
          onTap: session.isLoading
              ? null
              : () async {
                  if (!session.isAuthenticated) {
                    context.go('/login');
                    return;
                  }
                  await ref.read(authSessionProvider.notifier).logout();
                  if (!context.mounted) {
                    return;
                  }
                  context.go('/login');
                },
        ),
      ],
    );
  }

  String _themeModeLabel(
    AppLocalizations l10n,
    AppThemeModePreference preference,
  ) {
    return switch (preference) {
      AppThemeModePreference.system => l10n.mineThemeModeSystem,
      AppThemeModePreference.light => l10n.mineThemeModeLight,
      AppThemeModePreference.dark => l10n.mineThemeModeDark,
    };
  }
}

class _FooterActionButton extends StatelessWidget {
  const _FooterActionButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.destructive,
  });

  final String label;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final foreground = onTap == null
        ? surface.body.withValues(alpha: 0.45)
        : destructive
        ? theme.colorScheme.error
        : surface.body;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
            border: Border.all(color: surface.hairline),
            boxShadow: AppShadowTokens.level2,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.lg),
            child: Center(
              child: Text(
                label,
                style: typography.bodyMdStrong.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
