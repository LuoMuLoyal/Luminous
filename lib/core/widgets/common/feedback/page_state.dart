import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/auth_session_adapter.dart';
import 'package:luminous/core/database/cache_constants.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Unified single-layer page state for root tab pages.
///
/// Priority order (highest → lowest):
/// 1. [PageViewStateFatalError] — data loading failed
/// 2. [PageViewStateLoading] — data fetching (session restoring with cache miss,
///    or first load)
/// 3. [PageViewStateEmptyInsufficient] — data loaded but insufficient
/// 4. [PageViewStateReady] — normal content ready to render
///
/// When the user is **not signed in**, the page does **not** block — instead
/// the data providers return preview/mock data and [PageViewStateReady] is
/// emitted with [PageViewStateReady.isPreview] set to `true`. Pages can use
/// this flag to show a lightweight sign-in hint banner above the preview
/// content.
sealed class PageViewState<T> {
  const PageViewState();

  /// The displayable payload, or `null` when there is nothing to show yet.
  ///
  /// [PageViewStateLoading] and [PageViewStateFatalError] carry no data;
  /// [PageViewStateReady], [PageViewStateRefreshing] and [PageViewStateStale]
  /// all do — which is the whole point of separating them: a refresh or a failed
  /// refresh must not take the content away.
  T? get dataOrNull => switch (this) {
    PageViewStateReady<T>(:final data) => data,
    PageViewStateRefreshing<T>(:final data) => data,
    PageViewStateStale<T>(:final data) => data,
    PageViewStateLoading<T>() => null,
    PageViewStateEmptyInsufficient<T>() => null,
    PageViewStateFatalError<T>() => null,
  };

  /// Whether content is on screen in a degraded form (stale or refreshing).
  bool get isDegraded => switch (this) {
    PageViewStateRefreshing<T>() => true,
    PageViewStateStale<T>() => true,
    _ => false,
  };
}

/// Data is still being fetched or the auth session is being restored with a
/// cache miss.
class PageViewStateLoading<T> extends PageViewState<T> {
  const PageViewStateLoading();
}

/// Data is already on screen and a newer read is in flight.
///
/// [AsyncValue.isLoading] does **not** exclude [AsyncValue.hasValue], so a
/// "refreshing" page is not the same thing as a first load. Rendering it as
/// [PageViewStateLoading] replaces real content with a skeleton and makes the
/// page flash on every rebuild — `ref.invalidate` from `DataChangeBus`,
/// pull-to-refresh, or a dependency change all land here.
class PageViewStateRefreshing<T> extends PageViewState<T> {
  const PageViewStateRefreshing({
    required this.data,
    this.isPreview = false,
    this.fromCache = false,
  });

  final T data;
  final bool isPreview;

  /// The value came from the offline cache; the in-flight read may be offline.
  final bool fromCache;
}

/// A read failed, but data from an earlier successful read is still displayable.
///
/// The data must stay on screen with a visible "update failed" affordance.
/// Collapsing this into [PageViewStateFatalError] throws away usable content;
/// collapsing it into [PageViewStateReady] hides a failure.
class PageViewStateStale<T> extends PageViewState<T> {
  const PageViewStateStale({
    required this.data,
    required this.error,
    this.isPreview = false,
    this.retrying = false,
  });

  final T data;
  final Object error;
  final bool isPreview;

  /// A retry is scheduled but its backoff has not elapsed yet.
  final bool retrying;
}

