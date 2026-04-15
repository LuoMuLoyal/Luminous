import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:luminous/api/reminder_api.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/stores/reminder_local_gateway.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/app_i18n_text.dart';
import 'package:luminous/utils/loading_utils.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/reminder.dart';

/// 用药提醒列表页控制器。
///
/// 页面只从本地 SQLite 回流的数据渲染，远端同步完成后统一走本地 revision
/// 重新触发一次读取。
class ReminderListController extends GetxController {
  ReminderListController({
    UserController? userController,
    ReminderLocalGateway? reminderGateway,
  }) : _userController = userController ?? Get.find<UserController>(),
       _reminderGateway = reminderGateway ?? reminderLocalGateway;

  final UserController _userController;
  final ReminderLocalGateway _reminderGateway;

  Worker? _userWorker;
  StreamSubscription<int>? _revisionSubscription;
  bool _loading = false;
  bool _syncing = false;
  String? _error;
  List<ReminderPlan> _items = const <ReminderPlan>[];
  bool _reloadQueued = false;
  bool _syncQueued = false;
  int _loadRequestId = 0;
  final Set<String> _busyReminderIds = <String>{};
  bool _seedingDefaults = false;

  bool get loading => _loading || _syncing;
  String? get error => _error;
  List<ReminderPlan> get items => _items;
  String get userId => _userController.user.value?.id ?? '';
  bool get isLoggedIn => _userController.isLoggedIn && userId.trim().isNotEmpty;
  int get enabledCount => _items.where((item) => item.enabled).length;
  int get disabledCount => _items.length - enabledCount;

  @override
  void onInit() {
    super.onInit();
    _userWorker = ever<dynamic>(_userController.user, (_) {
      _handleUserChanged();
    });
    _handleUserChanged();
  }

  @override
  void onClose() {
    _userWorker?.dispose();
    _revisionSubscription?.cancel();
    super.onClose();
  }

  /// 只从本地仓库读取当前用户提醒列表。
  Future<void> load() async {
    final scopedUserId = userId.trim();
    if (scopedUserId.isEmpty) {
      _items = const <ReminderPlan>[];
      _error = null;
      _loading = false;
      _reloadQueued = false;
      _busyReminderIds.clear();
      update();
      return;
    }

    if (_loading) {
      _reloadQueued = true;
      return;
    }

    final requestId = ++_loadRequestId;
    _loading = true;
    update();

    try {
      final items = await _reminderGateway.loadPlans(scopedUserId);
      if (!_canApplyLoadResult(requestId, scopedUserId)) {
        return;
      }
      final sorted = _sortedPlans(items);
      if (sorted.isEmpty) {
        _items = await _seedDefaultPlansIfNeeded(scopedUserId, requestId);
      } else {
        _items = sorted;
      }
      _error = null;
    } catch (error) {
      if (!_canApplyLoadResult(requestId, scopedUserId)) {
        return;
      }
      _error = MessageUtils.extractError(error);
      _items = const <ReminderPlan>[];
    } finally {
      if (_isActiveLoadRequest(requestId) && !isClosed) {
        _loading = false;
        update();
      }
      if (_isActiveLoadRequest(requestId) && _reloadQueued && !isClosed) {
        _reloadQueued = false;
        unawaited(load());
      }
    }
  }

  /// 触发一次远端同步，成功后仍通过本地数据回流更新 UI。
  Future<void> sync() async {
    final scopedUserId = userId.trim();
    if (scopedUserId.isEmpty) {
      return;
    }

    if (_syncing) {
      _syncQueued = true;
      return;
    }

    _syncing = true;
    _error = null;
    update();

    try {
      await _reminderGateway.syncRemoteToLocal(scopedUserId);
      if (!isClosed && scopedUserId == userId.trim()) {
        await load();
      }
    } catch (error) {
      if (!isClosed && scopedUserId == userId.trim()) {
        _error = MessageUtils.extractError(error);
        update();
      }
    } finally {
      if (!isClosed && scopedUserId == userId.trim()) {
        _syncing = false;
        update();
      }
      if (_syncQueued && !isClosed && scopedUserId == userId.trim()) {
        _syncQueued = false;
        unawaited(sync());
      }
    }
  }

