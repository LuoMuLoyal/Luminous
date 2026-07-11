import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/skeleton.dart';
import 'package:luminous/core/widgets/common/state_message.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/features/legal/domain/entities/legal_doc_type.dart';
import 'package:luminous/features/legal/presentation/providers/legal_providers.dart';
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
        ),
      );
    }

    final asyncDoc = ref.watch(legalDocumentProvider(parsedType));

    return PageScaffold(
      title: l10n.legalDetailTitle,
      child: asyncDoc.when(
        loading: () => _LegalDetailSkeleton(),
        error: (_, __) => AppStateErrorView(
          title: l10n.legalLoadErrorTitle,
          description: l10n.legalLoadErrorDescription,
          icon: FLucideIcons.circleAlert,
          actionLabel: l10n.legalRetryAction,
          onAction: () => ref.invalidate(legalDocumentProvider(parsedType)),
        ),
        data: (doc) => Markdown(
          data: doc.content,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.level4,
            vertical: Spacing.level5,
          ),
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: TypographyToken.level3.body(context),
            h1: TypographyToken.level6
                .body(context)
                .copyWith(fontWeight: FontWeight.w700),
            h2: TypographyToken.level5
                .body(context)
                .copyWith(fontWeight: FontWeight.w600),
            h3: TypographyToken.level4
                .body(context)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _LegalDetailSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const AppStateSkeletonView(
      blocks: [
        AppStateSkeletonBlock(height: 32, widthFactor: 0.6),
        AppStateSkeletonBlock(height: 16, widthFactor: 0.9),
        AppStateSkeletonBlock(height: 16, widthFactor: 0.85),
        AppStateSkeletonBlock(height: 16, widthFactor: 0.7),
        AppStateSkeletonBlock(height: 24, widthFactor: 0.4),
        AppStateSkeletonBlock(height: 16, widthFactor: 0.8),
        AppStateSkeletonBlock(height: 16, widthFactor: 0.75),
      ],
    );
  }
}
