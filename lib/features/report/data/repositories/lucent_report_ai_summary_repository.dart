import 'package:luminous/core/design/app_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/report/data/datasources/report_ai_summary_remote_data_source.dart';
import 'package:luminous/features/report/domain/entities/report_ai_summary.dart';

sealed class ReportAiGenerationEvent {
  const ReportAiGenerationEvent();
}

class ReportAiGenerationSummaryEvent extends ReportAiGenerationEvent {
  const ReportAiGenerationSummaryEvent(this.summary);

  final String summary;
}

class ReportAiGenerationResultEvent extends ReportAiGenerationEvent {
  const ReportAiGenerationResultEvent(this.summary);

  final ReportAiSummary summary;
}

abstract interface class ReportAiSummaryRepository {
  Future<ReportAiSummary> generate(
    ReportAiSummaryRange range, {
    String? startDate,
    String? endDate,
  });
  Stream<ReportAiGenerationEvent> generateStream(
    ReportAiSummaryRange range, {
    String? startDate,
    String? endDate,
  });
}

final reportAiSummaryRemoteDataSourceProvider =
    Provider<ReportAiSummaryRemoteDataSource>((ref) {
      final api = ref.watch(lucentReportsApiProvider);
      final dio = ref.watch(lucentDioClientProvider).dio;
      return ReportAiSummaryRemoteDataSource(api: api, dio: dio);
    });

final reportAiSummaryRepositoryProvider = Provider<ReportAiSummaryRepository>((
  ref,
) {
  final dataSource = ref.watch(reportAiSummaryRemoteDataSourceProvider);
  return LucentReportAiSummaryRepository(dataSource: dataSource);
});

class LucentReportAiSummaryRepository implements ReportAiSummaryRepository {
  LucentReportAiSummaryRepository({required this.dataSource});

  final ReportAiSummaryRemoteDataSource dataSource;

  @override
  Future<ReportAiSummary> generate(
    ReportAiSummaryRange range, {
    String? startDate,
    String? endDate,
  }) async {
    await for (final event in generateStream(
      range,
      startDate: startDate,
      endDate: endDate,
    )) {
      if (event is ReportAiGenerationResultEvent) {
        return event.summary;
      }
    }
    throw StateError('报告 AI 流式响应已结束，但没有返回最终结果。');
  }

  @override
  Stream<ReportAiGenerationEvent> generateStream(
    ReportAiSummaryRange range, {
    String? startDate,
    String? endDate,
  }) async* {
    await for (final event in dataSource.generateStream(
      range,
      startDate: startDate,
      endDate: endDate,
    )) {
      switch (event) {
        case ReportAiRemoteSummaryEvent():
          yield ReportAiGenerationSummaryEvent(event.summary);
        case ReportAiRemoteResultEvent():
          yield ReportAiGenerationResultEvent(_mapSummary(event.dto));
      }
    }
  }

  ReportAiSummary _mapSummary(lucent.ReportSummaryDataDto dto) {
    return ReportAiSummary(
      range: _mapRange(dto.range),
      startDate: dto.startDate,
      endDate: dto.endDate,
      generatedAt: DateTime.parse(dto.generatedAt),
      summary: dto.summary,
      bullets: dto.bullets.map(_mapBullet).toList(growable: false),
      actionLabel: dto.actionLabel,
      action: dto.action,
      confidenceNote: dto.confidenceNote,
    );
  }

  ReportAiSummaryRange _mapRange(lucent.ReportSummaryDataDtoRangeEnum range) {
    return switch (range) {
      lucent.ReportSummaryDataDtoRangeEnum.last30Days =>
        ReportAiSummaryRange.last30Days,
      lucent.ReportSummaryDataDtoRangeEnum.custom =>
        ReportAiSummaryRange.custom,
      _ => ReportAiSummaryRange.last7Days,
    };
  }

  ReportAiSummaryBullet _mapBullet(lucent.ReportSummaryBulletDto dto) {
    final kind = switch (dto.kind.value) {
      'medication' => ReportAiSummaryBulletKind.medication,
      'hydration' => ReportAiSummaryBulletKind.hydration,
      'sleep' => ReportAiSummaryBulletKind.sleep,
      _ => ReportAiSummaryBulletKind.general,
    };

    return ReportAiSummaryBullet(
      kind: kind,
      text: dto.text,
      color: _bulletColor(kind),
      icon: _bulletIcon(kind),
    );
  }

  Color _bulletColor(ReportAiSummaryBulletKind kind) {
    return switch (kind) {
      ReportAiSummaryBulletKind.medication => Color(0xFF0F766E),
      ReportAiSummaryBulletKind.hydration => Color(0xFF16A34A),
      ReportAiSummaryBulletKind.sleep => Color(0xFF7C3AED),
      ReportAiSummaryBulletKind.general => Color(0xFF15803D),
    };
  }

  IconData _bulletIcon(ReportAiSummaryBulletKind kind) {
    return switch (kind) {
      ReportAiSummaryBulletKind.medication => Icons.medication_rounded,
      ReportAiSummaryBulletKind.hydration => Icons.water_drop_rounded,
      ReportAiSummaryBulletKind.sleep => Icons.nightlight_round,
      ReportAiSummaryBulletKind.general => Icons.lightbulb_outline_rounded,
    };
  }
}
