import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/network/lucent_error_mapper.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/common/app_section_surface.dart';
import 'package:luminous/core/widgets/layout/page_scaffold_shell.dart';
import 'package:luminous/features/settings/presentation/providers/data_export_controller.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/l10n/app_localizations.dart';

class DataExportPage extends ConsumerWidget {
  const DataExportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = _typography(context);
    final exportAsync = ref.watch(dataExportControllerProvider);
    final exportRequestInFlight = ref.watch(dataExportRequestInFlightProvider);
    final export = exportAsync.asData?.value;

    return PageScaffoldShell(
      title: l10n.mineSettingExportTitle,
      centerTitle: true,
      leading: const AppBackButton(),
      children: [
        AppSectionSurface(
          surface: surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsExportDescription,
                style: typography.bodyMd.copyWith(color: surface.body),
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              _StatusRow(
                label: l10n.mineSettingExportValue,
                value: _statusLabel(l10n, export),
                surface: surface,
                typography: typography,
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: exportRequestInFlight.inFlight
                      ? null
                      : () async => _requestExport(context, ref),
                  child: exportRequestInFlight.inFlight
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.settingsExportRequestButton),
                ),
              ),
            ],
          ),
        ),
      ],
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
    try {
      final request = await ref
          .read(dataExportControllerProvider.notifier)
          .requestExport();
      if (!context.mounted) {
        return;
      }

      switch (dataExportUiStatusForRequest(request)) {
        case DataExportUiStatus.completed:
          await AppToast.show(context, l10n.mineExportStatusCompleted);
        case DataExportUiStatus.completedLinkMissing:
          await AppToast.show(context, l10n.reportExportLinkMissingToast);
        case DataExportUiStatus.failed:
        case DataExportUiStatus.unavailable:
          await AppToast.show(
            context,
            request?.errorMessage?.isNotEmpty == true
                ? request!.errorMessage!
                : dataExportUiStatusForRequest(request) ==
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
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      final message = LucentErrorMapper.fromObject(error).message;
      await AppToast.show(context, '${l10n.mineExportStatusFailed}: $message');
    }
  }

  AppTypographyScale _typography(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    return width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.surface,
    required this.typography,
  });

  final String label;
  final String value;
  final AppThemeSurface surface;
  final AppTypographyScale typography;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: typography.bodyMd.copyWith(color: surface.body)),
        const Spacer(),
        Text(
          value,
          style: typography.bodyMdStrong.copyWith(color: surface.body),
        ),
      ],
    );
  }
}
