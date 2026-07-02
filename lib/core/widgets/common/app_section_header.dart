import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.compact = false,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacingTokens.level2),
        ],
        Expanded(
          child: Text(
            title,
            style: (compact ? textTheme.titleMedium : textTheme.headlineSmall)
                ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacingTokens.level3),
          trailing!,
        ],
      ],
    );
  }
}
