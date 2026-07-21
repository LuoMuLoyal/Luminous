import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
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
        FButton(
          key: const Key('wechat-identity-link-button'),
          variant: FButtonVariant.outline,
          onPress: isSubmitting ? null : () => onLinkWechat(),
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

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(RadiusTokens.level2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Row(
          children: [
            Icon(FLucideIcons.link, color: colors.primary, size: 20),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    identityProviderLabel(identity.provider, l10n),
                    style: TypographyToken.level4
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    [
                      identity.email ?? l10n.authLinkedIdentityEmailMissing,
                      l10n.authLinkedIdentityLinkedAt(
                        formatDate(identity.linkedAt),
                      ),
                    ].join(' · '),
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
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

class PasswordSection extends StatefulWidget {
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
  State<PasswordSection> createState() => _PasswordSectionState();
}

class _PasswordSectionState extends State<PasswordSection> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SectionColumn(
      title: l10n.authPasswordSectionTitle,
      children: [
        if (!widget.user.hasPassword)
          _MutedText(l10n.authPasswordUnsetManagementHint)
        else ...[
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FTextFormField.password(
                  control: FTextFieldControl.managed(
                    controller: widget.oldPasswordController,
                  ),
                  label: Text(l10n.authCurrentPasswordLabel),
                  hint: l10n.authPasswordHint,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? l10n.authCurrentPasswordRequiredToast
                      : null,
                ),
                const SizedBox(height: Spacing.level4),
                FTextFormField.password(
                  control: FTextFieldControl.managed(
                    controller: widget.newPasswordController,
                  ),
                  label: Text(l10n.authNewPasswordLabel),
                  hint: l10n.authPasswordHint,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? l10n.authNewPasswordRequiredToast
                      : null,
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FButton(
              onPress: widget.isSubmitting
                  ? null
                  : () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await widget.onChangePassword();
                      }
                    },
              child: widget.isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: FCircularProgress(),
                    )
                  : Text(l10n.authChangePasswordAction),
            ),
          ),
        ],
      ],
    );
  }
}

class DeleteAccountSection extends StatefulWidget {
  const DeleteAccountSection({
    super.key,
    required this.user,
    required this.deletePasswordController,
    required this.deleteCodeController,
    required this.isSubmitting,
    required this.isSendingCode,
    required this.cooldownSeconds,
    required this.onDelete,
    required this.onSendCode,
  });

  final AuthUser user;
  final TextEditingController deletePasswordController;
  final TextEditingController deleteCodeController;
  final bool isSubmitting;
  final bool isSendingCode;
  final int? cooldownSeconds;
  final Future<void> Function() onDelete;
  final Future<void> Function() onSendCode;

  @override
  State<DeleteAccountSection> createState() => _DeleteAccountSectionState();
}

class _DeleteAccountSectionState extends State<DeleteAccountSection> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // OAuth-only user with no verified email — cannot delete from here.
    if (!widget.user.hasPassword && !widget.user.emailVerified) {
      return _SectionColumn(
        title: l10n.authDeleteAccountSectionTitle,
        children: [_MutedText(l10n.authDeleteAccountEmailRequiredHint)],
      );
    }

    return _DangerZoneSection(
      title: l10n.authDeleteAccountSectionTitle,
      dangerLabel: l10n.authDeleteAccountDangerZoneLabel,
      children: [
        _MutedText(l10n.authDeleteAccountPolicyHint),
        Align(
          alignment: Alignment.centerLeft,
          child: FButton(
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.sm,
            mainAxisSize: MainAxisSize.min,
            onPress: () =>
                context.push('${AppRoutes.legal}/account-cancellation'),
            child: Text(l10n.authDeleteAccountPolicyAction),
          ),
        ),
        Form(
          key: _formKey,
          child: widget.user.hasPassword
              ? FTextFormField.password(
                  control: FTextFieldControl.managed(
                    controller: widget.deletePasswordController,
                  ),
                  label: Text(l10n.authCurrentPasswordLabel),
                  hint: l10n.authDeleteAccountHint,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? l10n.authCurrentPasswordRequiredToast
                      : null,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MutedText(l10n.authDeleteAccountCodeHint),
                    VerificationCodeField(
                      controller: widget.deleteCodeController,
                      label: l10n.authCodeLabel,
                      hint: l10n.authCodeLabel,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? l10n.authCodeRequiredError
                          : null,
                      buttonLabel: widget.cooldownSeconds == null
                          ? l10n.authSendCode
                          : l10n.authSendCodeAgain(widget.cooldownSeconds!),
                      isLoading: widget.isSendingCode,
                      onSendCode:
                          widget.isSendingCode ||
                              (widget.cooldownSeconds != null &&
                                  widget.cooldownSeconds! > 0)
                          ? null
                          : () => widget.onSendCode(),
                    ),
                  ],
                ),
        ),
        SizedBox(
          width: double.infinity,
          child: FButton(
            variant: FButtonVariant.destructive,
            onPress: widget.isSubmitting
                ? null
                : () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      await widget.onDelete();
                    }
                  },
            child: widget.isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: FCircularProgress(),
                  )
                : Text(l10n.authDeleteAccountAction),
          ),
        ),
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
      Text(
        title,
        style: TypographyToken.level5
            .body(context)
            .copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: Spacing.level5),
      for (final child in children) ...[
        child,
        if (child != children.last) const SizedBox(height: Spacing.level4),
      ],
    ],
  );
}

class _DangerZoneSection extends StatelessWidget {
  const _DangerZoneSection({
    required this.title,
    required this.dangerLabel,
    required this.children,
  });

  final String title;
  final String dangerLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.destructive.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(RadiusTokens.level3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FLucideIcons.triangleAlert,
                  size: 16,
                  color: colors.destructive,
                ),
                const SizedBox(width: Spacing.level2),
                Text(
                  dangerLabel,
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(
                        color: colors.destructive,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              title,
              style: TypographyToken.level5
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: Spacing.level5),
            for (final child in children) ...[
              child,
              if (child != children.last)
                const SizedBox(height: Spacing.level4),
            ],
          ],
        ),
      ),
    );
  }
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

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.mutedForeground),
        const SizedBox(width: Spacing.level3),
        Expanded(
          child: Text(
            label,
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: colors.mutedForeground),
          ),
        ),
        const SizedBox(width: Spacing.level4),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: colors.foreground),
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
      style: TypographyToken.level3
          .body(context)
          .copyWith(color: colors.mutedForeground),
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
