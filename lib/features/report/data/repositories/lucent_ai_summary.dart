import 'package:luminous/core/design/semantic_color.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/api/export.dart' as lucent;
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/report/data/datasources/ai_summary_remote.dart';
import 'package:luminous/features/report/domain/entities/ai_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lucent_ai_summary.g.dart';

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

@riverpod
ReportAiSummaryRemoteDataSource reportAiSummaryRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).reports;
  final dio = ref.watch(lucentDioClientProvider).dio;
  return ReportAiSummaryRemoteDataSource(api: api, dio: dio);
}

@riverpod
ReportAiSummaryRepository reportAiSummaryRepository(Ref ref) {
  final dataSource = ref.watch(reportAiSummaryRemoteDataSourceProvider);
  return LucentReportAiSummaryRepository(dataSource: dataSource);
}

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

  ReportAiSummaryRange _mapRange(lucent.ReportSummaryDataDtoRangeRange range) {
    return switch (range) {
      lucent.ReportSummaryDataDtoRangeRange.last30Days =>
        ReportAiSummaryRange.last30Days,
      lucent.ReportSummaryDataDtoRangeRange.custom =>
        ReportAiSummaryRange.custom,
      _ => ReportAiSummaryRange.last7Days,
    };
  }

  ReportAiSummaryBullet _mapBullet(lucent.ReportSummaryBulletDto dto) {
    final kind = switch (dto.kind.json ?? '') {
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

  SemanticColor _bulletColor(ReportAiSummaryBulletKind kind) =>
      SemanticColor.primary;

  IconData _bulletIcon(ReportAiSummaryBulletKind kind) {
    return switch (kind) {
      ReportAiSummaryBulletKind.medication => FLucideIcons.pill,
      ReportAiSummaryBulletKind.hydration => FLucideIcons.droplets,
      ReportAiSummaryBulletKind.sleep => FLucideIcons.moon,
      ReportAiSummaryBulletKind.general => FLucideIcons.lightbulb,
    };
  }
}
