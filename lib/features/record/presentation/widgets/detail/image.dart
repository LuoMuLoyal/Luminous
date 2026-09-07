import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/record.dart';

class RecordDetailImage extends StatelessWidget {
  const RecordDetailImage({super.key, required this.attachment});

  final DailyRecordAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final imageUrl = attachment.displayUrl;

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
              : CachedNetworkImage(
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
      ),
    );
  }
}
