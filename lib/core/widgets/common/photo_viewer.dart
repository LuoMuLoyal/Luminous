import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';
import 'package:luminous/core/widgets/common/feedback/state_message.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:photo_view/photo_view.dart';

/// Interactive full-screen image viewer for remote images.
///
/// Zoom/pan gestures come from [PhotoView]; image loading and caching still go
/// through [CachedNetworkImageProvider] so the app keeps a single cache strategy
/// (this widget is a viewer, not a second loader).
///
/// Returns a `Future` that completes when the viewer is dismissed.
Future<void> showPhotoViewer(
  BuildContext context, {
  required String imageUrl,
  String? semanticLabel,
  String? heroTag,
}) {
  return showAppDialog<void>(
    context: context,
    // PhotoView fills the dialog and owns the pan gesture; an outer scroll view
    // would steal vertical drags, so scrollable must stay false with a bounded
    // height (DialogShell asserts on unbounded + scrollable: false).
    scrollable: false,
    maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
    maxHeight: _viewerHeight(context),
    padding: EdgeInsets.zero,
    builder: (dialogContext) => PhotoViewer(
      imageUrl: imageUrl,
      semanticLabel: semanticLabel,
      heroTag: heroTag,
      onClose: () => Navigator.of(dialogContext).pop(),
    ),
  );
}

/// Interactive full-screen viewer for a local image file.
///
/// Same surface as [showPhotoViewer], but for on-device paths (e.g. a just-taken
/// scan photo) instead of a remote URL.
Future<void> showFilePhotoViewer(
  BuildContext context, {
  required String filePath,
  String? semanticLabel,
  String? heroTag,
}) {
  return showAppDialog<void>(
    context: context,
    scrollable: false,
    maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
    maxHeight: _viewerHeight(context),
    padding: EdgeInsets.zero,
    builder: (dialogContext) => PhotoViewer(
      filePath: filePath,
      semanticLabel: semanticLabel,
      heroTag: heroTag,
      onClose: () => Navigator.of(dialogContext).pop(),
    ),
  );
}

double _viewerHeight(BuildContext context) {
  final screenHeight = MediaQuery.sizeOf(context).height;
  return (screenHeight * 0.8).clamp(240.0, 640.0);
}

/// Zoomable image surface. Prefer [showPhotoViewer] / [showFilePhotoViewer]
/// unless embedding inline.
class PhotoViewer extends StatelessWidget {
  const PhotoViewer({
    super.key,
    this.imageUrl,
    this.filePath,
    this.semanticLabel,
    this.heroTag,
    this.onClose,
  }) : assert(
         (imageUrl == null) != (filePath == null),
         'PhotoViewer needs exactly one of imageUrl or filePath.',
       );

  final String? imageUrl;
  final String? filePath;
  final String? semanticLabel;
  final String? heroTag;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = semanticLabel ?? l10n.commonImagePreviewLabel;

    Widget viewer = PhotoView(
      imageProvider: imageUrl != null
          ? CachedNetworkImageProvider(imageUrl!)
          : FileImage(File(filePath!)),
      semanticLabel: label,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      minScale: PhotoViewComputedScale.contained * 0.8,
      maxScale: PhotoViewComputedScale.covered * 3,
      initialScale: PhotoViewComputedScale.contained,
      loadingBuilder: (context, progress) => const _PhotoViewerLoading(),
      errorBuilder: (context, error, stackTrace) => Center(
        child: StateMessageView(
          title: l10n.stateFatalErrorTitle,
          description: l10n.stateFatalErrorDescription,
          icon: SemanticIcons.statusUnavailable,
          tone: StateTone.danger,
          card: false,
          padding: const EdgeInsets.all(Spacing.xl),
        ),
      ),
    );

    if (heroTag != null) {
      viewer = Hero(tag: heroTag!, child: viewer);
    }

    return Semantics(
      label: label,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: viewer,
          ),
          if (onClose != null)
            Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: FTooltip(
                tipBuilder: (_, __) => Text(l10n.commonClose),
                child: FButton.icon(
                  variant: FButtonVariant.ghost,
                  onPress: onClose,
                  child: const Icon(
                    SemanticIcons.actionClose,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Skeleton shown while the image decodes.
///
/// Uses the shared shimmer primitive instead of a spinner, per the app's
/// loading-state convention.
class _PhotoViewerLoading extends StatelessWidget {
  const _PhotoViewerLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SkeletonShimmer(
        child: InlineSkeletonBlock(height: 48, width: 48, radius: 8),
      ),
    );
  }
}
