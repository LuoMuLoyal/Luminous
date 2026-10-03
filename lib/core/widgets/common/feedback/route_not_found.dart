import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 未知 location 的兜底页(GoRouter `errorBuilder`)。
///
/// 默认的 GoRouter 错误页会把 `GoException: no routes for location: …` 原样显示给
/// 用户(真机上表现为"崩溃页")。这里换成可返回的提示页,并把回首页动作交给调用方
/// (避免 core → app 的反向依赖)。
class RouteNotFoundPage extends StatelessWidget {
  const RouteNotFoundPage({
    super.key,
    required this.location,
    required this.onGoHome,
  });

  final String location;
  final void Function(BuildContext context) onGoHome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FScaffold(
      child: StateMessageView(
        title: l10n.commonRouteNotFoundTitle,
        description: l10n.commonRouteNotFoundDescription,
        icon: SemanticIcons.statusError,
        tone: StateTone.warning,
        actionLabel: l10n.commonGoHomeAction,
        onAction: () => onGoHome(context),
      ),
    );
  }
}
