import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/verification_code_field.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 密码修改部分 - 用于设置或修改账号密码
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
  State<PasswordSection> createState() => PasswordSectionState();
}

class PasswordSectionState extends State<PasswordSection> {
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
                const SizedBox(height: Spacing.lg),
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

/// 删除账号部分 - 用于永久删除用户账号
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
  State<DeleteAccountSection> createState() => DeleteAccountSectionState();
}

class DeleteAccountSectionState extends State<DeleteAccountSection> {
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

    return DangerZoneSection(
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
            onPress: () => context.push('${Routes.legal}/account-cancellation'),
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

/// 危险区域部分 - 用于包裹高风险操作
class DangerZoneSection extends StatelessWidget {
  const DangerZoneSection({
    super.key,
    required this.title,
    required this.dangerLabel,
    required this.children,
  });

  final String title;
  final String dangerLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: SemanticColor.destructive.borderStrong(context),
        ),
        borderRadius: context.theme.style.borderRadius.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  SemanticIcons.statusWarning,
                  size: 16,
                  color: SemanticColor.destructive.solid(context),
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  dangerLabel,
                  style: typography.body.xs.copyWith(
                    color: SemanticColor.destructive.solid(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              title,
              style: typography.body.md.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: Spacing.xl),
            for (final child in children) ...[
              child,
              if (child != children.last) const SizedBox(height: Spacing.lg),
            ],
          ],
        ),
      ),
    );
  }
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
    // 账号页移除内层 FCard 后，各模块与认证页标准骨架（PageScaffold）共用同一层
    // 背景，用语义容器 + header 为读屏用户划分模块边界（review 2026-09-06 §5）。
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
