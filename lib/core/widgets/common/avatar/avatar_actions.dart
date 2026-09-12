import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog/sheet_drag_handle.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// An action selected from the avatar management sheet.
enum AvatarAction { camera, gallery, remove }

/// Opens the avatar management actions using the app's Forui sheet pattern.
Future<AvatarAction?> showAvatarActionsSheet(
  BuildContext context, {
  required String? avatarUrl,
}) {
  return showFSheet<AvatarAction>(
    context: context,
    side: FLayout.btt,
    useSafeArea: true,
    builder: (context) =>
        _AvatarActionsSheet(hasAvatar: avatarUrl?.trim().isNotEmpty == true),
  );
}

class _AvatarActionsSheet extends StatelessWidget {
  const _AvatarActionsSheet({required this.hasAvatar});

  final bool hasAvatar;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actions = <Widget>[
      const SheetDragHandle(),
      Text(
        l10n.profileAvatarActionsTitle,
        style: context.theme.typography.body.lg.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: Spacing.md),
      if (!kIsWeb)
        _AvatarActionTile(
          key: const Key('avatar-action-camera'),
          icon: SemanticIcons.actionCamera,
          title: l10n.profileAvatarTakePhoto,
          onPress: () => Navigator.of(context).pop(AvatarAction.camera),
        ),
      _AvatarActionTile(
        key: const Key('avatar-action-gallery'),
        icon: SemanticIcons.actionImage,
        title: l10n.profileAvatarChooseFromGallery,
        onPress: () => Navigator.of(context).pop(AvatarAction.gallery),
      ),
      if (hasAvatar) ...[
        const SizedBox(height: Spacing.sm),
        _AvatarActionTile(
          key: const Key('avatar-action-remove'),
          icon: SemanticIcons.actionDelete,
          color: SemanticColor.destructive,
          title: l10n.profileAvatarRemove,
          onPress: () => Navigator.of(context).pop(AvatarAction.remove),
        ),
      ],
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Spacing.xl, 0, Spacing.xl, Spacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: actions,
      ),
    );
  }
}

class _AvatarActionTile extends StatelessWidget {
  const _AvatarActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onPress,
    this.color = SemanticColor.primary,
  });

  final IconData icon;
  final String title;
  final VoidCallback onPress;
  final SemanticColor color;

  @override
  Widget build(BuildContext context) {
    return FTile(
      onPress: onPress,
      prefix: Icon(icon, size: IconSizeTokens.lg, color: color.solid(context)),
      title: Text(title),
    );
  }
}
