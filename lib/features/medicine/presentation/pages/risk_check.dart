import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/providers/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/check_loading.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/check_tab_content.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineRiskCheckPage extends ConsumerStatefulWidget {
  const MedicineRiskCheckPage({super.key});

  @override
  ConsumerState<MedicineRiskCheckPage> createState() =>
      _MedicineRiskCheckPageState();
}

class _MedicineRiskCheckPageState extends ConsumerState<MedicineRiskCheckPage> {
  bool _isRunningStatic = false;
  bool _isRunningLlm = false;
  bool _llmUnavailable = false;

  Future<void> _runCheck(MedicineRiskCheckType type) async {
    final isLlm = type == MedicineRiskCheckType.llm;

    setState(() {
      if (isLlm) {
        _isRunningLlm = true;
        _llmUnavailable = false;
      } else {
        _isRunningStatic = true;
      }
    });

    try {
      await ref.read(runMedicineRiskCheckProvider(type).future);
    } catch (e) {
      if (isLlm && mounted) {
        setState(() => _llmUnavailable = true);
      }
    } finally {
      if (mounted) {
        setState(() {
          if (isLlm) {
            _isRunningLlm = false;
          } else {
            _isRunningStatic = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    final Widget bodyContent;
    if (!session.canAccessProtectedData) {
      bodyContent = session.isLoading
          ? const MedicineRiskCheckLoading()
          : AuthRequiredDialogGate(
              onLogin: () =>
                  context.push(loginRouteForCurrentLocation(context)),
            );
    } else {
      final recordsAsync = ref.watch(medicineRiskCheckRecordsProvider);
      bodyContent = recordsAsync.when(
        data: (records) => _RiskCheckTabs(
          records: records,
          l10n: l10n,
          onRunStatic: () => _runCheck(MedicineRiskCheckType.static_),
          onRunLlm: () => _runCheck(MedicineRiskCheckType.llm),
          isRunningStatic: _isRunningStatic,
          isRunningLlm: _isRunningLlm,
          llmUnavailable: _llmUnavailable,
        ),
        loading: () => const MedicineRiskCheckLoading(),
        error: (_, __) => StateErrorView(
          title: l10n.medicineErrorTitle,
          description: l10n.medicineErrorDescription,
          icon: SemanticIcons.safetyCaution,
          actionLabel: l10n.todayRetryAction,
          onAction: () => ref.invalidate(medicineRiskCheckRecordsProvider),
          tone: StateTone.warning,
        ),
      );
    }

    return PageScaffold(
      title: l10n.medicineRiskCheckPageTitle,
      child: ResponsiveContentFrame(child: bodyContent),
    );
  }
}

class _RiskCheckTabs extends StatelessWidget {
  const _RiskCheckTabs({
    required this.records,
    required this.l10n,
    required this.onRunStatic,
    required this.onRunLlm,
    required this.isRunningStatic,
    required this.isRunningLlm,
    required this.llmUnavailable,
  });

  final MedicineRiskCheckRecords records;
  final AppLocalizations l10n;
  final VoidCallback onRunStatic;
  final VoidCallback onRunLlm;
  final bool isRunningStatic;
  final bool isRunningLlm;
  final bool llmUnavailable;

  @override
  Widget build(BuildContext context) {
    return FTabs(
      expands: true,
      children: [
        FTabEntry(
          label: Text(l10n.medicineRiskCheckTabStatic),
          child: CheckTabContent(
            record: records.staticRecord,
            checkType: MedicineRiskCheckType.static_,
            l10n: l10n,
            onRunCheck: onRunStatic,
            isRunning: isRunningStatic,
          ),
        ),
        FTabEntry(
          label: Text(l10n.medicineRiskCheckTabLlm),
          child: CheckTabContent(
            record: records.llmRecord,
            checkType: MedicineRiskCheckType.llm,
            l10n: l10n,
            onRunCheck: onRunLlm,
            isRunning: isRunningLlm,
            llmUnavailable: llmUnavailable,
          ),
        ),
      ],
    );
  }
}