  /// 接住编辑页返回的新结果，只写本地仓库，再由仓库回流刷新页面。
  Future<void> applySavedPlan(ReminderPlan plan) async {
    final scopedUserId = userId.trim();
    if (scopedUserId.isEmpty) {
      return;
    }
    final planUserId = plan.userId.trim();
    if (planUserId.isNotEmpty && planUserId != scopedUserId) {
      await sync();
      return;
    }

    await _reminderGateway.upsertLocalPlan(scopedUserId, plan);
    if (!isClosed) {
      await load();
    }
  }

  /// 切换提醒启用状态，并在远端成功后回写本地 SQLite。
  Future<void> toggleEnabled(ReminderPlan plan, bool enabled) async {
    await _runWithBusyReminder(plan.id, () async {
      final scopedUserId = userId.trim();
      if (scopedUserId.isEmpty) {
        return;
      }

      try {
        final next = await ReminderApi.upsert(
          userId: scopedUserId,
          id: plan.id,
          time: plan.time,
          drugCode: plan.drugCode,
          approvalNo: plan.approvalNo,
          productName: plan.productName,
          medicines: plan.medicines,
          dosage: plan.dosage,
          subtitle: plan.subtitle,
          enabled: enabled,
          repeatRule: plan.repeatRule,
          method: plan.method,
          startDate: plan.startDate,
          endDate: plan.endDate,
        );
        if (isClosed) {
          return;
        }
        await _reminderGateway.upsertLocalPlan(scopedUserId, next.result);
        if (!isClosed) {
          await load();
        }
      } catch (error) {
        if (!isClosed) {
          _showError(error);
        }
      }
    });
  }

  /// 删除提醒计划，并在远端成功后通过本地仓库回流更新。
  Future<void> deletePlan(ReminderPlan plan) async {
    await _runWithBusyReminder(plan.id, () async {
      final scopedUserId = userId.trim();
      if (scopedUserId.isEmpty) {
        return;
      }

      try {
        await ReminderApi.delete(userId: scopedUserId, id: plan.id);
        if (isClosed) {
          return;
        }

        await _reminderGateway.deleteLocalPlan(scopedUserId, plan.id);
        if (!isClosed) {
          await load();
          _showToast(_l10n?.reminderDeletedToast ?? '已删除');
        }
      } catch (error) {
        if (!isClosed) {
          _showError(error);
        }
      }
    });
  }

  bool isBusy(String reminderId) {
    return _busyReminderIds.contains(reminderId.trim());
  }

  void _handleUserChanged() {
    _bindRevision();
    if (isLoggedIn) {
      unawaited(_loadThenSync());
      return;
    }
    unawaited(load());
  }

  Future<void> _loadThenSync() async {
    await load();
    if (!isClosed && isLoggedIn) {
      await sync();
    }
  }

  Future<List<ReminderPlan>> _seedDefaultPlansIfNeeded(
    String userId,
    int requestId,
  ) async {
    if (_seedingDefaults || !_canApplyLoadResult(requestId, userId)) {
      return const <ReminderPlan>[];
    }
    _seedingDefaults = true;
    try {
      final presets = _defaultPresetSeedData();
      for (final preset in presets) {
        if (!_canApplyLoadResult(requestId, userId)) {
          return const <ReminderPlan>[];
        }
        await ReminderApi.upsert(
          userId: userId,
          time: preset.time,
          productName: preset.productName,
          subtitle: preset.subtitle,
          enabled: false,
          repeatRule: 'daily',
          method: 'notification',
        );
      }
      await _reminderGateway.syncRemoteToLocal(userId);
      final next = await _reminderGateway.loadPlans(userId);
      return _sortedPlans(next);
    } finally {
      _seedingDefaults = false;
    }
  }

