import 'package:get/get.dart';
import 'package:luminous/features/auth/data/user_session_store.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/stores/browse_history_store.dart';
import 'package:luminous/stores/token_manager.dart';
import 'package:luminous/stores/album_asset_store.dart';
import 'package:luminous/utils/notification_service.dart';
import 'package:luminous/viewmodels/auth.dart';

/// 全局用户态控制器。
///
/// 使用 GetX 管理当前登录用户，并负责和本地持久化做同步。
class UserController extends GetxController {
  UserController({
    UserSessionStore? sessionStore,
    Future<void> Function()? cancelNotifications,
  }) : _sessionStore = sessionStore ?? UserSessionStore.lazy(),
       _cancelNotifications =
           cancelNotifications ?? NotificationService.instance.cancelAll;

  /// 当前登录用户的响应式容器。
  ///
  /// 未登录时值为 `null`，已登录时保存 `UserSafe`。
  final Rxn<UserSafe> user = Rxn<UserSafe>();
  final RxBool sessionReady = true.obs;
  final UserSessionStore _sessionStore;
  final Future<void> Function() _cancelNotifications;
  final BrowseHistoryStore _browseHistoryStore = BrowseHistoryStore.instance;
  final AlbumAssetStore _albumAssetStore = AlbumAssetStore();
  Future<UserSafe?> Function()? _restoreUser;
  Future<void> Function(UserSafe user)? _persistUser;
  Future<void> Function()? _clearUser;

  /// 当前是否处于登录状态。
  ///
  /// 通过用户对象是否存在且有有效数据来判断。
  bool get isLoggedIn => user.value?.hasData ?? false;

  /// 标记当前会话仍在恢复中。
  void markSessionPending() {
    sessionReady.value = false;
  }

  /// 将旧 GetX 控制器桥接到新的 Riverpod 会话状态。
  void attachSessionBridge({
    required Future<UserSafe?> Function() restoreUser,
    required Future<void> Function(UserSafe user) persistUser,
    required Future<void> Function() clearUser,
  }) {
    _restoreUser = restoreUser;
    _persistUser = persistUser;
    _clearUser = clearUser;
  }

  /// 从本地缓存恢复登录用户。
  ///
  /// 应用启动时由 `main()` 调用一次。
  Future<void> init() async {
    try {
      user.value = await (_restoreUser?.call() ?? _sessionStore.restoreUser());
    } catch (_) {
      user.value = null;
    } finally {
      sessionReady.value = true;
    }
  }

  /// 更新当前用户并持久化到本地。
  ///
  /// 一般在登录成功后调用。
  Future<void> setUser(UserSafe nextUser) async {
    user.value = nextUser;
    final persistUser = _persistUser;
    if (persistUser != null) {
      await persistUser(nextUser);
    } else {
      await _sessionStore.persistUser(nextUser);
    }
  }

  /// 清空当前用户状态并删除本地持久化数据。
  ///
  /// 一般在主动退出登录时调用。
  Future<void> logout() async {
    user.value = null;
    final clearUser = _clearUser;
    if (clearUser != null) {
      await clearUser();
    } else {
      await _sessionStore.clearUser();
    }
    await tokenManager.deleteToken();
    await _cancelNotifications();
  }

  /// 当账户被真正注销时，清空当前用户相关的本地缓存与资产文件。
  Future<void> purgeDeletedAccountData(String userId) async {
    final uid = userId.trim();
    if (uid.isEmpty) {
      return;
    }

    final db = await AppDatabase.instance.database;
    final albumRows = await db.query(
      'album_items',
      columns: ['imagePath', 'thumbPath'],
      where: 'userId = ?',
      whereArgs: [uid],
    );

    await _albumAssetStore.deletePaths(
      albumRows.expand((row) sync* {
        final imagePath = (row['imagePath'] ?? '').toString().trim();
        final thumbPath = (row['thumbPath'] ?? '').toString().trim();
        if (imagePath.isNotEmpty) {
          yield imagePath;
        }
        if (thumbPath.isNotEmpty) {
          yield thumbPath;
        }
      }),
    );

    await db.transaction((txn) async {
      await txn.delete('my_medicines', where: 'userId = ?', whereArgs: [uid]);
      await txn.delete('album_items', where: 'userId = ?', whereArgs: [uid]);
      await txn.delete('reminders', where: 'userId = ?', whereArgs: [uid]);
      await txn.delete('checkins', where: 'userId = ?', whereArgs: [uid]);
      await txn.delete(
        'checkin_overrides',
        where: 'userId = ?',
        whereArgs: [uid],
      );
      await txn.delete(
        'today_reminder_snapshots',
        where: 'userId = ?',
        whereArgs: [uid],
      );
    });

    await _browseHistoryStore.clear(userId: uid);
  }
}
