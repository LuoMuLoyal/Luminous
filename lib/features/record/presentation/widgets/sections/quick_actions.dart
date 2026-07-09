import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordQuickActions extends StatelessWidget {
  const RecordQuickActions({
    super.key,
    required this.actions,
    required this.l10n,
    this.compact = false,
    this.onQuickAction,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final bool compact;
  final ValueChanged<RecordQuickAction>? onQuickAction;

  @override
  Widget build(BuildContext context) {
    return FCard.raw(
      key: const Key('record-quick-actions'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recordQuickSectionTitle,
              style: AppTypographyToken.level5
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacingTokens.level4),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = compact || constraints.maxWidth < 520 ? 4 : 7;
                return Wrap(
                  spacing: AppSpacingTokens.level3,
                  runSpacing: AppSpacingTokens.level3,
                  children: actions
                      .map(
                        (action) => SizedBox(
                          width:
                              (constraints.maxWidth -
                                  AppSpacingTokens.level3 * (columns - 1)) /
                              columns,
                          child: _QuickActionTile(
                            action: action,
                            l10n: l10n,
                            onTap: onQuickAction,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.action,
    required this.l10n,
    this.onTap,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final ValueChanged<RecordQuickAction>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final label = recordCopy(l10n, action.titleKey);

    return FButton.raw(
      onPress: onTap == null ? null : () => onTap!(action),
      variant: FButtonVariant.outline,
      style: .delta(
        decoration: .delta([.all(.shapeDelta(color: colors.background))]),
        contentStyle: const .delta(
          padding: .value(
            EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.level2,
              vertical: AppSpacingTokens.level4,
            ),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FAvatar.raw(
            size: 40,
            style: .delta(backgroundColor: action.softColor.resolve(colors)),
            child: Icon(
              action.icon,
              color: action.accent.resolve(colors),
              size: 20,
            ),
          ),
          const SizedBox(height: AppSpacingTokens.level3),
          Text(
            label,
            style: AppTypographyToken.level3
                .body(context)
                .copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
