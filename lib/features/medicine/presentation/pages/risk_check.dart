import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
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
  /// 服务端「模型未配置」的稳定 problem code(Lucent problem-catalog 注册表:
  /// `LLM_NOT_CONFIGURED` → HTTP 503)。
  ///
  /// 只认这个 code,**不再用 `statusCode == 503` 兜底**:同一端点上运行时的
  /// LLM 失败也会以 503 返回,用状态码兜底会把可重试故障说成永久缺配置——
  /// 那正是这条分流要消除的误报。
  static const _llmNotConfiguredCode = 'LLM_NOT_CONFIGURED';

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

    LucentFailure? failure;
    try {
      failure = await _runAndNormalize(type);
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

    if (failure == null || !mounted) return;

    // 只有服务端明确宣告模型未配置时,AI 标签页才切到「AI 分析未配置」。
    // 此前任何失败(离线/超时/401/模型运行失败)都会整页显示这句文案,把可重试的
    // 失败误报成部署缺配置,同时吞掉真正的失败提示。
    if (isLlm && _isLlmNotConfigured(failure)) {
      setState(() => _llmUnavailable = true);
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    await Toast.show(
      context,
      userMessageFromError(
        failure,
        l10n: l10n,
        fallback: l10n.medicineErrorDescription,
      ),
    );
  }

  /// Runs [type] and returns the normalized failure, or `null` on success.
  ///
  /// The run provider is a command provider with riverpod's automatic retry
  /// switched off (`providers/risk_check.dart`), so the first failure reaches
  /// `.future` as the real failure instead of being hidden behind ~40s of
  /// exponential-backoff retries (which re-POST the check each round) or
  /// surfacing as riverpod's own disposal `StateError`.
  Future<LucentFailure?> _runAndNormalize(MedicineRiskCheckType type) async {
    try {
      await ref.read(runMedicineRiskCheckProvider(type).future);
      return null;
    } catch (caught) {
      try {
        return LucentErrorMapper.fromObject(caught);
      } on FormatException catch (formatError) {
        // 归一 seam 对畸形 problem+json 抛 FormatException:命令流程不能让归一
        // 异常上抛(它会变成按钮回调里的未捕获异步错误),回落为 unknown 失败。
        return LucentErrorMapper.fromObject(formatError);
      }
    }
  }

  /// 判断服务端是否在宣告「这个部署没配 AI 模型」。
  ///
  /// 依据只有稳定 code:503 本身不足以下这个结论(Lucent 的运行时 LLM 失败
  /// 也是 503),所以这里刻意不看 `statusCode`。
  bool _isLlmNotConfigured(LucentFailure failure) {
    return failure.code == _llmNotConfiguredCode;
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
          child: _ScrollableTabChild(
            child: CheckTabContent(
              record: records.staticRecord,
              checkType: MedicineRiskCheckType.static_,
              l10n: l10n,
              onRunCheck: onRunStatic,
              isRunning: isRunningStatic,
            ),
          ),
        ),
        FTabEntry(
          label: Text(l10n.medicineRiskCheckTabLlm),
          child: _ScrollableTabChild(
            child: CheckTabContent(
              record: records.llmRecord,
              checkType: MedicineRiskCheckType.llm,
              l10n: l10n,
              onRunCheck: onRunLlm,
              isRunning: isRunningLlm,
              llmUnavailable: llmUnavailable,
            ),
          ),
        ),
      ],
    );
  }
}

/// `FTabs(expands: true)` 给 tab 子节点的是**固定高度**且自身不滚动:
/// 360dp 真机 + 1.3 字号下 TabHeader + RiskScoreHero + MetricGrid 等内容高于
/// tab 视口,内容 Column 直接竖向溢出(实测 360x800 溢出 30px、320x720 溢出
/// 156px)。这里让 tab 内容自己滚动;内容不足一屏时用 [ConstrainedBox] 的
/// minHeight 撑满视口,空态/加载态仍能垂直居中。
///
/// 顺带让 `Scrollable.ensureVisible`(MetricGrid 的「查看发现/覆盖」跳转)
/// 有了可用的祖先滚动体。
class _ScrollableTabChild extends StatelessWidget {
  const _ScrollableTabChild({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : 0,
          ),
          child: child,
        ),
      ),
    );
  }
}
