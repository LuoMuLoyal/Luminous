import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';

/// Renders the bundled app icon at [size].
///
/// `assets/icon/app_icon.png` is 1024×1024 — a **4 MB** bitmap once decoded —
/// but it is drawn at 24–64 logical pixels. Without a decode hint the first
/// paint decodes the full-size bitmap and blocks the UI isolate: a profile
/// trace (2026-09-12) showed `ImageCache.putIfAbsent` at **41.8 ms** plus a
/// 41.7 ms stream listener right when the login page appeared, together with
/// 31 ms of concurrent-mark GC. Passing `cacheWidth`/`cacheHeight` here decodes
/// it at the displayed size (in physical pixels) instead, so every call site
/// gets the cheap path by construction.
class BrandIcon extends StatelessWidget {
  const BrandIcon({
    super.key,
    required this.size,
    this.fit = BoxFit.contain,
    this.errorIcon = SemanticIcons.safetyCaution,
  });

  /// Logical edge length to render at.
  final double size;

  final BoxFit fit;

  /// Fallback icon (`IconData`) shown if the asset fails to load. Pass `null`
  /// to render nothing on failure.
  final IconData? errorIcon;

  static const String assetPath = 'assets/icon/app_icon.png';

  @override
  Widget build(BuildContext context) {
    final cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
      cacheWidth: cacheSize,
      cacheHeight: cacheSize,
      errorBuilder: errorIcon == null
          ? null
          : (context, error, stackTrace) => Icon(
              errorIcon,
              color: SemanticColor.primary.solid(context),
              size: size,
            ),
    );
  }
}
