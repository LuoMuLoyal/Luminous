import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/drug.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/stores/my_medicine_repository.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/drug.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/pages/Drug/medicine_detail.dart';
import 'package:luminous/pages/Picker/medicine_picker.dart';
import 'package:luminous/pages/Scan/medicine_scan.dart';

// 药品页
//
// 设计要点：
// - 无顶部色块，直接展示搜索入口 + 快捷入口
// - 下方为"我的药品"列表，使用 SliverList.builder 按需加载
// - 药品可通过手动搜索或拍照识别两种方式添加
/// 药品页。
///
/// 页面上半部分提供药品相关快捷入口，下半部分展示本地“我的药品”列表。
class DrugView extends StatefulWidget {
  /// 创建药品页组件。
  const DrugView({super.key});

  /// 创建药品页对应的状态对象。
  @override
  State<DrugView> createState() => _DrugViewState();
}

/// 药品页状态对象。
///
/// 页面本身不维护复杂业务计算，核心是把顶部快捷入口和本地“我的药品”列表串起来。
class _DrugViewState extends State<DrugView> {
  /// 当前登录用户控制器。
  final UserController _userController = Get.find<UserController>();

  /// 监听登录用户变化的 worker。
  Worker? _userWorker;

  /// 药品页顶部“快捷入口”的配置列表。
  List<DrugQuickEntry> _quickEntries(AppLocalizations? l10n) {
    return [
      DrugQuickEntry(
        entryKey: 'search',
        title: l10n?.drugQuickEntrySearchTitle ?? '手动搜索',
        subtitle: l10n?.drugQuickEntrySearchSubtitle ?? '名称/批准文号',
        icon: Icons.search_rounded,
        color: const Color(0xFF0EA5E9),
        routeName: '/search',
      ),
      DrugQuickEntry(
        entryKey: 'scan',
        title: l10n?.drugQuickEntryScanTitle ?? '药物识别',
        subtitle: l10n?.drugQuickEntryScanSubtitle ?? '拍照识别',
        icon: Icons.camera_alt_outlined,
        color: const Color(0xFF10B981),
        routeName: '',
      ),
      DrugQuickEntry(
        entryKey: 'ai',
        title: l10n?.drugQuickEntryAiTitle ?? 'AI 解读',
        subtitle: l10n?.drugQuickEntryAiSubtitle ?? '用法禁忌',
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xFF6366F1),
        routeName: '',
      ),
    ];
  }

  /// 当前“我的药品”列表的原始数据库行数据。
  List<Map<String, dynamic>> _myMedicines = [];

  /// 当前是否正在加载“我的药品”列表。
  bool _loadingMedicines = false;

  /// 当前是否有新的刷新请求在排队。
  bool _reloadQueued = false;

  /// 当前活跃加载请求的编号。
  int _loadRequestId = 0;

  /// 页面初始化时先加载一次“我的药品”。
  @override
  void initState() {
    super.initState();
    _userWorker = ever<dynamic>(_userController.user, (_) {
      _loadMyMedicines();
    });
    _loadMyMedicines();
  }

  @override
  void dispose() {
    _userWorker?.dispose();
    super.dispose();
  }

  /// 从本地数据库加载“我的药品”列表。
  Future<void> _loadMyMedicines() async {
    final userId = _userId.trim();
    if (_loadingMedicines) {
      _reloadQueued = true;
      return;
    }

    final requestId = ++_loadRequestId;
    setState(() {
      _loadingMedicines = true;
    });
    try {
      /// 先读取当前作用域下的本地缓存。
      final rows = await myMedicineRepository.loadLocalRows(userId: userId);
      if (!_canApplyLoadResult(requestId, userId)) return;
      setState(() {
        _myMedicines = rows;
      });

      if (userId.isNotEmpty) {
        try {
          await myMedicineRepository.syncRemote(userId);
          final syncedRows = await myMedicineRepository.loadLocalRows(
            userId: userId,
          );
          if (!_canApplyLoadResult(requestId, userId)) return;
          setState(() {
            _myMedicines = syncedRows;
          });
        } catch (e) {
          if (!mounted ||
              !_isActiveLoadRequest(requestId) ||
              userId != _userId.trim()) {
            return;
          }
          ToastUtils.instance.showError(context, e);
        }
      }
    } catch (e) {
      if (!mounted ||
          !_isActiveLoadRequest(requestId) ||
          userId != _userId.trim()) {
        return;
      }
      ToastUtils.instance.show(
        context,
        _l10n?.drugLoadFailedToast ?? '加载我的药品失败',
      );
    } finally {
      if (_isActiveLoadRequest(requestId) && mounted) {
        setState(() {
          _loadingMedicines = false;
        });
      }
      if (_isActiveLoadRequest(requestId) && _reloadQueued && mounted) {
        _reloadQueued = false;
        unawaited(_loadMyMedicines());
      }
    }
  }

  /// 当前登录用户 id（未登录时为空字符串）。
  String get _userId => _userController.user.value?.id ?? '';

  AppLocalizations? get _l10n => AppLocalizations.of(context);

  bool _canApplyLoadResult(int requestId, String userId) {
    return mounted &&
        _isActiveLoadRequest(requestId) &&
        userId == _userId.trim();
  }

  bool _isActiveLoadRequest(int requestId) {
    return requestId == _loadRequestId;
  }

  /// 从“我的药品”列表删除一条药品记录。
  ///
  /// 删除完成后会自动重新加载列表并提示用户。
  Future<void> _deleteMedicine(Map<String, dynamic> row) async {
    try {
      await myMedicineRepository.deleteMedicine(row, userId: _userId);
      await _loadMyMedicines();
      if (mounted) {
        ToastUtils.instance.show(
          context,
          _l10n?.drugDeletedToast ?? '已从我的药品中移除',
        );
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.instance.show(
          context,
          _l10n?.drugDeleteFailedToast ?? '删除失败',
        );
      }
    }
  }

  /// 构建药品页 UI。
  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;

    return DrugPage(
      quickEntries: _quickEntries(l10n),
      myMedicines: _myMedicines,
      loadingMedicines: _loadingMedicines,
      onRefresh: _loadMyMedicines,
      onTapSearch: () {
        Navigator.pushNamed(context, '/search').then((_) {
          _loadMyMedicines();
        });
      },
      onTapQuickEntry: _onTapQuick,
      onTapMedicineRow: _openMedicineDetail,
      onDeleteMedicine: _deleteMedicine,
    );
  }

  /// 根据数据库行数据打开药品详情页。
  ///
  /// 这里会先把数据库行转换为 `MedicineItem`，作为详情页初始对象传入。
  void _openMedicineDetail(Map<String, dynamic> row) {
    /// 由数据库行拼装出的药品详情初始对象。
    final item = MedicineItem(
      serialNo: '',
      approvalNo: (row['approvalNo'] ?? '').toString(),
      productName: (row['productName'] ?? '').toString(),
      dosageForm: (row['dosageForm'] ?? '').toString(),
      specification: (row['specification'] ?? '').toString(),
      marketingAuthorizationHolder: '',
      manufacturer: (row['manufacturer'] ?? '').toString(),
      drugCode: (row['drugCode'] ?? '').toString(),
      drugCodeRemark: '',
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicineDetailPage(initialItem: item),
      ),
    );
  }

  /// 处理顶部“快捷入口”点击。
  ///
  /// 有 routeName 的入口直接走命名路由；
  /// 没有 routeName 的入口根据 entryKey 走自定义逻辑。
  void _onTapQuick(DrugQuickEntry entry) {
    if (entry.routeName.isNotEmpty) {
      Navigator.pushNamed(context, entry.routeName).then((_) {
        _loadMyMedicines();
      });
      return;
    }
    if (entry.entryKey == 'scan') {
      openMedicineScanFlow(context, mode: ScanEntryMode.actions).then((_) {
        _loadMyMedicines();
      });
      return;
    }
    if (entry.entryKey == 'ai') {
      _pickAndOpenDetail();
      return;
    }
    ToastUtils.instance.show(
      context,
      _l10n?.homeFeatureDevelopingToast ?? '功能开发中',
    );
  }

  /// 先打开药品选择器，再进入对应药品的详情页。
  ///
  /// 这是“AI 解读”入口的第一步：先让用户选一款药。
  Future<void> _pickAndOpenDetail() async {
    /// 从药品选择器返回的药品对象。
    final item = await Navigator.of(context).push<MedicineItem>(
      MaterialPageRoute<MedicineItem>(
        builder: (_) =>
            MedicinePickerPage(title: _l10n?.drugPickerTitle ?? '选择药品'),
      ),
    );
    if (!mounted) return;
    if (item == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicineDetailPage(initialItem: item),
      ),
    );
  }
}
