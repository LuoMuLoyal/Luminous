import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/control/back_button.dart';
import 'package:luminous/features/auth/presentation/pages/account_manage_helpers.dart';
import 'package:luminous/features/auth/presentation/pages/account_manage_sections.dart';
import 'package:luminous/features/auth/presentation/providers/account.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AccountManagePage extends HookConsumerWidget {
  const AccountManagePage({super.key, this.wechatCode, this.wechatState});
  final String? wechatCode;
  final String? wechatState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final accountState = ref.watch(authAccountProvider);
    final accountNotifier = ref.read(authAccountProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final user = session.user;
    final resolvingSession = session.isLoading;
    final signedOut = !session.canAccessProtectedData || user == null;

    final emailController = useTextEditingController(text: user?.email ?? '');
    final nicknameController = useTextEditingController(
      text: user?.nickname ?? '',
    );
    final oldPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final deletePasswordController = useTextEditingController();
    final deleteCodeController = useTextEditingController();
    final formUserId = useRef<String?>(null);
    final wechatIdentityLinkStarted = useRef(false);

    // Sync controllers when user changes
    useEffect(() {
      if (user == null || formUserId.value == user.id) return null;
      formUserId.value = user.id;
      emailController.text = user.email ?? '';
      nicknameController.text = user.nickname ?? '';
      return null;
    }, [user?.id]);

    Future<void> completeWechatIdentityLink(String code, String state) async {
      final ok = await ref
          .read(authAccountProvider.notifier)
          .completeWechatWebIdentityLink(code: code, state: state);
      if (!context.mounted) return;
      if (ok) {
        await Toast.show(context, l10n.authIdentityLinkSuccess);
        if (context.mounted) context.go(Routes.account);
      }
    }

    void maybeCompleteWechatIdentityLink() {
      if (wechatIdentityLinkStarted.value ||
          wechatCode?.isNotEmpty != true ||
          wechatState?.isNotEmpty != true) {
        return;
      }
      final s = ref.read(authSessionProvider);
      if (s.isLoading) return;
      wechatIdentityLinkStarted.value = true;
      if (!s.canAccessProtectedData) {
        context.go(loginRouteForReturnTo('/account'));
        return;
      }
      unawaited(completeWechatIdentityLink(wechatCode!, wechatState!));
    }

    // Handle OAuth callback on first build
    useEffect(() {
      if ((wechatCode?.isNotEmpty ?? false) &&
          (wechatState?.isNotEmpty ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          maybeCompleteWechatIdentityLink();
        });
      }
      return null;
    }, []);

    // Handle OAuth in subsequent builds
    if ((wechatCode?.isNotEmpty ?? false) &&
        (wechatState?.isNotEmpty ?? false) &&
        !wechatIdentityLinkStarted.value &&
        !session.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        maybeCompleteWechatIdentityLink();
      });
    }

    return AuthShell(
      title: l10n.authAccountManageFormTitle,
      leading: const AppBackButton(),
      centerTitle: true,
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (resolvingSession) ...[
            const AccountManageLoading(),
          ] else if (signedOut) ...[
            AuthRequiredDialogGate(
              onLogin: () =>
                  context.push(loginRouteForCurrentLocation(context)),
            ),
          ] else ...[
            // 顶部概要卡片：头像 + 昵称 + 邮箱
            AccountSummaryCard(user: user),
            const SizedBox(height: Spacing.xl2),

            // 账号管理列表
            AccountManageSection(
              user: user,
              l10n: l10n,
              accountState: accountState,
              accountNotifier: accountNotifier,
              emailController: emailController,
              nicknameController: nicknameController,
              oldPasswordController: oldPasswordController,
              newPasswordController: newPasswordController,
              deletePasswordController: deletePasswordController,
              deleteCodeController: deleteCodeController,
              onVerifyEmail: () =>
                  verifyEmailFlow(context, l10n, ref, user.email!),
              onChangeEmail: () => context.push(Routes.accountChangeEmail),
              onManageSessions: () => context.push(Routes.accountSessions),
              onManageSecurityCenter: () =>
                  context.push(Routes.accountSecurityCenter),
            ),
            const SizedBox(height: Spacing.xl2),

            // 底部服务入口
            const SupportLinksSection(),
          ],
        ],
      ),
    );
  }
}
