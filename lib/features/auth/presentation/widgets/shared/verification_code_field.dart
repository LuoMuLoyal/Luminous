import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// 验证码输入 + 发送按钮的行布局，用于登录、注册、忘记密码、修改邮箱等页面。
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
        const SizedBox(width: Spacing.level3),
        Padding(
          padding: const EdgeInsets.only(top: 26),
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
                  : Text(buttonLabel),
            ),
          ),
        ),
      ],
    );
  }
}
