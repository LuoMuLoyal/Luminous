import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/skeleton.dart';

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
        const SizedBox(width: AppSpacingTokens.level3),
        SizedBox(
          width: 148,
          child: Padding(
            padding: const EdgeInsets.only(top: 26),
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

/// Mine 编辑表单的加载骨架屏，用于 profile/allergy/condition/current_medicine 编辑页。
class MineEditFormLoading extends StatelessWidget {
  const MineEditFormLoading({
    super.key,
    this.blockHeights = const [56, 56, 56, 56, 96, 56],
  });

  final List<double> blockHeights;

  @override
  Widget build(BuildContext context) {
    return AppInlineSkeletonSection(
      children: [
        for (final h in blockHeights) AppInlineSkeletonBlock(height: h),
      ],
    );
  }
}

/// 设置子页面的分组标题文本。
class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.level2),
      child: Text(
        label,
        style: AppTypographyToken.level3
            .body(context)
            .copyWith(
              color: colors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// 底部弹窗的拖拽手柄。
class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacingTokens.level3),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: colors.border,
            borderRadius: BorderRadius.circular(AppRadiusTokens.levelFull),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.level4),
      ],
    );
  }
}

/// 柔和色调的图标容器，用于 mine 模块的归档/状态行。
class SoftIcon extends StatelessWidget {
  const SoftIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44.0,
    this.iconSize = 22.0,
  });

  final IconData icon;
  final AppColors color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final resolvedColor = color.resolve(colors);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(icon, color: resolvedColor, size: iconSize),
      ),
    );
  }
}

/// 带 Tooltip 的图标按钮，用于页面顶栏的紧凑操作入口。
class IconActionButton extends StatelessWidget {
  const IconActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FTooltip(
      tipBuilder: (context, controller) => Text(tooltip),
      child: FButton.icon(
        onPress: onTap,
        variant: FButtonVariant.ghost,
        size: FButtonSizeVariant.sm,
        child: Icon(icon, size: AppSpacingTokens.level5),
      ),
    );
  }
}
