import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/date_format_utils.dart';
import 'package:luminous/core/widgets/common/skeleton.dart';
import 'package:luminous/core/widgets/common/state_message.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/features/legal/domain/entities/doc_type.dart';
import 'package:luminous/features/legal/presentation/providers/legal.dart';
import 'package:luminous/features/legal/presentation/routes.dart';
import 'package:luminous/l10n/app_localizations.dart';

class LegalListPage extends ConsumerWidget {
  const LegalListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncList = ref.watch(legalDocumentsProvider);

    return PageScaffold(
      title: l10n.legalListTitle,
      child: asyncList.when(
        loading: () => const StateSkeletonView(
          blocks: [
            StateSkeletonBlock(height: 56, widthFactor: 1),
            StateSkeletonBlock(height: 56, widthFactor: 1),
            StateSkeletonBlock(height: 56, widthFactor: 1),
            StateSkeletonBlock(height: 56, widthFactor: 1),
          ],
        ),
        error: (_, __) => StateErrorView(
          title: l10n.legalLoadErrorTitle,
          description: l10n.legalLoadErrorDescription,
          icon: SemanticIcons.statusError,
          actionLabel: l10n.legalRetryAction,
          onAction: () => ref.invalidate(legalDocumentsProvider),
        ),
        data: (docs) {
          if (docs.isEmpty) {
            return StateMessageView(
              title: l10n.legalListEmptyTitle,
              description: l10n.legalListEmptyDescription,
              icon: SemanticIcons.recordNote,
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
                          l10n.legalListUpdatedAt(
                            formatDateTimeLabel(
                              doc.updatedAt,
                              Localizations.localeOf(context),
                            ),
                          ),
                          style: context.theme.typography.body.xs2.copyWith(
                            color: SemanticColor.neutral.solid(context),
                          ),
                        )
                      : null,
                  prefix: Icon(
                    _iconForType(doc.docType),
                    color: SemanticColor.primary.solid(context),
                    size: 20,
                  ),
                  suffix: const Icon(SemanticIcons.actionNext),
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
      LegalDocType.terms => SemanticIcons.recordNote,
      LegalDocType.privacy => SemanticIcons.safetyNeutral,
      LegalDocType.disclaimer => SemanticIcons.statusInfo,
      LegalDocType.minorProtection => SemanticIcons.safetySpecialGroup,
      LegalDocType.sdkList => SemanticIcons.tabRecord,
      LegalDocType.permissions => SemanticIcons.statusBlocked,
      LegalDocType.accountCancellation => SemanticIcons.profileUser,
    };
  }
}
