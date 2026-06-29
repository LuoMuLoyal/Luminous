import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
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
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(
      Theme.of(context).colorScheme.onSurface,
    );
    final hasAttachment =
        selectedBytes != null ||
        existingAttachment?.objectKey.isNotEmpty == true;
    final fileName = selectedFileName ?? existingAttachment?.fileName;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.recordImageSectionTitle, style: typography.bodyMdStrong),
            const SizedBox(height: AppSpacingTokens.sm),
            Row(
              children: [
                _AttachmentPreview(
                  selectedBytes: selectedBytes,
                  existingAttachment: existingAttachment,
                  surface: surface,
                  label: l10n.recordImageAttachedLabel,
                ),
                const SizedBox(width: AppSpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasAttachment
                            ? l10n.recordImageAttachedLabel
                            : l10n.recordImageEmptyLabel,
                        style: typography.bodySmStrong,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (fileName != null && fileName.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacingTokens.xxs),
                        Text(
                          fileName,
                          style: typography.caption.copyWith(
                            color: surface.body,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: AppSpacingTokens.sm),
                      Wrap(
                        spacing: AppSpacingTokens.sm,
                        runSpacing: AppSpacingTokens.xs,
                        children: [
                          OutlinedButton.icon(
                            onPressed: enabled ? onPick : null,
                            icon: const Icon(Icons.image_outlined, size: 18),
                            label: Text(
                              hasAttachment
                                  ? l10n.recordImageReplaceAction
                                  : l10n.recordImagePickAction,
                            ),
                          ),
                          if (hasAttachment)
                            TextButton.icon(
                              onPressed: enabled ? onRemove : null,
                              icon: const Icon(Icons.close_rounded, size: 18),
                              label: Text(l10n.recordImageRemoveAction),
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
    required this.surface,
    required this.label,
  });

  final Uint8List? selectedBytes;
  final DailyRecordAttachment? existingAttachment;
  final AppThemeSurface surface;
  final String label;

  @override
  Widget build(BuildContext context) {
    const width = 96.0;
    const height = 72.0;
    final bytes = selectedBytes;
    final imageUrl = existingAttachment?.displayUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadiusTokens.md),
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(color: surface.canvasSoft2),
          child: switch ((bytes, imageUrl)) {
            (final Uint8List data, _) => Image.memory(
              data,
              fit: BoxFit.cover,
              semanticLabel: label,
            ),
            (_, final String url) => CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, url) => _PreviewFallback(
                surface: surface,
                icon: Icons.image_outlined,
              ),
              errorWidget: (context, url, error) => _PreviewFallback(
                surface: surface,
                icon: Icons.broken_image_outlined,
              ),
            ),
            _ => _PreviewFallback(
              surface: surface,
              icon: Icons.add_photo_alternate_outlined,
            ),
          },
        ),
      ),
    );
  }
}

class _PreviewFallback extends StatelessWidget {
  const _PreviewFallback({required this.surface, required this.icon});

  final AppThemeSurface surface;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(child: Icon(icon, color: surface.mute, size: 24));
  }
}
