import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportSuggestionHistorySection extends StatelessWidget {
  const ReportSuggestionHistorySection({
    super.key,
    required this.suggestions,
    required this.l10n,
    this.isLoading = false,
    this.onSuggestionTap,
  });

  final List<NotificationListItemDto> suggestions;
  final AppLocalizations l10n;
  final bool isLoading;
  final ValueChanged<NotificationListItemDto>? onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('report-suggestion-history-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportSuggestionHistorySectionTitle,
          style: AppTypographyToken.level5
              .body(context)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        const AppDivider(),
        const SizedBox(height: AppSpacingTokens.level4),
        if (isLoading)
          const _LoadingList()
        else if (suggestions.isEmpty)
          _EmptyView(l10n: l10n)
        else
          FTileGroup(
            divider: FItemDivider.full,
            children: [
              for (final suggestion in suggestions)
                FTile(
                  key: Key('report-suggestion-${suggestion.id}'),
                  prefix: FAvatar.raw(
                    child: const Icon(FLucideIcons.sparkles, size: 18),
                  ),
                  title: Text(
                    suggestion.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    suggestion.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  details: Text(_formatTime(context, suggestion.createdAt)),
                  suffix: _SuggestionBadge(
                    isRead: suggestion.isRead,
                    l10n: l10n,
                  ),
                  onPress: onSuggestionTap == null
                      ? null
                      : () => onSuggestionTap!(suggestion),
                ),
            ],
          ),
      ],
    );
  }

  String _formatTime(BuildContext context, String iso8601) {
    final dateTime = DateTime.tryParse(iso8601)?.toLocal();
    if (dateTime == null) {
      return iso8601;
    }
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.Md(locale).add_Hm().format(dateTime);
  }
}

class _SuggestionBadge extends StatelessWidget {
  const _SuggestionBadge({required this.isRead, required this.l10n});

  final bool isRead;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final color = isRead ? colors.mutedForeground : colors.primary;
    final label = isRead
        ? l10n.reportSuggestionHistoryReadBadge
        : l10n.reportSuggestionHistoryUnreadBadge;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadiusTokens.levelFull),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level3,
          vertical: AppSpacingTokens.level1,
        ),
        child: Text(
          label,
          style: AppTypographyToken.level3
              .body(context)
              .copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.level5),
      decoration: BoxDecoration(
        color: colors.secondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadiusTokens.level3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FLucideIcons.history,
            color: colors.secondary,
            size: AppSpacingTokens.level5,
          ),
          const SizedBox(width: AppSpacingTokens.level3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reportSuggestionHistoryEmptyTitle,
                  style: AppTypographyToken.level5
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacingTokens.level1),
                Text(
                  l10n.reportSuggestionHistoryEmptyBody,
                  style: AppTypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return const AppSkeletonShimmer(
      child: Column(
        children: [
          AppInlineSkeletonBlock(height: 72, widthFactor: 1),
          SizedBox(height: AppSpacingTokens.level3),
          AppInlineSkeletonBlock(height: 72, widthFactor: 1),
          SizedBox(height: AppSpacingTokens.level3),
          AppInlineSkeletonBlock(height: 72, widthFactor: 1),
        ],
      ),
    );
  }
}
