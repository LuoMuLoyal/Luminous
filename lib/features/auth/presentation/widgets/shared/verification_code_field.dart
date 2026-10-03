import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// Verification code input + send button row layout, used in login, register,
/// forgot password, and change email pages.
class VerificationCodeField extends StatelessWidget {
  const VerificationCodeField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    required this.buttonLabel,
    required this.isLoading,
    required this.onSendCode,
    this.fieldKey,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String buttonLabel;
  final bool isLoading;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onSendCode;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FTextFormField(
            key: fieldKey,
            control: FTextFieldControl.managed(controller: controller),
            label: Text(label),
            hint: hint,
            keyboardType: TextInputType.number,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator,
          ),
        ),
        const SizedBox(width: Spacing.md),
        Padding(
          padding: const EdgeInsets.only(top: 26),
          // 发码按钮撑满固有宽度会把左侧输入框挤窄:给宽度上限(仍在
          // IntrinsicWidth 内,标签换文时不跳动),超长文案由标签省略兜住。
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: IntrinsicWidth(
              child: FButton(
                variant: FButtonVariant.outline,
                onPress: isLoading ? null : onSendCode,
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: FCircularProgress(),
                      )
                    : Flexible(
                        child: Text(
                          buttonLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
