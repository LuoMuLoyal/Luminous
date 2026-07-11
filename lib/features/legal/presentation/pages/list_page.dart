import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/skeleton.dart';
import 'package:luminous/core/widgets/common/state_message.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/features/legal/domain/entities/legal_doc_type.dart';
import 'package:luminous/features/legal/presentation/providers/legal_providers.dart';
import 'package:luminous/features/legal/presentation/routes.dart';
import 'package:luminous/l10n/app_localizations.dart';

class LegalListPage extends ConsumerWidget {
  const LegalListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final asyncList = ref.watch(legalDocumentsProvider);

    return PageScaffold(
      title: l10n.legalListTitle,
      child: asyncList.when(
        loading: () => const AppStateSkeletonView(
          blocks: [
            AppStateSkeletonBlock(height: 56, widthFactor: 1),
            AppStateSkeletonBlock(height: 56, widthFactor: 1),
            AppStateSkeletonBlock(height: 56, widthFactor: 1),
            AppStateSkeletonBlock(height: 56, widthFactor: 1),
          ],
        ),
        error: (_, __) => AppStateErrorView(
          title: l10n.legalLoadErrorTitle,
          description: l10n.legalLoadErrorDescription,
          icon: FLucideIcons.circleAlert,
          actionLabel: l10n.legalRetryAction,
          onAction: () => ref.invalidate(legalDocumentsProvider),
        ),
        data: (docs) {
          if (docs.isEmpty) {
            return AppStateMessageView(
              title: l10n.legalListEmptyTitle,
              description: l10n.legalListEmptyDescription,
              icon: FLucideIcons.fileText,
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.level4,
              vertical: Spacing.level4,
            ),
            child: FTileGroup(
              children: docs.map((doc) {
                return FTile(
                  title: Text(doc.title),
                  subtitle: doc.updatedAt.isNotEmpty
                      ? Text(
                          l10n.legalListUpdatedAt(doc.updatedAt),
                          style: TypographyToken.level2
                              .body(context)
                              .copyWith(color: colors.mutedForeground),
                        )
                      : null,
                  prefix: Icon(
                    _iconForType(doc.docType),
                    color: colors.primary,
                    size: 20,
                  ),
                  suffix: const Icon(FLucideIcons.chevronRight),
                  onPress: () => LegalDetailRoute(
                    docType: doc.docType.pathSegment,
                  ).push(context),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  IconData _iconForType(LegalDocType type) {
    return switch (type) {
      LegalDocType.terms => FLucideIcons.fileText,
      LegalDocType.privacy => FLucideIcons.shield,
      LegalDocType.disclaimer => FLucideIcons.info,
      LegalDocType.minorProtection => FLucideIcons.baby,
      LegalDocType.sdkList => FLucideIcons.list,
      LegalDocType.permissions => FLucideIcons.key,
      LegalDocType.accountCancellation => FLucideIcons.userMinus,
    };
  }
}
