import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/today/presentation/widgets/today_components.dart';

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
        TodaySectionHeader(
          title: title,
          trailing: actionLabel == null
              ? null
              : TodayTextAction(label: actionLabel!, onTap: onAction ?? () {}),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        child,
      ],
    );
  }
}
