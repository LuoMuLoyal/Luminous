import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/album/data/album_asset_store.dart';
import 'package:luminous/features/album/data/album_local_store.dart';
import 'package:luminous/core/local_storage/app_database.dart';
import 'package:luminous/features/album/presentation/models/album.dart';

import 'support/fake_sqflite_database.dart';

const _tinyPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+nWZ0AAAAASUVORK5CYII=';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AlbumLocalStore store;

  AlbumLocalStore buildStore({
    Future<IdResult> Function({
      required String userId,
      required String thumbBase64,
      String? drugCode,
      String? approvalNo,
      String? productName,
      int? takenAt,
    })?
    createRemoteRecord,
  }) {
    return AlbumLocalStore(
      assetStore: AlbumAssetStore(rootDirectoryProvider: () async => tempDir),
      createRemoteRecord:
          createRemoteRecord ??
          ({
            required userId,
            required thumbBase64,
            String? drugCode,
            String? approvalNo,
            String? productName,
            int? takenAt,
          }) async => const IdResult(id: ''),
    );
  }

  setUp(() async {
    await AppDatabase.instance.useTestingDatabase(FakeSqfliteDatabase());
    tempDir = await Directory.systemTemp.createTemp('album-local-store-test');
    store = buildStore();
  });

  tearDown(() async {
    await AppDatabase.instance.clearTestingDatabase();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'saveScanRecord stores local image paths and uploads thumbnail for logged-in user',
    () async {
      final uploads = <String>[];
      store = buildStore(
        createRemoteRecord:
            ({
              required userId,
              required thumbBase64,
              String? drugCode,
              String? approvalNo,
              String? productName,
              int? takenAt,
            }) async {
              uploads.add('$userId|$thumbBase64|$productName|$takenAt');
              return const IdResult(id: 'remote-1');
            },
      );

      await store.saveScanRecord(
        userId: 'user-a',
        drugCode: '86900000000001',
        approvalNo: '国药准字H20000001',
        productName: '阿莫西林胶囊',
        imageBytes: base64Decode(_tinyPngBase64),
        imageMimeType: 'image/png',
        preferredThumbBase64: _tinyPngBase64,
        takenAt: 1710000000000,
      );

      final db = await AppDatabase.instance.database;
      final rows = await db.query('album_items');

      expect(rows, hasLength(1));
      expect(rows.first['userId'], 'user-a');
      expect(rows.first['remoteId'], 'remote-1');
      expect(rows.first['imagePath'], isNotEmpty);
      expect(rows.first['thumbPath'], isNotEmpty);
      expect(await File(rows.first['imagePath'] as String).exists(), isTrue);
      expect(await File(rows.first['thumbPath'] as String).exists(), isTrue);
      expect(uploads, hasLength(1));

      final entries = await store.loadEntries(userId: 'user-a');
      expect(entries, hasLength(1));
      expect(entries.single.hasOriginalImage, isTrue);
      expect(entries.single.hasPreviewImage, isTrue);
    },
  );

  test('saveScanRecord keeps guest records local only', () async {
    final uploads = <String>[];
    store = buildStore(
      createRemoteRecord:
          ({
            required userId,
            required thumbBase64,
            String? drugCode,
            String? approvalNo,
            String? productName,
            int? takenAt,
          }) async {
            uploads.add(userId);
            return const IdResult(id: 'remote-guest');
          },
    );

    await store.saveScanRecord(
      userId: '',
      productName: '游客记录',
      imageBytes: base64Decode(_tinyPngBase64),
      imageMimeType: 'image/png',
      preferredThumbBase64: _tinyPngBase64,
      takenAt: 1710000000000,
    );

    final db = await AppDatabase.instance.database;
    final rows = await db.query('album_items');

    expect(rows, hasLength(1));
    expect(rows.first['userId'], '');
    expect(rows.first['remoteId'], isNull);
    expect(rows.first['imagePath'], isNotEmpty);
    expect(uploads, isEmpty);
  });

  test('loadEntries only returns rows from requested user scope', () async {
    await store.saveScanRecord(
      userId: '',
      productName: '游客记录',
      imageBytes: base64Decode(_tinyPngBase64),
      imageMimeType: 'image/png',
      takenAt: 10,
    );
    await store.saveScanRecord(
      userId: 'user-a',
      productName: '用户A记录',
      imageBytes: base64Decode(_tinyPngBase64),
      imageMimeType: 'image/png',
      takenAt: 20,
    );
    await store.saveScanRecord(
      userId: 'user-b',
      productName: '用户B记录',
      imageBytes: base64Decode(_tinyPngBase64),
      imageMimeType: 'image/png',
      takenAt: 30,
    );

    final guestEntries = await store.loadEntries(userId: '');
    final userAEntries = await store.loadEntries(userId: 'user-a');
    final userBEntries = await store.loadEntries(userId: 'user-b');

    expect(guestEntries.map((entry) => entry.productName), ['游客记录']);
    expect(userAEntries.map((entry) => entry.productName), ['用户A记录']);
    expect(userBEntries.map((entry) => entry.productName), ['用户B记录']);
  });

  test('readImageBytes returns original image bytes for rescan', () async {
    await store.saveScanRecord(
      userId: 'user-a',
      productName: '阿莫西林胶囊',
      imageBytes: base64Decode(_tinyPngBase64),
      imageMimeType: 'image/png',
      takenAt: 1710000000000,
    );

    final entry = (await store.loadEntries(userId: 'user-a')).single;
    final bytes = await store.readImageBytes(entry.imagePath);

    expect(bytes, isNotNull);
    expect(base64Encode(bytes!), _tinyPngBase64);
  });
}
