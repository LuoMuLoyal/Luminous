import 'dart:typed_data';

import 'package:luminous/api/scan_api.dart';
import 'package:luminous/stores/album_asset_store.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/viewmodels/album.dart';

typedef AlbumCreateRemoteRecord =
    Future<IdResult> Function({
      required String userId,
      required String thumbBase64,
      String? drugCode,
      String? approvalNo,
      String? productName,
      int? takenAt,
    });

/// 相册本地缓存的统一读写入口。
class AlbumLocalStore {
  AlbumLocalStore({
    AlbumAssetStore? assetStore,
    AlbumCreateRemoteRecord? createRemoteRecord,
  }) : _assetStore = assetStore ?? AlbumAssetStore(),
       _createRemoteRecord = createRemoteRecord ?? _defaultCreateRemoteRecord;

  static final AlbumLocalStore instance = AlbumLocalStore();

  final AlbumAssetStore _assetStore;
  final AlbumCreateRemoteRecord _createRemoteRecord;

  /// 读取指定用户作用域下的本地相册条目。
  Future<List<AlbumEntry>> loadEntries({String? userId}) async {
    try {
      final db = await AppDatabase.instance.database;
      final uid = normalizeUserId(userId);
      final rows = await db.query(
        'album_items',
        where: 'userId = ?',
        whereArgs: [uid],
        orderBy: 'COALESCE(takenAt, createdAt) DESC, createdAt DESC, id DESC',
      );
      return rows.map(AlbumEntry.fromLocalRow).toList();
    } catch (_) {
      return const [];
    }
  }

  /// 保存一条新的本地识别记录。
  ///
  /// 本地会持久化：
  /// - 原图文件；
  /// - 缩略图文件；
  /// - SQLite 中的元数据与路径。
  ///
  /// 若当前已登录，会在保存成功后最佳努力上报缩略图与识别结果。
  Future<void> saveScanRecord({
    String? userId,
    String? remoteId,
    String? drugCode,
    String? approvalNo,
    String? productName,
    required Uint8List imageBytes,
    String imageMimeType = '',
    String preferredThumbBase64 = '',
    required int takenAt,
    String source = 'scan',
  }) async {
    final uid = normalizeUserId(userId);
    final now = DateTime.now().millisecondsSinceEpoch;
    final effectiveTakenAt = takenAt == 0 ? now : takenAt;
    final trimmedRemoteId = _trimOrNull(remoteId);

    final assets = await _assetStore.saveScanAssets(
      imageBytes: imageBytes,
      imageMimeType: imageMimeType,
      preferredThumbBase64: preferredThumbBase64,
    );

    final db = await AppDatabase.instance.database;
    int localId;
    try {
      localId = await db.insert('album_items', {
        'remoteId': trimmedRemoteId,
        'userId': uid,
        'identityKey': _buildIdentityKey(
          drugCode: drugCode,
          approvalNo: approvalNo,
          productName: productName,
        ),
        'drugCode': _trimOrEmpty(drugCode),
        'approvalNo': _trimOrEmpty(approvalNo),
        'productName': _trimOrEmpty(productName),
        'imagePath': assets.imagePath,
        'thumbPath': _trimOrEmpty(assets.thumbPath),
        'imageMimeType': _normalizeMimeType(imageMimeType),
        'takenAt': effectiveTakenAt,
        'source': source.trim().isEmpty ? 'scan' : source.trim(),
        'createdAt': now,
      });
    } catch (_) {
      await _assetStore.deletePaths([assets.imagePath, assets.thumbPath]);
      rethrow;
    }

    if (uid.isEmpty || trimmedRemoteId != null || assets.thumbBase64.isEmpty) {
      return;
    }

    try {
      final result = await _createRemoteRecord(
        userId: uid,
        thumbBase64: assets.thumbBase64,
        drugCode: drugCode,
        approvalNo: approvalNo,
        productName: productName,
        takenAt: effectiveTakenAt,
      );
      if (!result.hasId) {
        return;
      }
      await db.update(
        'album_items',
        {'remoteId': result.id.trim()},
        where: 'id = ?',
        whereArgs: [localId],
      );
    } catch (_) {
      // 远端上报失败不影响本地记录。
    }
  }

  /// 读取相册原图，供再次识别使用。
  Future<Uint8List?> readImageBytes(String imagePath) {
    return _assetStore.readBytes(imagePath);
  }

  String _normalizeMimeType(String imageMimeType) {
    final trimmed = imageMimeType.trim();
    return trimmed.isEmpty ? 'image/jpeg' : trimmed;
  }

  String _buildIdentityKey({
    String? drugCode,
    String? approvalNo,
    String? productName,
  }) {
    final trimmedDrugCode = _trimOrEmpty(drugCode);
    if (trimmedDrugCode.isNotEmpty) {
      return 'drugCode:$trimmedDrugCode';
    }

    final trimmedApprovalNo = _trimOrEmpty(approvalNo);
    if (trimmedApprovalNo.isNotEmpty) {
      return 'approvalNo:$trimmedApprovalNo';
    }

    final trimmedProductName = _trimOrEmpty(productName);
    if (trimmedProductName.isNotEmpty) {
      return 'name:$trimmedProductName';
    }

    return 'scan:${DateTime.now().millisecondsSinceEpoch}';
  }

  String _trimOrEmpty(String? value) => (value ?? '').trim();

  String normalizeUserId(String? value) => _trimOrEmpty(value);

  String? _trimOrNull(String? value) {
    final trimmed = _trimOrEmpty(value);
    return trimmed.isEmpty ? null : trimmed;
  }

  static Future<IdResult> _defaultCreateRemoteRecord({
    required String userId,
    required String thumbBase64,
    String? drugCode,
    String? approvalNo,
    String? productName,
    int? takenAt,
  }) async {
    final response = await ScanApi.createScanRecord(
      userId: userId,
      thumbBase64: thumbBase64,
      drugCode: drugCode,
      approvalNo: approvalNo,
      productName: productName,
      takenAt: takenAt,
    );
    return response.result;
  }
}

final albumLocalStore = AlbumLocalStore.instance;
