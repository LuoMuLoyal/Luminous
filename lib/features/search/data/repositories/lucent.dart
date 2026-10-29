import 'dart:async';
import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/database/cache_constants.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/search_result.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/app_log.dart';
import 'package:luminous/core/network/contract/failure.dart';
import 'package:luminous/features/search/data/datasources/medicine_search.dart';
import 'package:luminous/features/search/data/mappers/medicine_search.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/domain/repositories/search.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lucent.g.dart';

/// Lucent-backed medicine search repository.
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; a legal empty result set stays a Right.
/// Protocol violations (non-Problem-Details error bodies) surface as a thrown
/// `FormatException` from `run()` instead of a Left.
class LucentMedicineSearchRepository implements MedicineSearchRepository {
  LucentMedicineSearchRepository({
    required this.dataSource,
    required this.mapper,
    required this.cacheDao,
  });

  final MedicineSearchRemoteDataSource dataSource;
  final MedicineSearchMapper mapper;
  final SearchResultDao cacheDao;

  /// Background refresh throttle per query scope.
  final Map<String, DateTime> _lastRefresh = {};

  @override
  TaskEither<LucentFailure, List<MedicineSearchResult>> search({
    required String query,
    required MedicineSearchSource source,
    int page = 1,
    int pageSize = 20,
  }) {
    return TaskEither.tryCatch(() async {
      final scope = '${source.name}|$query|$page|$pageSize';

      // Cache-first: re-running the same query renders instantly.
      final cached = await cacheDao.fetch(scope);
      if (cached != null) {
        _refreshInBackground(
          scope,
          query: query,
          source: source,
          page: page,
          pageSize: pageSize,
        );
        return (jsonDecode(cached) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(MedicineSearchResult.fromJson)
            .toList();
      }

      final results = await _searchRemote(
        query: query,
        source: source,
        page: page,
        pageSize: pageSize,
      );
      await cacheDao.replace(
        scope,
        jsonEncode(results.map((r) => r.toJson()).toList()),
      );
      return results;
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  Future<List<MedicineSearchResult>> _searchRemote({
    required String query,
    required MedicineSearchSource source,
    required int page,
    required int pageSize,
  }) async {
    final response = await dataSource.search(
      source: source.name,
      query: query,
      page: page,
      pageSize: pageSize,
    );
    return response.items.map(mapper.dtoToResult).toList();
  }

  /// Best-effort refresh: throttled, failures only logged.
  void _refreshInBackground(
    String scope, {
    required String query,
    required MedicineSearchSource source,
    required int page,
    required int pageSize,
  }) {
    final now = DateTime.now();
    final last = _lastRefresh[scope];
    if (last != null && now.difference(last) < backgroundRefreshThrottle) {
      return;
    }
    _lastRefresh[scope] = now;

    unawaited(
      Future(() async {
        try {
          final results = await _searchRemote(
            query: query,
            source: source,
            page: page,
            pageSize: pageSize,
          );
          await cacheDao.replace(
            scope,
            jsonEncode(results.map((r) => r.toJson()).toList()),
          );
        } catch (e) {
          appLog.warning('Search background refresh failed: $e');
        }
      }),
    );
  }

  /// 桌面端旧预览面板遗留的详情拉取（F-11 去造假后保留但**不接入主路径**）。
  ///
  /// 映射逻辑原样保留仅作参考：subtitle 按 `\n` 拆分充当 `conditions`、
  /// `checklist` 恒为空——这些都不是真实临床/安全内容，移动端不得复制该造假
  /// 模式；真实内容走 `medicine_detail` 链路与药品详情页。
  ///
  /// 失败语义（替换原 catch→null 吞错）：4xx/5xx 服务端失败（含资源不存在）
  /// 为 Left，保留 Problem Details 的 code/status，不本地猜 status；网络类
  /// 失败为 Left(network)；成功响应为 Right。空/无预览数据是合法 Right，
  /// 不再是错误。
  @override
  TaskEither<LucentFailure, MedicineSearchSafetyPreview?> fetchDetail(
    String id,
    MedicineSearchSource source,
  ) {
    return TaskEither.tryCatch(() async {
      final response = await dataSource.getDetail(id: id, source: source.name);

      return MedicineSearchSafetyPreview(
        title: response.name,
        conditions: response.subtitle?.toString().split('\n') ?? [],
        checklist: const [],
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }
}

/// Provider for LucentMedicineSearchRepository.
@riverpod
LucentMedicineSearchRepository lucentMedicineSearchRepository(Ref ref) {
  return LucentMedicineSearchRepository(
    dataSource: ref.watch(medicineSearchRemoteDataSourceProvider),
    mapper: MedicineSearchMapper(),
    cacheDao: ref.watch(searchResultDaoProvider),
  );
}

/// Provider that exposes the repository through the interface.
@riverpod
MedicineSearchRepository medicineSearchRepository(Ref ref) {
  return ref.watch(lucentMedicineSearchRepositoryProvider);
}

@riverpod
MedicineSearchRemoteDataSource medicineSearchRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).medicines;
  return MedicineSearchRemoteDataSource(api: api);
}