  List<({String time, String productName, String subtitle})>
  _defaultPresetSeedData() {
    final l10n = _l10n;
    final firstTitle =
        l10n?.homeFallbackReminder1Title ??
        AppI18nText.pick(zh: '08:30 维生素D', en: '08:30 Vitamin D');
    final secondTitle =
        l10n?.homeFallbackReminder2Title ??
        AppI18nText.pick(zh: '19:30 阿莫西林', en: '19:30 Amoxicillin');
    final thirdTitle =
        l10n?.homeFallbackReminder3Title ??
        AppI18nText.pick(zh: '22:00 血压记录', en: '22:00 Blood Pressure Log');
    final first = _splitTitle(firstTitle);
    final second = _splitTitle(secondTitle);
    final third = _splitTitle(thirdTitle);
    return <({String time, String productName, String subtitle})>[
      (
        time: first.time.isEmpty ? '08:30' : first.time,
        productName: first.productName,
        subtitle:
            l10n?.homeFallbackReminder1Subtitle ??
            AppI18nText.pick(
              zh: '早餐后服用 1 粒',
              en: 'Take 1 capsule after breakfast',
            ),
      ),
      (
        time: second.time.isEmpty ? '19:30' : second.time,
        productName: second.productName,
        subtitle:
            l10n?.homeFallbackReminder2Subtitle ??
            AppI18nText.pick(
              zh: '晚餐后服用 1 粒',
              en: 'Take 1 capsule after dinner',
            ),
      ),
      (
        time: third.time.isEmpty ? '22:00' : third.time,
        productName: third.productName,
        subtitle:
            l10n?.homeFallbackReminder3Subtitle ??
            AppI18nText.pick(
              zh: '睡前记录并上传',
              en: 'Record and upload before sleep',
            ),
      ),
    ];
  }

  ({String time, String productName}) _splitTitle(String rawTitle) {
    final text = rawTitle.trim();
    final firstSpace = text.indexOf(' ');
    if (firstSpace <= 0) {
      return (
        time: '',
        productName: text.isEmpty
            ? AppI18nText.pick(zh: '用药提醒', en: 'Medication reminder')
            : text,
      );
    }
    final maybeTime = text.substring(0, firstSpace).trim();
    final maybeName = text.substring(firstSpace + 1).trim();
    if (!RegExp(r'^\d{1,2}:\d{2}$').hasMatch(maybeTime)) {
      return (time: '', productName: text);
    }
    return (
      time: maybeTime,
      productName: maybeName.isEmpty
          ? AppI18nText.pick(zh: '用药提醒', en: 'Medication reminder')
          : maybeName,
    );
  }

  void _bindRevision() {
    _revisionSubscription?.cancel();
    final scopedUserId = userId.trim();
    if (scopedUserId.isEmpty) {
      return;
    }
    _revisionSubscription = _reminderGateway.watchRevision(scopedUserId).listen(
      (_) {
        if (!isClosed) {
          unawaited(load());
        }
      },
    );
  }

  Future<void> _runWithBusyReminder(
    String reminderId,
    Future<void> Function() task,
  ) async {
    final normalizedId = reminderId.trim();
    if (normalizedId.isEmpty) {
      await task();
      return;
    }
    if (_busyReminderIds.contains(normalizedId)) {
      return;
    }

    _busyReminderIds.add(normalizedId);
    if (!isClosed) {
      update();
    }
    try {
      await task();
    } finally {
      _busyReminderIds.remove(normalizedId);
      if (!isClosed) {
        update();
      }
    }
  }

  List<ReminderPlan> _sortedPlans(Iterable<ReminderPlan> items) {
    return List<ReminderPlan>.from(items)
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  bool _canApplyLoadResult(int requestId, String scopedUserId) {
    return !isClosed &&
        _isActiveLoadRequest(requestId) &&
        scopedUserId == userId.trim();
  }

  bool _isActiveLoadRequest(int requestId) {
    return requestId == _loadRequestId;
  }

  AppLocalizations? get _l10n {
    final context = _context;
    if (context == null) {
      return null;
    }
    return AppLocalizations.of(context);
  }

  BuildContext? get _context => LoadingUtils.navigatorKey.currentContext;

  void _showToast(String message) {
    final context = _context;
    if (context == null) {
      return;
    }
    ToastUtils.instance.show(context, message);
  }

  void _showError(Object error, {String? fallback}) {
    final context = _context;
    if (context == null) {
      return;
    }
    ToastUtils.instance.showError(context, error, fallback: fallback);
  }
}
