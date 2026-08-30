import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
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
    this.onCameraPick,
    this.enabled = true,
  });

  final AppLocalizations l10n;
  final Uint8List? selectedBytes;
  final String? selectedFileName;
  final DailyRecordAttachment? existingAttachment;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final VoidCallback? onCameraPick;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final hasAttachment =
        selectedBytes != null ||
        existingAttachment?.objectKey.isNotEmpty == true;
    final fileName = selectedFileName ?? existingAttachment?.fileName;
    final typography = context.theme.typography;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recordImageSectionTitle,
              style: typography.body.md.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Spacing.level3),
            Row(
              children: [
                _AttachmentPreview(
                  selectedBytes: selectedBytes,
                  existingAttachment: existingAttachment,
                  label: l10n.recordImageAttachedLabel,
                ),
                const SizedBox(width: Spacing.level4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasAttachment
                            ? l10n.recordImageAttachedLabel
                            : l10n.recordImageEmptyLabel,
                        style: typography.body.md.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (fileName != null && fileName.trim().isNotEmpty) ...[
                        const SizedBox(height: Spacing.level1),
                        Text(
                          fileName,
                          style: typography.body.xs.copyWith(
                            color: SemanticColor.neutral.solid(context),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: Spacing.level3),
                      Wrap(
                        spacing: Spacing.level3,
                        runSpacing: Spacing.level2,
                        children: [
                          FButton(
                            variant: FButtonVariant.outline,
                            onPress: enabled ? onPick : null,
                            prefix: const Icon(
                              SemanticIcons.actionImage,
                              size: IconSizeTokens.level3,
                            ),
                            child: Text(
                              hasAttachment
                                  ? l10n.recordImageReplaceAction
                                  : l10n.recordImagePickAction,
                            ),
                          ),
                          if (onCameraPick != null)
                            FButton(
                              variant: FButtonVariant.outline,
                              onPress: enabled ? onCameraPick : null,
                              prefix: const Icon(
                                SemanticIcons.actionCamera,
                                size: IconSizeTokens.level3,
                              ),
                              child: Text(l10n.recordImageCameraAction),
                            ),
                          if (hasAttachment)
                            FButton(
                              variant: FButtonVariant.ghost,
                              onPress: enabled ? onRemove : null,
                              prefix: const Icon(
                                SemanticIcons.actionClose,
                                size: IconSizeTokens.level3,
                              ),
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
    final bytes = selectedBytes;
    final imageUrl = existingAttachment?.displayUrl;

    return ClipRRect(
      borderRadius: context.theme.style.borderRadius.sm,
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: SemanticColor.neutral.subtle(context),
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
                  const _PreviewFallback(icon: SemanticIcons.actionImage),
              errorWidget: (context, url, error) =>
                  const _PreviewFallback(icon: SemanticIcons.statusUnavailable),
            ),
            _ => const _PreviewFallback(icon: SemanticIcons.actionAdd),
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
      child: Icon(
        icon,
        color: SemanticColor.neutral.solid(context),
        size: IconSizeTokens.level4,
      ),
    );
  }
}
