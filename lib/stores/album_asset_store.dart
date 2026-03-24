import 'dart:io';
import 'dart:typed_data';

import 'package:luminous/utils/scan_image_processing.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

typedef AlbumAssetRootDirectoryProvider = Future<Directory> Function();

/// 相册图片文件的本地读写入口。
///
/// 设计原则：
/// - 原图与缩略图都保存在应用私有目录，避免把大体积图片塞进 SQLite；
/// - SQLite 只保存文件路径和识别元数据；
/// - 缩略图的 base64 仅用于最佳努力上报云端，不在本地数据库重复存储。
class AlbumAssetStore {
  AlbumAssetStore({AlbumAssetRootDirectoryProvider? rootDirectoryProvider})
    : _rootDirectoryProvider =
          rootDirectoryProvider ?? _defaultRootDirectoryProvider;

  final AlbumAssetRootDirectoryProvider _rootDirectoryProvider;

  /// 保存一组扫描资产，并返回本地路径与可上传的缩略图 base64。
  Future<SavedAlbumAssets> saveScanAssets({
    required Uint8List imageBytes,
    String imageMimeType = 'image/jpeg',
    String preferredThumbBase64 = '',
  }) async {
    final rootDirectory = await _ensureRootDirectory();
    final originalsDirectory = Directory(
      p.join(rootDirectory.path, 'originals'),
    );
    final thumbsDirectory = Directory(p.join(rootDirectory.path, 'thumbs'));
    await originalsDirectory.create(recursive: true);
    await thumbsDirectory.create(recursive: true);

    final token = DateTime.now().microsecondsSinceEpoch.toString();
    final imagePath = p.join(
      originalsDirectory.path,
      'scan_$token.${_extensionForMimeType(imageMimeType)}',
    );
    var thumbPath = '';

    try {
      await File(imagePath).writeAsBytes(imageBytes, flush: true);

      final thumbPayload = await buildAlbumThumbPayload(
        bytes: imageBytes,
        preferredThumbBase64: preferredThumbBase64,
      );
      final thumbBase64 = (thumbPayload['thumbBase64'] as String? ?? '').trim();
      final rawThumbBytes = thumbPayload['thumbBytes'];
      final thumbBytes = rawThumbBytes is Uint8List
          ? rawThumbBytes
          : Uint8List(0);

      if (thumbBytes.isNotEmpty) {
        thumbPath = p.join(thumbsDirectory.path, 'thumb_$token.jpg');
        await File(thumbPath).writeAsBytes(thumbBytes, flush: true);
      }

      return SavedAlbumAssets(
        imagePath: imagePath,
        thumbPath: thumbPath,
        thumbBase64: thumbBase64,
      );
    } catch (_) {
      await deletePaths([imagePath, thumbPath]);
      rethrow;
    }
  }

  /// 读取一张已保存的图片。
  Future<Uint8List?> readBytes(String path) async {
    final normalizedPath = path.trim();
    if (normalizedPath.isEmpty) {
      return null;
    }

    final file = File(normalizedPath);
    if (!await file.exists()) {
      return null;
    }

    try {
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  /// 删除一组路径，适合失败回滚或后续清理。
  Future<void> deletePaths(Iterable<String> paths) async {
    for (final rawPath in paths) {
      final normalizedPath = rawPath.trim();
      if (normalizedPath.isEmpty) {
        continue;
      }

      try {
        final file = File(normalizedPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // 清理失败不影响主流程。
      }
    }
  }

  Future<Directory> _ensureRootDirectory() async {
    final directory = await _rootDirectoryProvider();
    await directory.create(recursive: true);
    return directory;
  }

  static Future<Directory> _defaultRootDirectoryProvider() async {
    final supportDirectory = await getApplicationSupportDirectory();
    return Directory(p.join(supportDirectory.path, 'album_assets'));
  }

  String _extensionForMimeType(String mimeType) {
    switch (mimeType.trim().toLowerCase()) {
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/heic':
        return 'heic';
      case 'image/heif':
        return 'heif';
      default:
        return 'jpg';
    }
  }
}

/// 一次扫描保存后生成的本地资产结果。
class SavedAlbumAssets {
  const SavedAlbumAssets({
    required this.imagePath,
    required this.thumbPath,
    required this.thumbBase64,
  });

  final String imagePath;
  final String thumbPath;
  final String thumbBase64;
}
