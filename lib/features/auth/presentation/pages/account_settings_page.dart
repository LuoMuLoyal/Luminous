import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_account_provider.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({
    super.key,
    this.enableFormAnimation = true,
    this.wechatCode,
    this.wechatState,
  });

  final bool enableFormAnimation;
  final String? wechatCode;
  final String? wechatState;

  @override
  ConsumerState<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _avatarController;
  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _deletePasswordController;
  String? _formUserId;
  bool _wechatIdentityLinkStarted = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authSessionProvider).user;
    _emailController = TextEditingController(text: user?.email ?? '');
    _nicknameController = TextEditingController(text: user?.nickname ?? '');
    _avatarController = TextEditingController(text: user?.avatar ?? '');
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _deletePasswordController = TextEditingController();
    _formUserId = user?.id;

    if ((widget.wechatCode?.isNotEmpty ?? false) &&
        (widget.wechatState?.isNotEmpty ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _maybeCompleteWechatIdentityLink();
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nicknameController.dispose();
    _avatarController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _deletePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    final accountState = ref.watch(authAccountProvider);
    final accountNotifier = ref.read(authAccountProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final user = session.user;
    final resolvingSession = session.isLoading;
    final signedOut = !session.canAccessProtectedData || user == null;
    final success = accountState.successMessage?.isNotEmpty == true
        ? accountState.successMessage
        : null;

    _syncControllersFromUser(user);

    if ((widget.wechatCode?.isNotEmpty ?? false) &&
        (widget.wechatState?.isNotEmpty ?? false) &&
        !_wechatIdentityLinkStarted &&
        !session.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _maybeCompleteWechatIdentityLink();
        }
      });
    }

    return AuthShell(
      title: l10n.authAccountSettingsFormTitle,
      leading: BackButton(onPressed: () => context.pop()),
      centerTitle: true,
      enableFormAnimation: widget.enableFormAnimation,
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (resolvingSession) ...[
            const _AccountSettingsLoading(),
          ] else if (signedOut) ...[
            AuthStatusMessage(error: l10n.authNotSignedIn),
            const SizedBox(height: AppSpacingTokens.lg),
            AuthPrimaryButton(
              label: l10n.authGoLogin,
              onPressed: () => context.go('/login'),
            ),
          ] else ...[
            AuthSectionCard(
              child: _AccountStatusSection(user: user, l10n: l10n),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            AuthSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.authProfileSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacingTokens.lg),
                  AuthTextField(
                    controller: _nicknameController,
                    label: l10n.authNicknameLabel,
                    hint: l10n.authNicknameHint,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  AuthTextField(
                    controller: _avatarController,
                    label: l10n.authAvatarLabel,
                    hint: l10n.authAvatarHint,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  AuthPrimaryButton(
                    label: l10n.authProfileSaveAction,
                    isLoading: accountState.isSubmitting,
                    onPressed: () async {
                      final ok = await accountNotifier.updateProfile(
                        nickname: _nicknameController.text,
                        avatar: _avatarController.text,
                      );
                      if (ok && context.mounted) {
                        await AppToast.show(
                          context,
                          l10n.authProfileSaveSuccess,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            AuthSectionCard(
              child: _EmailSection(
                user: user,
                emailController: _emailController,
                onChangeEmail: () => context.push('/account/change-email'),
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            AuthSectionCard(
              child: _LinkedIdentitiesSection(
                user: user,
                isSubmitting: accountState.isSubmitting,
                onLinkWechat: () => _startWechatIdentityLink(context, l10n),
                onUnlink: (identity) async {
                  final confirmed = await _confirmUnlinkIdentity(
                    context,
                    identity,
                    l10n,
                  );
                  if (!confirmed || !context.mounted) {
                    return;
                  }
                  final ok = await accountNotifier.unlinkIdentity(
                    identityId: identity.id,
                  );
                  if (ok && context.mounted) {
                    await AppToast.show(
                      context,
                      l10n.authIdentityUnlinkSuccess,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            AuthSectionCard(
              child: _PasswordSection(
                user: user,
                oldPasswordController: _oldPasswordController,
                newPasswordController: _newPasswordController,
                isSubmitting: accountState.isSubmitting,
                onChangePassword: () async {
                  final currentContext = context;
                  final router = GoRouter.of(currentContext);
                  if (_oldPasswordController.text.trim().isEmpty) {
                    await AppToast.show(
                      currentContext,
                      l10n.authCurrentPasswordRequiredToast,
                    );
                    return;
                  }
                  if (_newPasswordController.text.trim().isEmpty) {
                    await AppToast.show(
                      currentContext,
                      l10n.authNewPasswordRequiredToast,
                    );
                    return;
                  }
                  final ok = await accountNotifier.changePassword(
                    oldPassword: _oldPasswordController.text,
                    newPassword: _newPasswordController.text,
                  );
                  if (!ok || !currentContext.mounted) {
                    return;
                  }
                  await AppToast.show(
                    currentContext,
                    l10n.authChangePasswordSuccess,
                  );
                  if (!currentContext.mounted) {
                    return;
                  }
                  router.go('/login');
                },
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            AuthSectionCard(
              child: _DeleteAccountSection(
                user: user,
                deletePasswordController: _deletePasswordController,
                isSubmitting: accountState.isSubmitting,
                onDelete: () async {
                  final currentContext = context;
                  final router = GoRouter.of(currentContext);
                  if (_deletePasswordController.text.trim().isEmpty) {
                    await AppToast.show(
                      currentContext,
                      l10n.authCurrentPasswordRequiredToast,
                    );
                    return;
                  }
                  final ok = await accountNotifier.deleteAccount(
                    password: _deletePasswordController.text,
                  );
                  if (!ok || !currentContext.mounted) {
                    return;
                  }
                  await AppToast.show(
                    currentContext,
                    l10n.authDeleteAccountSuccess,
                  );
                  if (!currentContext.mounted) {
                    return;
                  }
                  router.go('/login');
                },
              ),
            ),
            if ((accountState.errorMessage?.isNotEmpty ?? false) ||
                success != null) ...[
              const SizedBox(height: AppSpacingTokens.md),
              AuthStatusMessage(
                error: accountState.errorMessage,
                success: success,
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _syncControllersFromUser(AuthUser? user) {
    if (user == null || _formUserId == user.id) {
      return;
    }

    _formUserId = user.id;
    _emailController.text = user.email ?? '';
    _nicknameController.text = user.nickname ?? '';
    _avatarController.text = user.avatar ?? '';
  }

  void _maybeCompleteWechatIdentityLink() {
    if (_wechatIdentityLinkStarted ||
        widget.wechatCode?.isNotEmpty != true ||
        widget.wechatState?.isNotEmpty != true) {
      return;
    }

    final session = ref.read(authSessionProvider);
    if (session.isLoading) {
      return;
    }

    _wechatIdentityLinkStarted = true;
    if (!session.canAccessProtectedData) {
      context.go('/login');
      return;
    }

    unawaited(
      _completeWechatIdentityLink(widget.wechatCode!, widget.wechatState!),
    );
  }

  Future<void> _completeWechatIdentityLink(String code, String state) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await ref
        .read(authAccountProvider.notifier)
        .completeWechatWebIdentityLink(code: code, state: state);
    if (!mounted) {
      return;
    }
    if (ok) {
      await AppToast.show(context, l10n.authIdentityLinkSuccess);
      if (mounted) {
        context.go('/account');
      }
    }
  }
}

class _AccountSettingsLoading extends StatelessWidget {
  const _AccountSettingsLoading();

  @override
  Widget build(BuildContext context) {
    return const AppInlineSkeleton(
      children: [
        AppInlineSkeletonBlock(height: 96),
        AppInlineSkeletonBlock(height: 132),
        AppInlineSkeletonBlock(height: 96),
        AppInlineSkeletonBlock(height: 116),
      ],
    );
  }
}

Future<void> _startWechatIdentityLink(
  BuildContext context,
  AppLocalizations l10n,
) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final result = await container
      .read(authAccountProvider.notifier)
      .startWechatIdentityLink(webCallbackUri: _webWechatLinkCallbackUri());
  if (!context.mounted || result == null) {
    return;
  }

  switch (result) {
    case WechatIdentityLinkResult.completed:
      await AppToast.show(context, l10n.authIdentityLinkSuccess);
      return;
    case WechatIdentityLinkResult.opened:
      await AppToast.show(context, l10n.authWechatAuthorizeOpened);
      return;
    case WechatIdentityLinkResult.unsupported:
      await AppToast.show(context, l10n.authIdentityLinkUnsupported);
      return;
  }
}

String? _webWechatLinkCallbackUri() {
  if (!kIsWeb) {
    return null;
  }

  final base = Uri.base;
  return Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
    path: '/account/oauth/wechat',
  ).toString();
}

Future<bool> _confirmUnlinkIdentity(
  BuildContext context,
  AuthLinkedIdentity identity,
  AppLocalizations l10n,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.authIdentityUnlinkConfirmTitle),
      content: Text(
        l10n.authIdentityUnlinkConfirmMessage(
          _identityProviderLabel(identity.provider, l10n),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.authCancelAction),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.authIdentityUnlinkAction),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _AccountStatusSection extends StatelessWidget {
  const _AccountStatusSection({required this.user, required this.l10n});

  final AuthUser user;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _SectionColumn(
      title: l10n.authAccountOverviewTitle,
      children: [
        _InfoRow(
          icon: Icons.mail_outline_rounded,
          label: l10n.authAccountOverviewEmail,
          value: user.email ?? l10n.authEmailMissing,
        ),
        _InfoRow(
          icon: user.emailVerified
              ? Icons.mark_email_read_outlined
              : Icons.mark_email_unread_outlined,
          label: l10n.authAccountOverviewEmailVerified,
          value: user.emailVerifiedAt == null
              ? l10n.authEmailUnverifiedStatus
              : l10n.authEmailVerifiedAt(
                  _formatDateTime(user.emailVerifiedAt!),
                ),
        ),
        _InfoRow(
          icon: user.hasPassword
              ? Icons.lock_outline_rounded
              : Icons.lock_open_outlined,
          label: l10n.authAccountOverviewPassword,
          value: user.hasPassword
              ? l10n.authPasswordSetStatus
              : l10n.authPasswordUnsetStatus,
        ),
        _InfoRow(
          icon: Icons.schedule_rounded,
          label: l10n.authAccountOverviewLastLogin,
          value: user.lastLoginAt == null
              ? l10n.authLastLoginUnknown
              : _formatDateTime(user.lastLoginAt!),
        ),
      ],
    );
  }
}

class _EmailSection extends StatelessWidget {
  const _EmailSection({
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

class _LinkedIdentitiesSection extends StatelessWidget {
  const _LinkedIdentitiesSection({
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
              : const Icon(Icons.add_link_rounded, size: 18),
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
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = _typography(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: surface.hairline),
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Row(
          children: [
            Icon(Icons.link_rounded, color: surface.link, size: 20),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _identityProviderLabel(identity.provider, l10n),
                    style: typography.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    [
                      identity.email ?? l10n.authLinkedIdentityEmailMissing,
                      l10n.authLinkedIdentityLinkedAt(
                        _formatDate(identity.linkedAt),
                      ),
                    ].join(' · '),
                    style: typography.caption.copyWith(color: surface.mute),
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

class _PasswordSection extends StatelessWidget {
  const _PasswordSection({
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

class _DeleteAccountSection extends StatelessWidget {
  const _DeleteAccountSection({
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacingTokens.lg),
        for (final child in children) ...[
          child,
          if (child != children.last)
            const SizedBox(height: AppSpacingTokens.md),
        ],
      ],
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
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = _typography(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: surface.mute),
        const SizedBox(width: AppSpacingTokens.sm),
        Expanded(
          child: Text(
            label,
            style: typography.bodySm.copyWith(color: surface.mute),
          ),
        ),
        const SizedBox(width: AppSpacingTokens.md),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: typography.bodySm.copyWith(color: surface.body),
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
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    return Text(
      text,
      style: _typography(context).bodySm.copyWith(color: surface.mute),
    );
  }
}

AppTypographyScale _typography(BuildContext context) {
  final theme = Theme.of(context);
  return AppTypographyTokens.mobile(theme.colorScheme.onSurface);
}

String _identityProviderLabel(String provider, AppLocalizations l10n) {
  return switch (provider) {
    'wechat_web' => l10n.authIdentityProviderWechatWeb,
    'wechat_mobile' => l10n.authIdentityProviderWechatMobile,
    _ => provider,
  };
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${_formatDate(local)} $hour:$minute';
}
