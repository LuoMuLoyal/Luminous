import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/common/app_icon_badge.dart';
import 'package:luminous/core/widgets/common/app_ink_well.dart';
import 'package:luminous/core/widgets/common/app_section_surface.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordQuickActions extends StatelessWidget {
  const RecordQuickActions({
    super.key,
    required this.actions,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.compact = false,
    this.onQuickAction,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool compact;
  final ValueChanged<RecordQuickAction>? onQuickAction;

  @override
  Widget build(BuildContext context) {
    return AppSectionSurface(
      key: const Key('record-quick-actions'),
      title: l10n.recordQuickSectionTitle,
      typography: typography,
      surface: surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = compact || constraints.maxWidth < 520 ? 4 : 7;
          return Wrap(
            spacing: AppSpacingTokens.sm,
            runSpacing: AppSpacingTokens.sm,
            children: actions
                .map(
                  (action) => SizedBox(
                    width:
                        (constraints.maxWidth -
                            AppSpacingTokens.sm * (columns - 1)) /
                        columns,
                    child: _QuickActionTile(
                      action: action,
                      l10n: l10n,
                      typography: typography,
                      surface: surface,
                      onTap: onQuickAction,
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.action,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onTap,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<RecordQuickAction>? onTap;

  @override
  Widget build(BuildContext context) {
    final label = recordCopy(l10n, action.titleKey);

    return AppInkWell(
      onTap: onTap == null ? null : () => onTap!(action),
      borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: action.softColor.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
          border: Border.all(color: surface.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.xs,
            vertical: AppSpacingTokens.md,
          ),
          child: Column(
            children: [
              AppIconBadge(
                icon: action.icon,
                color: action.accent,
                backgroundColor: Colors.white.withValues(alpha: 0.7),
                size: 40,
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              Text(
                label,
                style: typography.bodySmStrong,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
