import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/photo_viewer.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordDetailImage extends StatelessWidget {
  const RecordDetailImage({super.key, required this.attachment});

  final DailyRecordAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final imageUrl = attachment.displayUrl;
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: context.theme.style.borderRadius.sm,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: SemanticColor.neutral.subtle(context),
          ),
          child: imageUrl == null
              ? Center(
                  child: Icon(
                    SemanticIcons.actionImage,
                    color: SemanticColor.neutral.solid(context),
                    size: 28,
                  ),
                )
              : _ZoomableAttachment(
                  imageUrl: imageUrl,
                  semanticLabel: l10n.commonImagePreviewLabel,
                ),
        ),
      ),
    );
  }
}

/// Tap-to-zoom wrapper around the attachment thumbnail.
///
/// Only wraps a successfully loadable URL: a broken image would otherwise open
/// a viewer that can only show its error state.
class _ZoomableAttachment extends StatelessWidget {
  const _ZoomableAttachment({
    required this.imageUrl,
    required this.semanticLabel,
  });

  final String imageUrl;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: () => showPhotoViewer(
          context,
          imageUrl: imageUrl,
          semanticLabel: semanticLabel,
        ),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: Icon(
              SemanticIcons.actionImage,
              color: SemanticColor.neutral.solid(context),
              size: 28,
            ),
          ),
          errorWidget: (context, url, error) => Center(
            child: Icon(
              SemanticIcons.statusUnavailable,
              color: SemanticColor.neutral.solid(context),
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
