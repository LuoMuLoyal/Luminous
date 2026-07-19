import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/date_format_utils.dart';
import 'package:luminous/core/widgets/common/skeleton.dart';
import 'package:luminous/core/widgets/common/state_message.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/legal/domain/entities/doc_type.dart';
import 'package:luminous/features/legal/presentation/providers/legal.dart';
import 'package:luminous/l10n/app_localizations.dart';

class LegalDetailPage extends ConsumerWidget {
  const LegalDetailPage({super.key, required this.docType});

  final String docType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final parsedType = LegalDocType.fromPathSegment(docType);

    if (parsedType == null) {
      return PageScaffold(
        title: l10n.legalDetailTitle,
        child: AppStateErrorView(
          title: l10n.legalNotFoundTitle,
          description: l10n.legalNotFoundDescription,
          icon: FLucideIcons.fileQuestion,
          actionLabel: l10n.legalBackToListAction,
          onAction: () => context.go(AppRoutes.legal),
        ),
      );
    }

    final asyncDoc = ref.watch(legalDocumentProvider(parsedType));

    // Use the document title as the page title when available.
    final pageTitle = asyncDoc.maybeWhen(
      data: (doc) => doc.title,
      orElse: () => l10n.legalDetailTitle,
    );

    return PageScaffold(
      title: pageTitle,
      child: asyncDoc.when(
        loading: () => const _LegalDetailSkeleton(),
        error: (_, __) => AppStateErrorView(
          title: l10n.legalLoadErrorTitle,
          description: l10n.legalLoadErrorDescription,
          icon: FLucideIcons.circleAlert,
          actionLabel: l10n.legalRetryAction,
          onAction: () => ref.invalidate(legalDocumentProvider(parsedType)),
        ),
        data: (doc) => ResponsiveContentFrame(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: Spacing.level5,
                    bottom: Spacing.level2,
                  ),
                  child: Text(
                    l10n.legalListUpdatedAt(
                      formatDateTimeLabel(
                        doc.updatedAt,
                        Localizations.localeOf(context),
                        fallback: doc.updatedAt,
                      ),
                    ),
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: context.theme.colors.mutedForeground),
                  ),
                ),
                MarkdownBody(
                  data: doc.content,
                  selectable: true,
                  shrinkWrap: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                      .copyWith(
                        p: TypographyToken.level4
                            .body(context)
                            .copyWith(height: 1.7),
                        h1: TypographyToken.level7
                            .body(context)
                            .copyWith(fontWeight: FontWeight.w700),
                        h2: TypographyToken.level6
                            .body(context)
                            .copyWith(fontWeight: FontWeight.w600),
                        h3: TypographyToken.level5
                            .body(context)
                            .copyWith(fontWeight: FontWeight.w600),
                        h1Padding: const EdgeInsets.only(top: Spacing.level6),
                        h2Padding: const EdgeInsets.only(top: Spacing.level5),
                        h3Padding: const EdgeInsets.only(top: Spacing.level4),
                      ),
                ),
                const SizedBox(height: Spacing.level7),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalDetailSkeleton extends StatelessWidget {
  const _LegalDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const ResponsiveContentFrame(
      child: AppStateSkeletonView(
        blocks: [
          AppStateSkeletonBlock(height: 32, widthFactor: 0.6),
          AppStateSkeletonBlock(height: 16, widthFactor: 0.9),
          AppStateSkeletonBlock(height: 16, widthFactor: 0.85),
          AppStateSkeletonBlock(height: 16, widthFactor: 0.7),
          AppStateSkeletonBlock(height: 24, widthFactor: 0.4),
          AppStateSkeletonBlock(height: 16, widthFactor: 0.8),
          AppStateSkeletonBlock(height: 16, widthFactor: 0.75),
        ],
      ),
    );
  }
}