/// A fatal error occurred while loading page data.
class PageViewStateFatalError<T> extends PageViewState<T> {
  const PageViewStateFatalError({
    required this.title,
    required this.description,
    required this.icon,
    this.onRetry,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onRetry;
}

/// Data was loaded but is empty or insufficient for the page's purpose.
class PageViewStateEmptyInsufficient<T> extends PageViewState<T> {
  const PageViewStateEmptyInsufficient({
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
}

/// Data is ready and the page can render its normal content.
///
/// When [isPreview] is `true`, the data is mock/preview data shown to
/// unauthenticated users. Pages should display a [SignInHintBanner] at the
/// top to invite the user to sign in.
class PageViewStateReady<T> extends PageViewState<T> {
  const PageViewStateReady(this.data, {this.isPreview = false});

  final T data;
  final bool isPreview;
}

/// Resolves the [PageViewState] from the current auth session and async data.
///
/// Priority:
/// 1. If the async data is loading (without a previous value) and the session
///    is restoring → [PageViewStateLoading]. Providers are cache-first, so
///    during restore they resolve immediately when a local cache hit exists;
///    only a genuine cache miss keeps the skeleton.
/// 2. If the async data is loading (without a previous value) →
///    [PageViewStateLoading]
/// 3. If the async data has an error → [PageViewStateFatalError]
/// 4. If the data is loaded but [isInsufficient] returns true →
///    [PageViewStateEmptyInsufficient]
/// 5. Otherwise → [PageViewStateReady] (with `isPreview` = true when signed out)
///
/// **Important**: when the user is signed out, this function does **not**
/// block the page. The data providers are expected to return preview/mock
/// data for unauthenticated users, and the resulting [PageViewStateReady]
/// will have `isPreview` set to `true`.
PageViewState<T> resolvePageViewState<T>({
  required AuthSessionState session,
  required AsyncValue<T> data,
  bool Function(T data)? isInsufficient,
  IconData errorIcon = SemanticIcons.statusError,
}) {
  final isPreview = session.isConfirmedSignedOut;
  final value = data.value;

  PageViewState<T> readyWith(T previousValue) {
    if (isInsufficient != null && isInsufficient(previousValue)) {
      return PageViewStateEmptyInsufficient<T>(title: '', description: '');
    }
    return PageViewStateReady<T>(previousValue, isPreview: isPreview);
  }

  // 1. Data on screen + a newer read in flight → keep the content, mark refresh.
  //    (`isLoading` and `hasValue` are not mutually exclusive.)
  if (value != null && data.isLoading) {
    if (isInsufficient != null && isInsufficient(value)) {
      return PageViewStateEmptyInsufficient<T>(title: '', description: '');
    }
    return PageViewStateRefreshing<T>(
      data: value,
      isPreview: isPreview,
      fromCache: data.isFromCache,
    );
  }

  // 2. Data on screen + the newer read failed → keep the content, surface it.
  if (value != null && data.hasError) {
    return PageViewStateStale<T>(
      data: value,
      error: data.error!,
      isPreview: isPreview,
      retrying: data.retrying,
    );
  }

  // 3. Data on screen and stable.
  if (value != null) {
    return readyWith(value);
  }

  // 4. Nothing to show and the read failed.
  if (data.hasError) {
    return PageViewStateFatalError<T>(
      title: '',
      description: '',
      icon: errorIcon,
    );
  }

  // 5. Nothing to show yet.
  return PageViewStateLoading<T>();
}

/// A widget that switches between [PageViewState] variants and renders the
/// appropriate view.
///
/// Each state has a default implementation, but pages can override any
/// builder for custom UI.
class PageStateSwitch<T> extends StatelessWidget {
  const PageStateSwitch({
    super.key,
    required this.state,
    required this.readyBuilder,
    this.loadingBuilder,
    this.fatalErrorBuilder,
    this.emptyInsufficientBuilder,
  });

  final PageViewState<T> state;

  /// Builder for the [PageViewStateReady] state. Required.
  ///
  /// Receives the data and whether it is preview (signed-out) data.
  final Widget Function(T data, bool isPreview) readyBuilder;

  /// Builder for the [PageViewStateLoading] state.
  /// Defaults to a [StateSkeletonView] with generic shimmer blocks.
  final Widget Function()? loadingBuilder;

  /// Builder for the [PageViewStateFatalError] state.
  /// Defaults to [StateErrorView] using l10n copy.
  final Widget Function(PageViewStateFatalError<T> error)? fatalErrorBuilder;

  /// Builder for the [PageViewStateEmptyInsufficient] state.
  /// Defaults to [StateMessageView] using l10n copy.
  final Widget Function(PageViewStateEmptyInsufficient<T> empty)?
  emptyInsufficientBuilder;

  /// Stable key for the [PageViewState] variant, so [PageTransitionSwitcher]
  /// animates between variants (skeleton → content → error) but a payload change
  /// within the same variant (e.g. a data refresh keeping [PageViewStateReady])
  /// updates in place without re-animating the whole page.
  String _variantKey(PageViewState<T> state) => switch (state) {
    PageViewStateLoading<T>() => 'loading',
    PageViewStateFatalError<T>() => 'error',
    PageViewStateEmptyInsufficient<T>() => 'empty',
    // Refreshing and stale keep the content on screen, so they share the
    // 'ready' key: the page must not re-run its transition animation when a
    // background refresh starts or a background read fails.
    PageViewStateRefreshing<T>() => 'ready',
    PageViewStateStale<T>() => 'ready',
    PageViewStateReady<T>() => 'ready',
  };

  /// Renders the existing content with a slim "refreshing" affordance.
  ///
  /// Deliberately not a skeleton: the previous data is still valid, replacing
  /// it would make every background rebuild of a `DataChangeBus`-driven page
  /// flash. Offline reads say so instead of pretending the data is fresh.
  Widget _withRefreshHint(BuildContext context, bool fromCache) {
    final refreshing = state as PageViewStateRefreshing<T>;
    final l10n = AppLocalizations.of(context)!;
    return _ContentWithNotice(
      label: fromCache
          ? l10n.commonStatusOffline
          : l10n.commonStatusRefreshing,
      tone: StateNoticeTone.neutral,
      busy: !fromCache,
      child: readyBuilder(refreshing.data, refreshing.isPreview),
    );
  }

  /// Renders the last good content with a visible "update failed" affordance.
  ///
  /// The alternative — showing the stale data as if it were current, or
  /// replacing it with a full error page — loses information either way.
  Widget _withStaleHint(BuildContext context, PageViewStateStale<T> stale) {
    final l10n = AppLocalizations.of(context)!;
    return _ContentWithNotice(
      label: stale.retrying
          ? l10n.commonRetryingHint
          : l10n.commonStaleHint,
      tone: StateNoticeTone.warning,
      busy: stale.retrying,
      child: readyBuilder(stale.data, stale.isPreview),
    );
  }

  @override
  Widget build(BuildContext context) {
    final view = switch (state) {
      PageViewStateLoading<T>() => _LoadingTimeoutWrapper(
        child: loadingBuilder?.call() ?? const _DefaultLoadingView(),
      ),
      final PageViewStateFatalError<T> error =>
        fatalErrorBuilder?.call(error) ??
            _DefaultFatalErrorView(
              title: error.title,
              description: error.description,
              icon: error.icon,
              onRetry: error.onRetry,
            ),
      final PageViewStateEmptyInsufficient<T> empty =>
        emptyInsufficientBuilder?.call(empty) ??
            _DefaultEmptyInsufficientView(
              title: empty.title,
              description: empty.description,
              actionLabel: empty.actionLabel,
              onAction: empty.onAction,
              icon: empty.icon,
            ),
      final PageViewStateRefreshing<T> refreshing =>
        _withRefreshHint(context, refreshing.fromCache),
      final PageViewStateStale<T> stale => _withStaleHint(context, stale),
      PageViewStateReady<T>(:final data, :final isPreview) => readyBuilder(
        data,
        isPreview,
      ),
    };

    // Material fade-through between state variants: the outgoing view fades out
    // over the first 30% of the duration, then the incoming view fades in and
    // scales up (0.92 → 1.0). The first child renders without animating, so a
    // page's initial paint is immediate.
    return PageTransitionSwitcher(
      duration: DurationTokens.pageStateSwitch,
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
          FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          ),
      // StackFit.passthrough forwards the incoming constraints untouched: some
      // pages mount this switch inside a SingleChildScrollView, where the
      // default loose Stack would hand children unbounded constraints.
      layoutBuilder: (entries) =>
          Stack(fit: StackFit.passthrough, children: entries),
      child: KeyedSubtree(
        key: ValueKey<String>(_variantKey(state)),
        child: view,
      ),
    );
  }
}

/// A lightweight sign-in hint banner for preview (signed-out) mode.
///
/// Shows a compact row with a lock icon, a short "sign in for real data"
/// message, and a sign-in button. Designed to sit at the top of a page's
/// scrollable content — not a full-screen replacement.
class SignInHintBanner extends StatelessWidget {
  const SignInHintBanner({super.key, this.onSignIn, this.message});

  /// Callback when the sign-in button is tapped.
  final VoidCallback? onSignIn;

  /// Optional custom message. Defaults to l10n copy.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return Container(
      key: const Key('sign-in-hint-banner'),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: context.theme.style.borderRadius.md,
        border: Border.all(color: SemanticColor.neutral.border(context)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.sm,
      ),
      // 图标 + 文案 + 按钮三件挤在一个 Row 里时，文案是可压缩的 flex 子节点，
      // 缩到极限就竖向堆成 4 行（真机窄屏 + 大字号必现），并顺带把整条 banner
      // 顶高。这里让**图标与文案先成组**，按钮整体放到第二行右侧：文案至少能拿到
      // 整行宽度，按钮也不再参与和文案抢宽度。宽屏空间充足时二者并排，观感不变。
      child: LayoutBuilder(
        builder: (context, constraints) {
          final messageBlock = Row(
            children: [
              Icon(
                SemanticIcons.statusBlocked,
                color: SemanticColor.primary.solid(context),
                size: 20,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  message ?? l10n.statePreviewSignInHint,
                  style: context.theme.typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ),
            ],
          );

          // 按钮给宽度上限 + 标签省略：FButton 内部 Row 对非 flex 子节点是无界
          // 主轴约束，窄屏大字号下会按固有宽度把同行内容挤没。
          final actionButton = ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: FButton(
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.sm,
              onPress: onSignIn,
              child: Flexible(
                child: Text(
                  l10n.statePreviewSignInAction,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );

          // 文案单行放得下才并排；否则让按钮落到第二行，避免文案被压成多行。
          final textPainter = TextPainter(
            text: TextSpan(
              text: message ?? l10n.statePreviewSignInHint,
              style: context.theme.typography.body.xs,
            ),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            maxLines: 1,
          )..layout();

          const iconAndGap = 20 + Spacing.md;
          final buttonWidth = actionButton.constraints.maxWidth;
          final fitsOnOneLine =
              textPainter.width + iconAndGap + buttonWidth + Spacing.md <=
              constraints.maxWidth;

          if (fitsOnOneLine) {
            return Row(
              children: [
                Expanded(child: messageBlock),
                const SizedBox(width: Spacing.md),
                actionButton,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              messageBlock,
              const SizedBox(height: Spacing.xs),
              Align(alignment: Alignment.centerRight, child: actionButton),
            ],
          );
        },
      ),
    );
  }
}

/// Wraps loading content with a floor-timeout hint. After
/// [loadingFloorTimeout] (6 s), a "loading slow" hint banner appears above
/// the skeleton so the user knows the app is still working, not frozen.
class _LoadingTimeoutWrapper extends StatefulWidget {
  const _LoadingTimeoutWrapper({required this.child});

  final Widget child;

  @override
  State<_LoadingTimeoutWrapper> createState() => _LoadingTimeoutWrapperState();
}

class _LoadingTimeoutWrapperState extends State<_LoadingTimeoutWrapper> {
  Timer? _timer;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(loadingFloorTimeout, () {
      if (mounted) {
        setState(() => _showHint = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showHint) {
      return widget.child;
    }
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;
        return Column(
          mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Container(
              key: const Key('loading-slow-hint'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.sm,
              ),
              color: SemanticColor.warning.subtle(context),
              child: Row(
                children: [
                  Icon(
                    SemanticIcons.statusWarning,
                    size: 18,
                    color: SemanticColor.warning.solid(context),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      l10n.todayLoadingSlowHint,
                      style: context.theme.typography.body.xs.copyWith(
                        color: SemanticColor.neutral.solid(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (hasBoundedHeight)
              Expanded(child: widget.child)
            else
              widget.child,
          ],
        );
      },
    );
  }
}

class _DefaultLoadingView extends StatelessWidget {
  const _DefaultLoadingView();

  @override
  Widget build(BuildContext context) {
    return const StateSkeletonView(
      blocks: [
        StateSkeletonBlock(height: 28, widthFactor: 0.6),
        StateSkeletonBlock(height: 16, widthFactor: 0.9),
        StateSkeletonBlock(height: 16, widthFactor: 0.8),
        StateSkeletonBlock(height: 28, widthFactor: 0.5),
        StateSkeletonBlock(height: 16, widthFactor: 0.7),
      ],
    );
  }
}

class _DefaultFatalErrorView extends StatelessWidget {
  const _DefaultFatalErrorView({
    required this.title,
    required this.description,
    required this.icon,
    this.onRetry,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StateErrorView(
      title: title.isEmpty ? l10n.stateFatalErrorTitle : title,
      description: description.isEmpty
          ? l10n.stateFatalErrorDescription
          : description,
      icon: icon,
      actionLabel: l10n.todayRetryAction,
      onAction: onRetry,
      tone: StateTone.warning,
    );
  }
}

class _DefaultEmptyInsufficientView extends StatelessWidget {
  const _DefaultEmptyInsufficientView({
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StateMessageView(
      title: title.isEmpty ? l10n.stateEmptyDefaultTitle : title,
      description: description.isEmpty
          ? l10n.stateEmptyDefaultDescription
          : description,
      icon: icon ?? SemanticIcons.statusInfo,
      actionLabel: actionLabel,
      onAction: onAction,
      tone: StateTone.neutral,
    );
  }
}

/// Tone of the notice strip rendered above stale/refreshing content.
enum StateNoticeTone { neutral, warning }

/// Stacks a notice strip above content without taking the content away.
///
/// Used for [PageViewStateRefreshing] and [PageViewStateStale]: the page keeps
/// showing real data while telling the user what is happening.
class _ContentWithNotice extends StatelessWidget {
  const _ContentWithNotice({
    required this.child,
    required this.label,
    required this.tone,
    required this.busy,
  });

  final Widget child;
  final String label;
  final StateNoticeTone tone;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      StateNoticeTone.neutral => SemanticColor.info.solid(context),
      StateNoticeTone.warning => SemanticColor.warning.solid(context),
    };
    // The notice is an **overlay**, never a sibling of the content.
    //
    // Wrapping content in a Column hands it "available height minus the strip";
    // a full-screen shell (`Column` + `Expanded(ListView)`) receives unbounded
    // height from a Column and asserts. Stacking keeps the content's constraints
    // identical to the ready state, so the layout does not change just because a
    // background refresh started. IgnorePointer keeps the strip from stealing
    // taps aimed at the content underneath.
    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.sm,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.theme.colors.background,
                  borderRadius: context.theme.style.borderRadius.md,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.sm,
                  ),
                  child: Row(
                    children: [
                      if (busy) ...[
                        const SizedBox(
                          width: IconSizeTokens.sm,
                          height: IconSizeTokens.sm,
                          child: FProgress(),
                        ),
                        const SizedBox(width: Spacing.sm),
                      ],
                      Expanded(
                        child: Text(
                          label,
                          style: context.theme.typography.body.xs.copyWith(
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
