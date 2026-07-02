import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AccountSettingsLoading extends StatelessWidget {
  const AccountSettingsLoading({super.key});

  @override
  Widget build(BuildContext context) => const AppInlineSkeleton(
    children: [
      AppInlineSkeletonBlock(height: 96),
      AppInlineSkeletonBlock(height: 132),
      AppInlineSkeletonBlock(height: 96),
      AppInlineSkeletonBlock(height: 116),
    ],
  );
}

class AccountStatusSection extends StatelessWidget {
  const AccountStatusSection({
    super.key,
    required this.user,
    required this.l10n,
  });

  final AuthUser user;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => _SectionColumn(
    title: l10n.authAccountOverviewTitle,
    children: [
      _InfoRow(
        icon: FLucideIcons.mail,
        label: l10n.authAccountOverviewEmail,
        value: user.email ?? l10n.authEmailMissing,
      ),
      _InfoRow(
        icon: user.emailVerified
            ? FLucideIcons.mailCheck
            : FLucideIcons.mailWarning,
        label: l10n.authAccountOverviewEmailVerified,
        value: user.emailVerifiedAt == null
            ? l10n.authEmailUnverifiedStatus
            : l10n.authEmailVerifiedAt(formatDateTime(user.emailVerifiedAt!)),
      ),
      _InfoRow(
        icon: user.hasPassword ? FLucideIcons.lock : FLucideIcons.lockOpen,
        label: l10n.authAccountOverviewPassword,
        value: user.hasPassword
            ? l10n.authPasswordSetStatus
            : l10n.authPasswordUnsetStatus,
      ),
      _InfoRow(
        icon: FLucideIcons.clock3,
        label: l10n.authAccountOverviewLastLogin,
        value: user.lastLoginAt == null
            ? l10n.authLastLoginUnknown
            : formatDateTime(user.lastLoginAt!),
      ),
    ],
  );
}

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
        AuthTextField(
          controller: emailController,
          label: l10n.authEmailLabel,
          enabled: false,
        ),
        AuthPrimaryButton(
          label: user.email == null
              ? l10n.authEmailAddAction
              : l10n.authEmailChangeAction,
          onPressed: onChangeEmail,
        ),
      ],
    );
  }
}

class LinkedIdentitiesSection extends StatelessWidget {
  const LinkedIdentitiesSection({
    super.key,
    required this.user,
    required this.isSubmitting,
    required this.onLinkWechat,
    required this.onUnlink,
  });

  final AuthUser user;
  final bool isSubmitting;
  final Future<void> Function() onLinkWechat;
  final Future<void> Function(AuthLinkedIdentity identity) onUnlink;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SectionColumn(
      title: l10n.authLinkedIdentitiesSectionTitle,
      children: [
        if (user.linkedIdentities.isEmpty)
          _MutedText(l10n.authLinkedIdentityNone)
        else
          ...user.linkedIdentities.map(
            (identity) => _LinkedIdentityTile(
              user: user,
              identity: identity,
              isSubmitting: isSubmitting,
              onUnlink: () => onUnlink(identity),
            ),
          ),
        OutlinedButton.icon(
          key: const Key('wechat-identity-link-button'),
          onPressed: isSubmitting ? null : onLinkWechat,
          icon: isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(FLucideIcons.link, size: 18),
          label: Text(l10n.authIdentityLinkWechatAction),
        ),
      ],
    );
  }
}

class _LinkedIdentityTile extends StatelessWidget {
  const _LinkedIdentityTile({
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
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Row(
          children: [
            Icon(FLucideIcons.link, color: colors.primary, size: 20),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    identityProviderLabel(identity.provider, l10n),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    [
                      identity.email ?? l10n.authLinkedIdentityEmailMissing,
                      l10n.authLinkedIdentityLinkedAt(
                        formatDate(identity.linkedAt),
                      ),
                    ].join(' · '),
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: canUnlink && !isSubmitting ? onUnlink : null,
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

class PasswordSection extends StatelessWidget {
  const PasswordSection({
    super.key,
    required this.user,
    required this.oldPasswordController,
    required this.newPasswordController,
    required this.isSubmitting,
    required this.onChangePassword,
  });

  final AuthUser user;
  final TextEditingController oldPasswordController;
  final TextEditingController newPasswordController;
  final bool isSubmitting;
  final Future<void> Function() onChangePassword;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SectionColumn(
      title: l10n.authPasswordSectionTitle,
      children: [
        if (!user.hasPassword)
          _MutedText(l10n.authPasswordUnsetManagementHint)
        else ...[
          AuthTextField(
            controller: oldPasswordController,
            label: l10n.authCurrentPasswordLabel,
            hint: l10n.authPasswordHint,
            obscureText: true,
          ),
          AuthTextField(
            controller: newPasswordController,
            label: l10n.authNewPasswordLabel,
            hint: l10n.authPasswordHint,
            obscureText: true,
          ),
          AuthPrimaryButton(
            label: l10n.authChangePasswordAction,
            isLoading: isSubmitting,
            onPressed: onChangePassword,
          ),
        ],
      ],
    );
  }
}

class DeleteAccountSection extends StatelessWidget {
  const DeleteAccountSection({
    super.key,
    required this.user,
    required this.deletePasswordController,
    required this.isSubmitting,
    required this.onDelete,
  });

  final AuthUser user;
  final TextEditingController deletePasswordController;
  final bool isSubmitting;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SectionColumn(
      title: l10n.authDeleteAccountSectionTitle,
      children: [
        if (!user.hasPassword)
          _MutedText(l10n.authDeleteAccountPasswordRequiredHint)
        else ...[
          AuthTextField(
            controller: deletePasswordController,
            label: l10n.authCurrentPasswordLabel,
            hint: l10n.authDeleteAccountHint,
            obscureText: true,
          ),
          AuthPrimaryButton(
            label: l10n.authDeleteAccountAction,
            isLoading: isSubmitting,
            onPressed: onDelete,
          ),
        ],
      ],
    );
  }
}

class _SectionColumn extends StatelessWidget {
  const _SectionColumn({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: AppSpacingTokens.lg),
      for (final child in children) ...[
        child,
        if (child != children.last) const SizedBox(height: AppSpacingTokens.md),
      ],
    ],
  );
}

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
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.mutedForeground),
        const SizedBox(width: AppSpacingTokens.sm),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: colors.mutedForeground),
          ),
        ),
        const SizedBox(width: AppSpacingTokens.md),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(color: colors.foreground),
          ),
        ),
      ],
    );
  }
}

class _MutedText extends StatelessWidget {
  const _MutedText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: colors.mutedForeground),
    );
  }
}

String identityProviderLabel(String provider, AppLocalizations l10n) =>
    switch (provider) {
      'wechat_web' => l10n.authIdentityProviderWechatWeb,
      'wechat_mobile' => l10n.authIdentityProviderWechatMobile,
      _ => provider,
    };

String formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

String formatDateTime(DateTime value) {
  final local = value.toLocal();
  return '${formatDate(local)} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}
