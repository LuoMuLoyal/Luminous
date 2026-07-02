import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/common/app_text_action.dart';
import 'package:luminous/core/widgets/common/app_section_header.dart';
import 'package:luminous/core/design/app_design.dart';

class TodaySection extends StatelessWidget {
  const TodaySection({
    super.key,
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: title,
          trailing: actionLabel == null
              ? null
              : AppTextAction(label: actionLabel!, onTap: onAction ?? () {}),
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        child,
      ],
    );
  }
}
