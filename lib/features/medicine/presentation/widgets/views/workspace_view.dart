import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/workspace_parts.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/mobile_dashboard_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineWorkspaceView extends StatelessWidget {
  const MedicineWorkspaceView({
    super.key,
    required this.workspace,
    this.onMarkDose,
  });

  final MedicineWorkspace workspace;
  final void Function(MedicineDoseMarkRequest request)? onMarkDose;

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        FadeEffect(duration: DurationTokens.widgetFadeIn),
        SlideEffect(
          begin: Offset(0, 0.025),
          end: Offset.zero,
          duration: DurationTokens.widgetFadeIn,
        ),
      ],
      child: MedicineMobileDashboardView(
        workspace: workspace,
        onMarkDose: onMarkDose,
      ),
    );
  }
}

class MedicineErrorView extends StatelessWidget {
  const MedicineErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppStateErrorView(
      title: l10n.medicineErrorTitle,
      description: l10n.medicineErrorDescription,
      icon: FLucideIcons.pillBottle,
      actionLabel: l10n.todayRetryAction,
      onAction: onRetry,
      tone: AppStateTone.warning,
    );
  }
}
