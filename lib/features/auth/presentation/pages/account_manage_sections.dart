import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/config/env_keys.dart';
import 'package:luminous/core/config/env_reader.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/providers/sensitive_action_password.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_view.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/pages/account_identity.dart';
import 'package:luminous/features/auth/presentation/pages/account_manage_helpers.dart';
import 'package:luminous/features/auth/presentation/pages/account_security.dart';
import 'package:luminous/features/auth/presentation/providers/account.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/section_label.dart';
import 'package:luminous/features/support/data/providers/resources.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

// 保留账号设置加载状态组件
class AccountManageLoading extends StatelessWidget {
  const AccountManageLoading({super.key});

  @override
  Widget build(BuildContext context) => const InlineSkeleton(
    children: [
      InlineSkeletonBlock(height: 96),
      InlineSkeletonBlock(height: 132),
      InlineSkeletonBlock(height: 96),
      InlineSkeletonBlock(height: 116),
    ],
  );
}

/// 顶部概要卡片：头像 + 昵称 + 邮箱
class AccountSummaryCard extends StatelessWidget {
  const AccountSummaryCard({super.key, required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: SemanticColor.neutral.border(context)),
        borderRadius: context.theme.style.borderRadius.md,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Row(
          children: [
            // 头像
            AvatarView(
              avatarUrl: user.avatar,
              size: 64,
              iconSize: 32,
              semanticLabel: l10n.profileAvatarLabel,
            ),
            const SizedBox(width: Spacing.xl),
            // 昵称和邮箱
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.nickname ?? l10n.authAccountOverviewEmail,
                    style: context.theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    user.email ?? l10n.authEmailMissing,
                    style: context.theme.typography.body.sm.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 账号管理主列表
class AccountManageSection extends ConsumerWidget {
  const AccountManageSection({
    super.key,
    required this.user,
    required this.l10n,
    required this.accountState,
    required this.accountNotifier,
    required this.emailController,
    required this.nicknameController,
    required this.oldPasswordController,
    required this.newPasswordController,
    required this.deletePasswordController,
    required this.deleteCodeController,
    required this.onVerifyEmail,
    required this.onChangeEmail,
    required this.onManageSessions,
    required this.onManageSecurityCenter,
  });

  final AuthUser user;
  final AppLocalizations l10n;
  final AuthAccountState accountState;
  final AuthAccountNotifier accountNotifier;
  final TextEditingController emailController;
  final TextEditingController nicknameController;
  final TextEditingController oldPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController deletePasswordController;
  final TextEditingController deleteCodeController;
  final Future<void> Function() onVerifyEmail;
  final VoidCallback onChangeEmail;
  final VoidCallback onManageSessions;
  final VoidCallback onManageSecurityCenter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 账号信息分组
        SettingsSectionLabel(label: l10n.authAccountManageSectionAccount),
        SizedBox(height: context.titleContentGap),
        FTileGroup(
          physics: const NeverScrollableScrollPhysics(),
          divider: FItemDivider.full,
          children: [
            // 用户名
            FTile(
              prefix: Icon(
                SemanticIcons.actionSettings,
                color: SemanticColor.neutral.solid(context),
                size: IconSizeTokens.md,
              ),
              title: Text(l10n.authAccountManageUsername),
              subtitle: Text(
                user.nickname ?? l10n.authAccountManageUsernameNotSet,
                style: TextStyle(color: SemanticColor.neutral.solid(context)),
              ),
              suffix: const Icon(SemanticIcons.actionNext),
              onPress: () {
                // TODO: 实现用户名设置页面
              },
            ),
            // 邮箱
            FTile(
              prefix: Icon(
                SemanticIcons.actionMessage,
                color: SemanticColor.neutral.solid(context),
                size: IconSizeTokens.md,
              ),
              title: Text(l10n.authAccountManageEmail),
              subtitle: Text(
                user.email ?? l10n.authEmailMissing,
                style: TextStyle(color: SemanticColor.neutral.solid(context)),
              ),
              suffix: user.emailVerifiedAt != null
                  ? Icon(
                      SemanticIcons.statusSuccess,
                      size: 16,
                      color: SemanticColor.success.solid(context),
                    )
                  : const Icon(SemanticIcons.actionNext),
              onPress: onChangeEmail,
            ),
            // 第三方账号
            FTile(
              prefix: Icon(
                SemanticIcons.actionExternalLink,
                color: SemanticColor.neutral.solid(context),
                size: IconSizeTokens.md,
              ),
              title: Text(l10n.authAccountManageThirdParty),
              subtitle: Text(
                _getThirdPartySubtitle(user, l10n),
                style: TextStyle(color: SemanticColor.neutral.solid(context)),
              ),
              suffix: const Icon(SemanticIcons.actionNext),
              onPress: () => _showThirdPartyDialog(context, ref),
            ),
          ],
        ),
        const SizedBox(height: Spacing.xl2),

        // 账号安全分组
        SettingsSectionLabel(label: l10n.authAccountManageSectionSecurity),
        SizedBox(height: context.titleContentGap),
        FTileGroup(
          physics: const NeverScrollableScrollPhysics(),
          divider: FItemDivider.full,
          children: [
            // 登录密码
            FTile(
              prefix: Icon(
                SemanticIcons.actionSettings,
                color: SemanticColor.neutral.solid(context),
                size: IconSizeTokens.md,
              ),
              title: Text(l10n.authAccountManagePassword),
              subtitle: Text(
                user.hasPassword
                    ? l10n.authAccountManagePasswordSet
                    : l10n.authAccountManagePasswordNotSet,
                style: TextStyle(color: SemanticColor.neutral.solid(context)),
              ),
              suffix: const Icon(SemanticIcons.actionNext),
              onPress: () => _showPasswordDialog(context, ref),
            ),
            // 登录设备
            FTile(
              prefix: Icon(
                SemanticIcons.statusPending,
                color: SemanticColor.neutral.solid(context),
                size: IconSizeTokens.md,
              ),
              title: Text(l10n.authAccountManageLoginDevices),
              subtitle: Text(
                l10n.authSessionsSectionSubtitle,
                style: TextStyle(color: SemanticColor.neutral.solid(context)),
              ),
              suffix: const Icon(SemanticIcons.actionNext),
              onPress: onManageSessions,
            ),
            // 账号安全中心
            FTile(
              prefix: Icon(
                SemanticIcons.statusWarning,
                color: SemanticColor.neutral.solid(context),
                size: IconSizeTokens.md,
              ),
              title: Text(l10n.authAccountManageSecurityCenter),
              subtitle: Text(
                l10n.authAccountManageSecurityCenterSubtitle,
                style: TextStyle(color: SemanticColor.neutral.solid(context)),
              ),
              suffix: const Icon(SemanticIcons.actionNext),
              onPress: onManageSecurityCenter,
            ),
            // 账号注销
            FTile(
              prefix: Icon(
                SemanticIcons.statusWarning,
                color: SemanticColor.destructive.solid(context),
                size: IconSizeTokens.md,
              ),
              title: Text(
                l10n.authAccountManageDeleteAccount,
                style: TextStyle(
                  color: SemanticColor.destructive.solid(context),
                ),
              ),
              subtitle: Text(
                l10n.authDeleteAccountSectionDescription,
                style: TextStyle(color: SemanticColor.neutral.solid(context)),
              ),
              suffix: Icon(
                SemanticIcons.actionNext,
                color: SemanticColor.destructive.solid(context),
              ),
              onPress: () => _showDeleteAccountDialog(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  String _getThirdPartySubtitle(AuthUser user, AppLocalizations l10n) {
    if (user.linkedIdentities.isEmpty) {
      return l10n.authAccountManageThirdPartyNone;
    }
    final providers = user.linkedIdentities
        .map((identity) => identityProviderLabel(identity.provider, l10n))
        .join(', ');
    return providers;
  }

  Future<void> _showThirdPartyDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showAppDialog<void>(
      context: context,
      maxWidth: LayoutScaleResolver.wideDialogMaxWidthFor(
        MediaQuery.sizeOf(context).width,
      ),
      builder: (context) => LinkedIdentitiesSection(
        user: user,
        isSubmitting: accountState.isSubmitting,
        onLinkWechat: () async {
          // TODO: 实现微信绑定
        },
        onUnlink: (identity) async {
          final confirmed = await confirmUnlinkIdentity(
            context,
            identity,
            l10n,
          );
          if (!confirmed || !context.mounted) return;
          final password = await ref.read(
            sensitiveActionPasswordPromptProvider,
          )(context);
          if (password == null || !context.mounted) return;
          final ok = await accountNotifier.unlinkIdentity(
            identityId: identity.id,
            password: password,
          );
          if (!ok && context.mounted) {
            await showAuthAccountFailureToast(context, ref, l10n);
            return;
          }
          if (ok && context.mounted) {
            await Toast.show(context, l10n.authIdentityUnlinkSuccess);
          }
        },
        showWechatLink: false,
      ),
    );
  }

  Future<void> _showPasswordDialog(BuildContext context, WidgetRef ref) async {
    await showAppDialog<void>(
      context: context,
      maxWidth: LayoutScaleResolver.wideDialogMaxWidthFor(
        MediaQuery.sizeOf(context).width,
      ),
      builder: (context) => PasswordSection(
        user: user,
        oldPasswordController: oldPasswordController,
        newPasswordController: newPasswordController,
        isSubmitting: accountState.isSubmitting,
        onChangePassword: () async {
          final ok = await accountNotifier.changePassword(
            password: oldPasswordController.text,
            newPassword: newPasswordController.text,
          );
          if (!ok && context.mounted) {
            await showAuthAccountFailureToast(context, ref, l10n);
            return;
          }
          if (!ok || !context.mounted) return;
          await Toast.show(context, l10n.authChangePasswordSuccess);
          if (context.mounted) Navigator.of(context).pop(); // Close dialog
        },
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showAppDialog<void>(
      context: context,
      maxWidth: LayoutScaleResolver.wideDialogMaxWidthFor(
        MediaQuery.sizeOf(context).width,
      ),
      builder: (context) => DeleteAccountSection(
        user: user,
        deletePasswordController: deletePasswordController,
        deleteCodeController: deleteCodeController,
        isSubmitting: accountState.isSubmitting,
        isSendingCode: accountState.isSendingCode,
        cooldownSeconds: accountState.lastCooldownSeconds,
        onSendCode: () async {
          if (user.email == null || user.email!.trim().isEmpty) {
            await Toast.show(context, l10n.authDeleteAccountEmailRequiredHint);
            return;
          }
          await accountNotifier.sendVerificationCode(
            email: user.email!,
            scene: AuthVerificationScene.deleteAccount,
          );
        },
        onDelete: () async {
          if (user.hasPassword) {
            final ok = await accountNotifier.deleteAccount(
              password: deletePasswordController.text,
            );
            if (!ok && context.mounted) {
              final msg = accountState.errorMessage?.isNotEmpty == true
                  ? accountState.errorMessage!
                  : null;
              if (msg != null) {
                await Toast.show(context, msg);
              }
              return;
            }
            if (!ok || !context.mounted) return;
            await Toast.show(context, l10n.authDeleteAccountSuccess);
            if (context.mounted) context.go(Routes.login);
          } else {
            final ok = await accountNotifier.deleteAccount(
              code: deleteCodeController.text,
            );
            if (!ok && context.mounted) {
              final msg = accountState.errorMessage?.isNotEmpty == true
                  ? accountState.errorMessage!
                  : null;
              if (msg != null) {
                await Toast.show(context, msg);
              }
              return;
            }
            if (!ok || !context.mounted) return;
            await Toast.show(context, l10n.authDeleteAccountSuccess);
            if (context.mounted) context.go(Routes.login);
          }
        },
      ),
    );
  }
}

/// 底部服务入口
class SupportLinksSection extends ConsumerWidget {
  const SupportLinksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // Prefer backend supportEmail; fall back to compile-time env.
    final appInfo = ref.watch(appInfoProvider).asData?.value;
    final supportEmail =
        appInfo?.supportEmail ?? EnvReader.string(EnvKey.supportEmail);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionLabel(label: l10n.authAccountManageBottomSupport),
        SizedBox(height: context.titleContentGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _SupportLink(
                icon: SemanticIcons.actionMessage,
                label: l10n.authAccountManageSupportCustomerService,
                onTap: () => _openCustomerService(context),
              ),
            ),
            Expanded(
              child: _SupportLink(
                icon: SemanticIcons.actionSettings,
                label: l10n.authAccountManageSupportFeedback,
                onTap: () => _openFeedback(context, l10n, supportEmail),
              ),
            ),
            Expanded(
              child: _SupportLink(
                icon: SemanticIcons.actionSettings,
                label: l10n.authAccountManageSupportHelpCenter,
                onTap: () => _openHelpCenter(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openCustomerService(BuildContext context) async {
    await context.push(Routes.settingsHelp);
  }

  Future<void> _openFeedback(
    BuildContext context,
    AppLocalizations l10n,
    String email,
  ) async {
    if (email.isEmpty) {
      await Toast.show(context, l10n.settingsHelpFeedbackUnavailable);
      return;
    }
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(l10n.settingsHelpFeedbackSubject)}',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      await Toast.show(context, l10n.settingsHelpFeedbackOpenFailed);
    }
  }

  Future<void> _openHelpCenter(BuildContext context) async {
    await context.push(Routes.settingsHelp);
  }
}

/// 支持链接项
class _SupportLink extends StatelessWidget {
  const _SupportLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: SemanticColor.neutral.solid(context)),
            const SizedBox(height: Spacing.sm),
            Text(
              label,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
