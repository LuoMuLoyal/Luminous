import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/api/medicine_api.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/mine/data/browse_history_store.dart';
import 'package:luminous/shared/models/medicine.dart';

typedef FetchMedicineDetail = Future<ApiResult<MedicineItem>> Function({
  String? drugCode,
  String? approvalNo,
  CancelToken? cancelToken,
});

typedef FetchMedicineAiDetail = Future<ApiResult<MedicineAiDetailResult>> Function({
  String? drugCode,
  String? approvalNo,
  bool refresh,
  CancelToken? cancelToken,
});

/// 注入 provider。
final detailFetchProvider = Provider<FetchMedicineDetail>(
  (ref) => MedicineApi.fetchDetail,
);

final aiFetchProvider = Provider<FetchMedicineAiDetail>(
  (ref) => MedicineApi.fetchAiDetail,
);

final detailHistoryStoreProvider = Provider<BrowseHistoryStore>(
  (ref) => browseHistoryStore,
);

/// 药品详情页状态。
class DetailState {
  const DetailState({
    required this.item,
    this.loadingDetail = false,
    this.aiResult,
    this.loadingAi = false,
    this.isClosed = false,
  });

  final MedicineItem item;
  final bool loadingDetail;
  final MedicineAiDetailResult? aiResult;
  final bool loadingAi;
  final bool isClosed;

  DetailState copyWith({
    MedicineItem? item,
    bool? loadingDetail,
    MedicineAiDetailResult? aiResult,
    bool? loadingAi,
    bool? isClosed,
  }) {
    return DetailState(
      item: item ?? this.item,
      loadingDetail: loadingDetail ?? this.loadingDetail,
      aiResult: aiResult ?? this.aiResult,
      loadingAi: loadingAi ?? this.loadingAi,
      isClosed: isClosed ?? this.isClosed,
    );
  }
}

/// 药品详情页状态管理器。
class DetailNotifier extends Notifier<DetailState> {
  CancelToken? _detailCancelToken;
  CancelToken? _aiCancelToken;

  FetchMedicineDetail get _fetchDetail => ref.read(detailFetchProvider);
  FetchMedicineAiDetail get _fetchAiDetail => ref.read(aiFetchProvider);
  BrowseHistoryStore get _historyStore => ref.read(detailHistoryStoreProvider);

  @override
  DetailState build() {
    ref.onDispose(() {
      _detailCancelToken?.cancel('notifier closed');
      _aiCancelToken?.cancel('notifier closed');
    });

    return DetailState(
      item: MedicineItem(
        serialNo: '',
        approvalNo: '',
        productName: '',
        dosageForm: '',
        specification: '',
        marketingAuthorizationHolder: '',
        manufacturer: '',
        drugCode: '',
        drugCodeRemark: '',
      ),
    );
  }

  /// 初始化详情页，设置初始 item 并开始加载。
  void initialize(MedicineItem initialItem) {
    if (state.isClosed) return;
    state = state.copyWith(item: initialItem);
    _recordHistory(initialItem);
    unawaited(loadDetail());
  }

  /// 拉取药品基础详情。返回错误消息供 page 层 toast。
  Future<String?> loadDetail() async {
    if (state.loadingDetail || !state.item.hasIdentity) return null;

    _detailCancelToken?.cancel('new detail request started');
    final cancelToken = CancelToken();
    _detailCancelToken = cancelToken;
    state = state.copyWith(loadingDetail: true);

    try {
      final response = await _fetchDetail(
        drugCode: state.item.drugCode,
        approvalNo: state.item.approvalNo,
        cancelToken: cancelToken,
      );
      if (state.isClosed) return null;
      if (response.result.productName.isNotEmpty) {
        state = state.copyWith(item: response.result);
        _recordHistory(response.result);
      }
    } catch (error) {
      if (state.isClosed || _isCanceledError(error)) return null;
      return _extractError(error);
    } finally {
      if (identical(_detailCancelToken, cancelToken)) {
        _detailCancelToken = null;
      }
      if (!state.isClosed) {
        state = state.copyWith(loadingDetail: false);
      }
    }
    return null;
  }

  /// 拉取 AI 药品解读。返回错误消息供 page 层 toast。
  Future<String?> loadAiDetail({bool refresh = false}) async {
    if (state.loadingAi || !state.item.hasIdentity) return null;

    _aiCancelToken?.cancel('new ai detail request started');
    final cancelToken = CancelToken();
    _aiCancelToken = cancelToken;
    state = state.copyWith(loadingAi: true);

    try {
      final response = await _fetchAiDetail(
        drugCode: state.item.drugCode,
        approvalNo: state.item.approvalNo,
        refresh: refresh,
        cancelToken: cancelToken,
      );
      if (state.isClosed) return null;
      state = state.copyWith(aiResult: response.result);
      if (!response.result.hasText) {
        return 'aiNoContent';
      }
    } catch (error) {
      if (state.isClosed || _isCanceledError(error)) return null;
      if (_isLikelyNetworkFailure(error)) {
        return 'aiNetworkError';
      }
      return _extractError(error);
    } finally {
      if (identical(_aiCancelToken, cancelToken)) {
        _aiCancelToken = null;
      }
      if (!state.isClosed) {
        state = state.copyWith(loadingAi: false);
      }
    }
    return null;
  }

  /// 取消当前 AI 解读请求。返回 toast 消息供 page 层显示。
  String cancelAiDetail() {
    _aiCancelToken?.cancel('user canceled');
    _aiCancelToken = null;
    if (state.loadingAi && !state.isClosed) {
      state = state.copyWith(loadingAi: false);
    }
    return _cancelToastText();
  }

  String _cancelToastText() {
    return '已取消获取详细信息';
  }

  bool _isCanceledError(Object error) {
    if (error is DioException && error.type == DioExceptionType.cancel) {
      return true;
    }
    final text = error.toString().toLowerCase();
    return text.contains('cancel') || text.contains('canceled');
  }

  bool _isLikelyNetworkFailure(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('timeout') ||
        text.contains('socket') ||
        text.contains('connection') ||
        text.contains('network') ||
        text.contains('xmlhttprequest') ||
        text.contains('failed host lookup');
  }

  String? _extractError(Object error) {
    final s = error.toString();
    if (s.isEmpty) return null;
    return s;
  }

  Future<void> _recordHistory(MedicineItem item) async {
    if (!item.hasIdentity) return;
    try {
      await _historyStore.recordMedicine(
        userId: ref.read(currentUserProvider)?.id,
        item: item,
      );
    } catch (_) {}
  }
}

/// 药品详情页 provider。
final detailProvider = NotifierProvider<DetailNotifier, DetailState>(() {
  return DetailNotifier();
});
