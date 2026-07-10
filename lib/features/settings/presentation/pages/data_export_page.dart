import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/errors/result.dart';
import 'package:luminous/core/errors/run_guarded.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:lucent_api/api/export.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/providers/data_export_controller.dart';
import 'package:luminous/l10n/app_localizations.dart';

import 'package:luminous/core/design/design.dart';

class DataExportPage extends ConsumerWidget {
  const DataExportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    final exportAsync = ref.watch(dataExportControllerProvider);
    final export = exportAsync.asData?.value;

    final width = MediaQuery.sizeOf(context).width;
    final content = ResponsiveContentFrame(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: width < Breakpoints.mobile ? 24 : 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCard.raw(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsExportDescription,
                    style: TypographyToken.level4
                        .body(context)
                        .copyWith(color: colors.foreground),
                  ),
                  const SizedBox(height: Spacing.level5),
                  _StatusRow(
                    label: l10n.mineSettingExportValue,
                    value: _statusLabel(l10n, export),
                  ),
                  const SizedBox(height: Spacing.level5),
                  _buildActionButton(context, ref, export, l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return PageScaffold(
      title: l10n.mineSettingExportTitle,
      child: SingleChildScrollView(child: content),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    DataExportRequestDataDto? export,
    AppLocalizations l10n,
  ) {
    final status = dataExportUiStatusForRequest(export);
    final downloadUrl = export?.downloadUrl;
    final hasDownloadLink =
        downloadUrl != null && downloadUrl.trim().isNotEmpty;
    final requestInFlight = ref.watch(dataExportRequestInFlightProvider);

    if (requestInFlight.inFlight) {
      return const SizedBox.square(
        dimension: 18,
        child: Center(child: FCircularProgress()),
      );
    }

    if (status == DataExportUiStatus.completed && hasDownloadLink) {
      return SizedBox(
        width: double.infinity,
        child: FButton(
          onPress: () => launchUrl(
            Uri.parse(downloadUrl),
            mode: LaunchMode.externalApplication,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FLucideIcons.chevronDown, size: 18),
              const SizedBox(width: Spacing.level2),
              Text(l10n.mineExportDownloadButton),
            ],
          ),
        ),
      );
    }

    if (status == DataExportUiStatus.completedLinkMissing ||
        status == DataExportUiStatus.failed) {
      return SizedBox(
        width: double.infinity,
        child: FButton(
          variant: FButtonVariant.outline,
          onPress: () => _requestExport(context, ref),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FLucideIcons.chevronsUpDown, size: 18),
              const SizedBox(width: Spacing.level2),
              Text(l10n.mineExportRegenerateButton),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FButton(
        onPress:
            status == DataExportUiStatus.idle ||
                status == DataExportUiStatus.unavailable
            ? () => _requestExport(context, ref)
            : null,
        child: Text(
          status == DataExportUiStatus.idle
              ? l10n.settingsExportRequestButton
              : l10n.mineExportStatusPending,
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, DataExportRequestDataDto? export) {
    return switch (dataExportUiStatusForRequest(export)) {
      DataExportUiStatus.idle => l10n.mineSettingExportValue,
      DataExportUiStatus.requested => l10n.mineExportStatusRequested,
      DataExportUiStatus.processing => l10n.mineExportStatusPending,
      DataExportUiStatus.completed => l10n.mineExportStatusCompleted,
      DataExportUiStatus.completedLinkMissing =>
        l10n.mineExportStatusLinkMissing,
      DataExportUiStatus.failed => l10n.mineExportStatusFailed,
      DataExportUiStatus.unavailable => l10n.mineExportStatusUnavailable,
    };
  }

  Future<void> _requestExport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await runGuarded(
      ref: ref,
      tag: 'DataExportPage._requestExport',
      action: () =>
          ref.read(dataExportControllerProvider.notifier).requestExport(),
    );
    if (!context.mounted) return;
    switch (result) {
      case Success(:final value):
        switch (dataExportUiStatusForRequest(value)) {
          case DataExportUiStatus.completed:
            await AppToast.show(context, l10n.mineExportStatusCompleted);
          case DataExportUiStatus.completedLinkMissing:
            await AppToast.show(context, l10n.reportExportLinkMissingToast);
          case DataExportUiStatus.failed:
          case DataExportUiStatus.unavailable:
            await AppToast.show(
              context,
              value?.errorMessage?.isNotEmpty == true
                  ? value?.errorMessage ?? ''
                  : dataExportUiStatusForRequest(value) ==
                        DataExportUiStatus.unavailable
                  ? l10n.mineExportStatusUnavailable
                  : l10n.mineExportStatusFailed,
            );
          case DataExportUiStatus.requested:
            await AppToast.show(context, l10n.mineExportRequested);
          case DataExportUiStatus.processing:
            await AppToast.show(context, l10n.mineExportStatusPending);
          case DataExportUiStatus.idle:
            await AppToast.show(context, l10n.mineExportStatusFailed);
        }
      case Failure(:final error):
        await AppToast.show(
          context,
          '${l10n.mineExportStatusFailed}: ${error.message}',
        );
    }
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Row(
      children: [
        Text(
          label,
          style: TypographyToken.level4
              .body(context)
              .copyWith(color: colors.foreground),
        ),
        const Spacer(),
        Text(
          value,
          style: TypographyToken.level4
              .body(context)
              .copyWith(color: colors.foreground, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
