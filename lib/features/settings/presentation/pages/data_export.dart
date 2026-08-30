import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/auth/sensitive_action_password_resolver.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

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
          vertical: width < Breakpoints.mobile
              ? Spacing.level6
              : Spacing.level7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsExportDescription,
                    style: context.theme.typography.body.sm.copyWith(
                      color: colors.foreground,
                    ),
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
      return SizedBox(
        width: double.infinity,
        child: FButton(
          onPress: null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: Center(child: FCircularProgress()),
              ),
              const SizedBox(width: Spacing.level2),
              Text(l10n.settingsExportStatusLoading),
            ],
          ),
        ),
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
              const Icon(
                SemanticIcons.actionExpand,
                size: IconSizeTokens.level3,
              ),
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
              const Icon(SemanticIcons.actionMore, size: IconSizeTokens.level3),
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
      DataExportUiStatus.idle => l10n.settingsExportStatusIdle,
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

    // Resolve account password re-authentication, respecting the user's
    // `passwordReauthenticationRequired` setting. Awaits settings readiness
    // to avoid forcing the prompt on OAuth-only users while settings load.
    final password = await resolveSensitiveActionPassword(ref, context);
    if (password == null || !context.mounted) return;

    final DataExportRequestDataDto? value;
    try {
      value = await ref
          .read(dataExportControllerProvider.notifier)
          .requestExport(
            reviewHospitalPdfLast7DaysExportRequest,
            password: password,
          );
    } catch (error) {
      if (!context.mounted) return;
      await handleSensitiveActionFailure(
        context: context,
        l10n: l10n,
        error: error,
        failurePrefix: l10n.mineExportStatusFailed,
      );
      return;
    }
    if (!context.mounted) return;
    switch (dataExportUiStatusForRequest(value)) {
      case DataExportUiStatus.completed:
        await Toast.show(context, l10n.mineExportStatusCompleted);
      case DataExportUiStatus.completedLinkMissing:
        await Toast.show(context, l10n.reviewExportLinkMissingToast);
      case DataExportUiStatus.failed:
      case DataExportUiStatus.unavailable:
        await Toast.show(
          context,
          value?.errorMessage?.isNotEmpty == true
              ? value?.errorMessage ?? ''
              : dataExportUiStatusForRequest(value) ==
                    DataExportUiStatus.unavailable
              ? l10n.mineExportStatusUnavailable
              : l10n.mineExportStatusFailed,
        );
      case DataExportUiStatus.requested:
        await Toast.show(context, l10n.mineExportRequested);
      case DataExportUiStatus.processing:
        await Toast.show(context, l10n.mineExportStatusPending);
      case DataExportUiStatus.idle:
        await Toast.show(context, l10n.mineExportStatusFailed);
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
    final typography = context.theme.typography;

    return Row(
      children: [
        Text(
          label,
          style: typography.body.sm.copyWith(color: colors.foreground),
        ),
        const Spacer(),
        Text(
          value,
          style: typography.body.sm.copyWith(
            color: colors.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
