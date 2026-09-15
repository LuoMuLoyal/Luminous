import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 账号概览部分 - 显示邮箱、验证状态、密码设置状态、最后登录时间
class AccountStatusSection extends StatelessWidget {
  const AccountStatusSection({
    super.key,
    required this.user,
    required this.l10n,
    this.onVerifyEmail,
  });

  final AuthUser user;
  final AppLocalizations l10n;
  final Future<void> Function()? onVerifyEmail;

  @override
  Widget build(BuildContext context) => _SectionColumn(
    title: l10n.authAccountOverviewTitle,
    children: [
      _InfoRow(
        icon: SemanticIcons.actionMessage,
        label: l10n.authAccountOverviewEmail,
        value: user.email ?? l10n.authEmailMissing,
      ),
      _InfoRow(
        icon: user.emailVerified
            ? SemanticIcons.statusSuccess
            : SemanticIcons.notificationWarning,
        label: l10n.authAccountOverviewEmailVerified,
        value: user.emailVerifiedAt == null
            ? l10n.authEmailUnverifiedStatus
            : l10n.authEmailVerifiedAt(formatDateTime(user.emailVerifiedAt!)),
      ),
      if (user.email != null &&
          user.emailVerifiedAt == null &&
          onVerifyEmail != null)
        SizedBox(
          width: double.infinity,
          child: FButton(
            variant: FButtonVariant.outline,
            onPress: () => onVerifyEmail!(),
            child: Text(l10n.authEmailVerifyAction),
          ),
        ),
      _InfoRow(
        icon: user.hasPassword
            ? SemanticIcons.statusBlocked
            : SemanticIcons.actionSettings,
        label: l10n.authAccountOverviewPassword,
        value: user.hasPassword
            ? l10n.authPasswordSetStatus
            : l10n.authPasswordUnsetStatus,
      ),
      _InfoRow(
        icon: SemanticIcons.statusPending,
        label: l10n.authAccountOverviewLastLogin,
        value: user.lastLoginAt == null
            ? l10n.authLastLoginUnknown
            : formatDateTime(user.lastLoginAt!),
      ),
    ],
  );
}

/// 邮箱部分 - 显示和修改邮箱
class EmailSection extends StatelessWidget {
  const EmailSection({
    super.key,
    required this.user,
    required this.emailController,
    required this.onChangeEmail,
  });

  final AuthUser user;
  final TextEditingController emailController;
  final VoidCallback onChangeEmail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SectionColumn(
      title: l10n.authEmailSectionTitle,
      children: [
        FTextField.email(
          control: FTextFieldControl.managed(controller: emailController),
          label: Text(l10n.authEmailLabel),
          enabled: false,
        ),
        SizedBox(
          width: double.infinity,
          child: FButton(
            onPress: onChangeEmail,
            child: Text(
              user.email == null
                  ? l10n.authEmailAddAction
                  : l10n.authEmailChangeAction,
            ),
          ),
        ),
      ],
    );
  }
}

/// 绑定身份部分 - 显示已绑定的第三方账号和绑定/解绑操作
class LinkedIdentitiesSection extends StatelessWidget {
  const LinkedIdentitiesSection({
    super.key,
    required this.user,
    required this.isSubmitting,
    required this.onLinkWechat,
    required this.onUnlink,
    this.showWechatLink = true,
  });

  final AuthUser user;
  final bool isSubmitting;

  /// Runs the WeChat binding flow. Null when the host page hides the entry
  /// point ([showWechatLink] `false`): the button is then not rendered at all,
  /// so no caller has to pass a no-op callback that can never run.
  final Future<void> Function()? onLinkWechat;
  final Future<void> Function(AuthLinkedIdentity identity) onUnlink;

  /// Shows the "绑定微信" button. When `false` the button is removed but the
  /// underlying flow and any already-linked identity tiles remain visible.
  final bool showWechatLink;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final linkWechat = onLinkWechat;
    return _SectionColumn(
      title: l10n.authLinkedIdentitiesSectionTitle,
      children: [
        if (user.linkedIdentities.isEmpty)
          _MutedText(l10n.authLinkedIdentityNone)
        else
          ...user.linkedIdentities.map(
            (identity) => LinkedIdentityTile(
              user: user,
              identity: identity,
              isSubmitting: isSubmitting,
              onUnlink: () => onUnlink(identity),
            ),
          ),
        if (showWechatLink && linkWechat != null)
          FButton(
            key: const Key('wechat-identity-link-button'),
            variant: FButtonVariant.outline,
            onPress: isSubmitting ? null : () => linkWechat(),
            child: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: FCircularProgress(),
                  )
                : Text(l10n.authIdentityLinkWechatAction),
          ),
      ],
    );
  }
}

/// 绑定身份卡片
class LinkedIdentityTile extends StatelessWidget {
  const LinkedIdentityTile({
    super.key,
    required this.user,
    required this.identity,
    required this.isSubmitting,
    required this.onUnlink,
  });

  final AuthUser user;
  final AuthLinkedIdentity identity;
  final bool isSubmitting;
  final Future<void> Function() onUnlink;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canUnlink = user.hasPassword || user.linkedIdentities.length > 1;
    final typography = context.theme.typography;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: SemanticColor.neutral.border(context)),
        borderRadius: context.theme.style.borderRadius.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Row(
          children: [
            Icon(
              SemanticIcons.actionExternalLink,
              color: SemanticColor.primary.solid(context),
              size: 20,
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    identityProviderLabel(identity.provider, l10n),
                    style: typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    [
                      identity.email ?? l10n.authLinkedIdentityEmailMissing,
                      l10n.authLinkedIdentityLinkedAt(
                        formatDate(identity.linkedAt),
                      ),
                    ].join(' · '),
                    style: typography.body.xs.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                ],
              ),
            ),
            FButton(
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              onPress: canUnlink && !isSubmitting ? () => onUnlink() : null,
              child: Text(
                canUnlink
                    ? l10n.authIdentityUnlinkAction
                    : l10n.authIdentityUnlinkDisabledAction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 获取身份提供商标签
String identityProviderLabel(String provider, AppLocalizations l10n) =>
    switch (provider) {
      'wechat_web' => l10n.authIdentityProviderWechatWeb,
      'wechat_mobile' => l10n.authIdentityProviderWechatMobile,
      _ => provider,
    };

/// 格式化日期
String formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

/// 格式化日期时间
String formatDateTime(DateTime value) {
  final local = value.toLocal();
  return '${formatDate(local)} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

/// 通用组件：章节列容器
class _SectionColumn extends StatelessWidget {
  const _SectionColumn({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    header: true,
    label: title,
    // 账号页移除内层 FCard 后，各模块与外层 AuthShell 面板共用同一层背景，
    // 用语义容器 + header 为读屏用户划分模块边界（review 2026-09-06 §5）。
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.theme.typography.body.md.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Spacing.xl),
        for (final child in children) ...[
          child,
          if (child != children.last) const SizedBox(height: Spacing.lg),
        ],
      ],
    ),
  );
}

/// 通用组件：信息行
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Row(
      children: [
        Icon(icon, size: 18, color: SemanticColor.neutral.solid(context)),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Text(
            label,
            style: typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ),
        const SizedBox(width: Spacing.lg),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: typography.body.xs.copyWith(color: colors.foreground),
          ),
        ),
      ],
    );
  }
}

/// 通用组件：弱化文本
class _MutedText extends StatelessWidget {
  const _MutedText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.theme.typography.body.xs.copyWith(
        color: SemanticColor.neutral.solid(context),
      ),
    );
  }
}
