import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/report/data/datasources/report_ai_summary_remote_data_source.dart';
import 'package:luminous/features/report/domain/entities/report_ai_summary.dart';

abstract interface class ReportAiSummaryRepository {
  Future<ReportAiSummary> generate();
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
  Future<ReportAiSummary> generate() async {
    final dto = await dataSource.generate();
    return ReportAiSummary(
      range: dto.range.value,
      startDate: dto.startDate,
      endDate: dto.endDate,
      generatedAt: DateTime.parse(dto.generatedAt),
      summary: dto.summary,
      bullets: dto.bullets.map(_mapBullet).toList(growable: false),
      actionLabel: dto.actionLabel,
      confidenceNote: dto.confidenceNote,
    );
  }

  ReportAiSummaryBullet _mapBullet(lucent.ReportWeeklySummaryBulletDto dto) {
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
      ReportAiSummaryBulletKind.medication => AppColorTokens.cyanDeep,
      ReportAiSummaryBulletKind.hydration => AppColorTokens.link,
      ReportAiSummaryBulletKind.sleep => AppColorTokens.violet,
      ReportAiSummaryBulletKind.general => AppColorTokens.health,
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
