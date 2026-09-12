import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// Displays an account avatar with one consistent fallback across the app.
///
/// This widget is intentionally presentation-only: it never loads or mutates
/// account state beyond resolving the supplied URL.
class AvatarView extends StatelessWidget {
  const AvatarView({
    super.key,
    this.avatarUrl,
    this.bytes,
    this.size = IconSizeTokens.xl4,
    this.iconSize = IconSizeTokens.xl2,
    this.semanticLabel,
    this.borderColor,
    this.borderWidth = 1,
    this.onTap,
  });

  final String? avatarUrl;
  final Uint8List? bytes;
  final double size;
  final double iconSize;
  final String? semanticLabel;
  final Color? borderColor;
  final double borderWidth;

  /// Makes the avatar box a tap target.
  ///
  /// The gesture belongs here rather than on an outer [Stack] wrapper: the
  /// stack's hit test is resolved by its children, so a tap that lands off the
  /// rendered bitmap never reaches a wrapper-level detector.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    final border = borderColor ?? SemanticColor.neutral.border(context);

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.theme.colors.secondary,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: bytes != null
          ? Image.memory(bytes!, width: size, height: size, fit: BoxFit.cover)
          : url == null || url.isEmpty
          ? _FallbackIcon(size: iconSize)
          : CachedNetworkImage(
              imageUrl: url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, __) => _FallbackIcon(size: iconSize),
              errorWidget: (_, __, ___) => _FallbackIcon(size: iconSize),
            ),
    );

    return Semantics(
      image: true,
      button: onTap != null,
      label: semanticLabel,
      child: onTap == null
          ? avatar
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: avatar,
            ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        SemanticIcons.profileUser,
        color: SemanticColor.neutral.solid(context),
        size: size,
      ),
    );
  }
}
