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
///
/// 调用方需保证传入的 [context] 在 await 边界后仍 mounted（例如来自
/// dialog / showModalBottomSheet 内部），否则空文件/裁剪失败等反馈
/// Toast 会静默不显示。
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
    // 裁剪画布是拖动交互面:保留 scrollable: false(外层滚动会抢走裁剪框的
    // 拖拽),因此必须给弹窗一个有界高度。这里只圈定「不超过一屏」(FDialog 自己
    // 的 insetPadding 会再收紧);真正的收口在 [AvatarCropper]:画布按剩余高度
    // 自适应,上限 [_maxCropCanvasSize]——标题/按钮行随字号变高时画布让位,不会
    // 再把按钮行挤出弹窗下沿。
    maxHeight: MediaQuery.sizeOf(context).height,
    scrollable: false,
    builder: (_) => AvatarCropper(bytes: bytes),
  );
}

/// 裁剪画布的最大边长。窄屏 + 大字号下实际边长由可用高度决定,见 [AvatarCropper]。
const double _maxCropCanvasSize = 320;

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

    // 画布高度自适应:固定高度 + 弹窗固定上限的组合在大字号真机上会把按钮行顶出
    // 弹窗(标题、按钮标签都随字号长高,留给画布的空间相应变小)。弹窗高度有界时
    // 让画布吃掉标题与按钮行之外的剩余高度(Flexible),边长仍以
    // [_maxCropCanvasSize] 为上限、并保持 1:1;没有上界时(例如被直接放进可滚动
    // 容器)退回固定正方形——Flexible 在无界主轴上会断言失败。
    final canvas = Crop(
      image: widget.bytes,
      controller: _controller,
      aspectRatio: 1,
      withCircleUi: true,
      interactive: true,
      fixCropRect: true,
      maskColor: Colors.black54,
      onCropped: _handleCropped,
    );

    return LayoutBuilder(
      builder: (context, constraints) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.profileAvatarCropTitle,
            style: context.theme.typography.body.lg.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          if (constraints.hasBoundedHeight)
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: _maxCropCanvasSize,
                ),
                child: AspectRatio(aspectRatio: 1, child: canvas),
              ),
            )
          else
            SizedBox(height: _maxCropCanvasSize, child: canvas),
          const SizedBox(height: Spacing.lg),
          // 按钮是固有宽度:Row 会先给它们无界主轴约束、把右缘顶出弹窗。
          DialogActionRow(
            actions: [
              DialogActionButton(
                label: l10n.commonCancel,
                variant: FButtonVariant.ghost,
                onPress: _cropping ? null : () => Navigator.of(context).pop(),
              ),
              DialogActionButton(
                label: _cropping
                    ? l10n.profileAvatarCropProcessing
                    : l10n.profileAvatarCropDone,
                onPress: _cropping
                    ? null
                    : () {
                        setState(() => _cropping = true);
                        _controller.crop();
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleCropped(CropResult result) {
    if (!mounted) return;
    setState(() => _cropping = false);
    if (result is CropSuccess) {
      Navigator.of(context).pop(result.croppedImage);
    } else {
      _showCropFailure();
    }
  }

  void _showCropFailure() {
    // 直接使用 State.context 而非收 BuildContext 参数：调用方（onCropped
    // 回调）已由 `if (!mounted) return;` 保证走到这里时 State 仍挂载，
    // 避免从 dispose 路径误传已失效的 context 给 Toast。
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    // 轻量反馈统一走 Toast（AGENTS.md「轻反馈用 AppToast」约定）,
    // 不在这里用 ScaffoldMessenger/SnackBar——对话框之上做全局提示。
    unawaited(Toast.show(context, l10n.profileAvatarCropFailed));
  }
}
