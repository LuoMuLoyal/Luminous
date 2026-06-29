import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
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
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacingTokens.xs),
        ],
        Expanded(
          child: Text(
            title,
            style: (compact ? typography.bodyMdStrong : typography.displaySm)
                .copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacingTokens.sm),
          trailing!,
        ],
      ],
    );
  }
}
