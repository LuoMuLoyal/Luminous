import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/providers/sensitive_action_password.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_view.dart';
import 'package:luminous/core/widgets/common/control/back_button.dart';
import 'package:luminous/core/widgets/common/control/tile_value.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/pages/account_identity.dart';
import 'package:luminous/features/auth/presentation/pages/account_manage_helpers.dart';
import 'package:luminous/features/auth/presentation/providers/account.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/shell.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/section_label.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 账号概要卡片：头像 + 昵称 + 邮箱，点击进入个人信息页。
class _AccountOverviewCard extends StatelessWidget {
  const _AccountOverviewCard({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FTileGroup(
      physics: const NeverScrollableScrollPhysics(),
      divider: FItemDivider.full,
      children: [
        FTile(
          key: const Key('security-center-avatar-row'),
          prefix: AvatarView(
            avatarUrl: user.avatar,
            size: 40,
            iconSize: 20,
            semanticLabel: l10n.profileAvatarLabel,
          ),
          title: Text(l10n.profileAvatarRowTitle),
          suffix: const Icon(SemanticIcons.actionNext),
          onPress: () => context.push(Routes.profile),
        ),
        FTile(
          key: const Key('security-center-nickname-row'),
          title: Text(l10n.profileNicknameLabel),
          details: AppTileValue(
            user.nickname?.trim().isNotEmpty == true
                ? user.nickname!.trim()
                : l10n.profileEmptyValue,
          ),
          suffix: const Icon(SemanticIcons.actionNext),
          onPress: () => context.push(Routes.profile),
        ),
        FTile(
          title: Text(l10n.authAccountManageEmail),
          details: AppTileValue(user.email ?? l10n.authEmailMissing),
        ),
      ],
    );
  }
}

/// 账号安全中心页面
class SecurityCenterPage extends ConsumerWidget {
  const SecurityCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final accountState = ref.watch(authAccountProvider);
    final accountNotifier = ref.read(authAccountProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final user = session.user;
    final resolvingSession = session.isLoading;
    final signedOut = !session.canAccessProtectedData || user == null;

    return AuthShell(
      title: l10n.authAccountManageSecurityCenter,
      leading: const AppBackButton(),
      centerTitle: true,
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (resolvingSession) ...[
            const _SecurityCenterLoading(),
          ] else if (signedOut) ...[
            AuthRequiredDialogGate(
              onLogin: () =>
                  context.push(loginRouteForCurrentLocation(context)),
            ),
          ] else ...[
            // 账号概要：头像 + 昵称 / 邮箱，与个人信息页同一「左标签 / 右数据」观感，
            // 点击回到个人信息页编辑。
            _AccountOverviewCard(user: user),
            const SizedBox(height: Spacing.xl2),

            // 授权记录
            LinkedIdentitiesSection(
              user: user,
              isSubmitting: accountState.isSubmitting,
              onLinkWechat: () async {
                await startWechatIdentityLink(context, l10n, ref);
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
            const SizedBox(height: Spacing.xl2),

            // 敏感操作记录
            SettingsSectionLabel(
              label: l10n.securityCenterSensitiveOperationsTitle,
            ),
            const SizedBox(height: Spacing.md),
            _EmptyRecordCard(
              message: l10n.securityCenterSensitiveOperationsEmpty,
            ),
            const SizedBox(height: Spacing.xl2),

            // 登录记录
            SettingsSectionLabel(label: l10n.securityCenterLoginHistoryTitle),
            SizedBox(height: context.titleContentGap),
            FTileGroup(
              physics: const NeverScrollableScrollPhysics(),
              divider: FItemDivider.full,
              children: [
                FTile(
                  prefix: Icon(
                    SemanticIcons.statusPending,
                    color: SemanticColor.neutral.solid(context),
                    size: IconSizeTokens.md,
                  ),
                  title: Text(l10n.securityCenterLoginHistoryViewAll),
                  subtitle: Text(
                    l10n.securityCenterLoginHistoryViewAllSubtitle,
                    style: TextStyle(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                  suffix: const Icon(SemanticIcons.actionNext),
                  onPress: () => context.push(Routes.accountSessions),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xl2),

            // 账号保护（预留）
            SettingsSectionLabel(
              label: l10n.securityCenterAccountProtectionTitle,
            ),
            const SizedBox(height: Spacing.md),
            FTileGroup(
              physics: const NeverScrollableScrollPhysics(),
              divider: FItemDivider.full,
              children: [
                FTile(
                  prefix: Icon(
                    SemanticIcons.safetySafe,
                    color: SemanticColor.neutral.solid(context),
                    size: IconSizeTokens.md,
                  ),
                  title: Text(l10n.securityCenterAccountProtectionComingSoon),
                  subtitle: Text(
                    l10n.securityCenterAccountProtectionComingSoonSubtitle,
                    style: TextStyle(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                  suffix: const Icon(SemanticIcons.actionNext),
                  onPress: () {}, // 预留入口，暂无具体功能
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 安全中心加载状态（shimmer 骨架屏）
class _SecurityCenterLoading extends StatelessWidget {
  const _SecurityCenterLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InlineSkeleton(
          children: [
            InlineSkeletonBlock(height: 96),
            InlineSkeletonBlock(height: 132),
            InlineSkeletonBlock(height: 96),
            InlineSkeletonBlock(height: 116),
          ],
        ),
      ],
    );
  }
}

/// 空记录占位卡片
class _EmptyRecordCard extends StatelessWidget {
  const _EmptyRecordCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: SemanticColor.neutral.border(context)),
        borderRadius: context.theme.style.borderRadius.md,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Row(
          children: [
            Icon(
              SemanticIcons.statusInfo,
              color: SemanticColor.neutral.solid(context),
              size: 20,
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                message,
                style: context.theme.typography.body.sm.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
