import 'package:flutter/material.dart';
import 'package:luminous/constants/app_ui_constants.dart';
import 'package:luminous/shared/design_tokens/design_tokens.dart';

/// 今日页区块标题行。
///
/// 左侧标题文字 + 右侧可选操作按钮，用于各功能区块的头部。
class TodaySectionHeader extends StatelessWidget {
  const TodaySectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onTrailingTap,
    this.titleFontSize = 15,
  });

  /// 标题文字。
  final String title;

  /// 右侧操作文字（如 "查看"、"换一换"）。
  final String? trailing;

  /// 右侧操作点击回调。
  final VoidCallback? onTrailingTap;

  /// 标题字号。
  final double titleFontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark
        ? const Color(0xFFF2F6F2)
        : const Color(0xFF222222);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              trailing!,
              style: TextStyle(
                fontSize: AppTypography.bodySmall,
                fontWeight: FontWeight.w500,
                color: AppUiConstants.TEXT_MUTED,
              ),
            ),
          ),
      ],
    );
  }
}
