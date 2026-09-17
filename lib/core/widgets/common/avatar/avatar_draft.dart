import 'dart:async';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_actions.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AvatarDraft {
  const AvatarDraft({
    required this.bytes,
    required this.fileName,
    required this.contentType,
  });

  final Uint8List bytes;
  final String fileName;
  final String contentType;
}

const _avatarContentTypes = <String, String>{
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'webp': 'image/webp',
};

/// Picks an image and returns a local avatar draft. Web intentionally skips
/// cropping and uses the original bytes as the product fallback.
Future<AvatarDraft?> pickAvatarDraft(
  BuildContext context, {
  required AvatarAction action,
  ImagePicker? picker,
}) async {
  if (action == AvatarAction.remove) return null;
  final image = await (picker ?? ImagePicker()).pickImage(
    source: action == AvatarAction.camera
        ? ImageSource.camera
        : ImageSource.gallery,
    requestFullMetadata: false,
  );
  if (image == null) return null;

  final bytes = await image.readAsBytes();
  if (bytes.isEmpty) {
    // 空文件(读取失败/损坏)按失败处理,给一条轻提示,不让用户以为选图成功。
    if (context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      unawaited(Toast.show(context, l10n.profileAvatarEmptyFile));
    }
    return null;
  }
  if (kIsWeb) {
    return AvatarDraft(
      bytes: bytes,
      fileName: image.name,
      contentType: _contentType(image.name),
    );
  }

  if (!context.mounted) return null;
  final cropped = await showAvatarCropper(context, bytes: bytes);
  if (cropped == null) return null;
  return AvatarDraft(
    bytes: cropped,
    fileName: 'avatar.jpg',
    contentType: 'image/jpeg',
  );
}

String _contentType(String name) {
  final extension = name.split('.').last.toLowerCase();
  return _avatarContentTypes[extension] ?? 'application/octet-stream';
}

Future<Uint8List?> showAvatarCropper(
  BuildContext context, {
  required Uint8List bytes,
}) {
  return showAppDialog<Uint8List?>(
    context: context,
    maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
    scrollable: false,
    builder: (_) => AvatarCropper(bytes: bytes),
  );
}

class AvatarCropper extends StatefulWidget {
  const AvatarCropper({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  State<AvatarCropper> createState() => _AvatarCropperState();
}

class _AvatarCropperState extends State<AvatarCropper> {
  final _controller = CropController();
  bool _cropping = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.profileAvatarCropTitle,
          style: context.theme.typography.body.lg.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.lg),
        SizedBox(
          height: 320,
          child: Crop(
            image: widget.bytes,
            controller: _controller,
            aspectRatio: 1,
            withCircleUi: true,
            interactive: true,
            fixCropRect: true,
            maskColor: Colors.black54,
            onCropped: (result) {
              if (!mounted) return;
              setState(() => _cropping = false);
              if (result is CropSuccess) {
                Navigator.of(context).pop(result.croppedImage);
              } else {
                _showCropFailure(context);
              }
            },
          ),
        ),
        const SizedBox(height: Spacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: _cropping ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            const SizedBox(width: Spacing.sm),
            FButton(
              onPress: _cropping
                  ? null
                  : () {
                      setState(() => _cropping = true);
                      _controller.crop();
                    },
              child: Text(
                _cropping
                    ? l10n.profileAvatarCropProcessing
                    : l10n.profileAvatarCropDone,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCropFailure(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // 轻量反馈统一走 Toast（AGENTS.md「轻反馈用 AppToast」约定）,
    // 不在这里用 ScaffoldMessenger/SnackBar——对话框之上做全局提示。
    unawaited(Toast.show(context, l10n.profileAvatarCropFailed));
  }
}
