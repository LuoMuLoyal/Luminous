import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/l10n/app_localizations.dart';

class DailyRecordImageAttachmentField extends StatelessWidget {
  const DailyRecordImageAttachmentField({
    super.key,
    required this.l10n,
    required this.selectedBytes,
    required this.selectedFileName,
    required this.existingAttachment,
    required this.onPick,
    required this.onRemove,
    this.enabled = true,
  });

  final AppLocalizations l10n;
  final Uint8List? selectedBytes;
  final String? selectedFileName;
  final DailyRecordAttachment? existingAttachment;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final hasAttachment =
        selectedBytes != null ||
        existingAttachment?.objectKey.isNotEmpty == true;
    final fileName = selectedFileName ?? existingAttachment?.fileName;

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recordImageSectionTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacingTokens.level3),
            Row(
              children: [
                _AttachmentPreview(
                  selectedBytes: selectedBytes,
                  existingAttachment: existingAttachment,
                  label: l10n.recordImageAttachedLabel,
                ),
                const SizedBox(width: AppSpacingTokens.level4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasAttachment
                            ? l10n.recordImageAttachedLabel
                            : l10n.recordImageEmptyLabel,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (fileName != null && fileName.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacingTokens.level1),
                        Text(
                          fileName,
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.mutedForeground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: AppSpacingTokens.level3),
                      Wrap(
                        spacing: AppSpacingTokens.level3,
                        runSpacing: AppSpacingTokens.level2,
                        children: [
                          FButton(
                            variant: FButtonVariant.outline,
                            onPress: enabled ? onPick : null,
                            prefix: const Icon(FLucideIcons.image, size: 18),
                            child: Text(
                              hasAttachment
                                  ? l10n.recordImageReplaceAction
                                  : l10n.recordImagePickAction,
                            ),
                          ),
                          if (hasAttachment)
                            FButton(
                              variant: FButtonVariant.ghost,
                              onPress: enabled ? onRemove : null,
                              prefix: const Icon(FLucideIcons.x, size: 18),
                              child: Text(l10n.recordImageRemoveAction),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({
    required this.selectedBytes,
    required this.existingAttachment,
    required this.label,
  });

  final Uint8List? selectedBytes;
  final DailyRecordAttachment? existingAttachment;
  final String label;

  @override
  Widget build(BuildContext context) {
    const width = 96.0;
    const height = 72.0;
    final colors = context.theme.colors;
    final bytes = selectedBytes;
    final imageUrl = existingAttachment?.displayUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadiusTokens.level3),
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.secondary.withValues(alpha: 0.2),
          ),
          child: switch ((bytes, imageUrl)) {
            (final Uint8List data, _) => Image.memory(
              data,
              fit: BoxFit.cover,
              semanticLabel: label,
            ),
            (_, final String url) => CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const _PreviewFallback(icon: FLucideIcons.image),
              errorWidget: (context, url, error) =>
                  const _PreviewFallback(icon: FLucideIcons.imageOff),
            ),
            _ => const _PreviewFallback(icon: FLucideIcons.imagePlus),
          },
        ),
      ),
    );
  }
}

class _PreviewFallback extends StatelessWidget {
  const _PreviewFallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(icon, color: context.theme.colors.mutedForeground, size: 24),
    );
  }
}
