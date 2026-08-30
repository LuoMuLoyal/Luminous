import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/database/cache_constants.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Unified single-layer page state for root tab pages.
///
/// Priority order (highest → lowest):
/// 1. [PageViewStateFatalError] — data loading failed
/// 2. [PageViewStateLoading] — session restoring or data fetching
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
}

/// Data is still being fetched or the auth session is being restored.
class PageViewStateLoading<T> extends PageViewState<T> {
  const PageViewStateLoading();
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
/// 1. If the session is restoring → [PageViewStateLoading]
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
  // Priority 1: session still restoring
  if (session.isRestoring) {
    return PageViewStateLoading<T>();
  }

  final isPreview = session.isConfirmedSignedOut;

  // If the data is refreshing (loading but has a previous value), keep
  // showing the previous data instead of flashing a skeleton.
  if (data.isLoading && data.hasValue) {
    final previousValue = data.value as T;
    if (isInsufficient != null && isInsufficient(previousValue)) {
      return PageViewStateEmptyInsufficient<T>(title: '', description: '');
    }
    return PageViewStateReady<T>(previousValue, isPreview: isPreview);
  }

  // Resolve based on the async data state.
  return data.when(
    loading: () => PageViewStateLoading<T>(),
    error: (error, stackTrace) {
      return PageViewStateFatalError<T>(
        title: '',
        description: '',
        icon: errorIcon,
      );
    },
    data: (value) {
      if (isInsufficient != null && isInsufficient(value)) {
        return PageViewStateEmptyInsufficient<T>(title: '', description: '');
      }
      return PageViewStateReady<T>(value, isPreview: isPreview);
    },
  );
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

  @override
  Widget build(BuildContext context) {
    return switch (state) {
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
      PageViewStateReady<T>(:final data, :final isPreview) => readyBuilder(
        data,
        isPreview,
      ),
    };
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
        horizontal: Spacing.level4,
        vertical: Spacing.level2,
      ),
      child: Row(
        children: [
          Icon(SemanticIcons.statusBlocked, color: colors.primary, size: 20),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Text(
              message ?? l10n.statePreviewSignInHint,
              style: context.theme.typography.body.xs.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(width: Spacing.level3),
          FButton(
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.sm,
            onPress: onSignIn,
            child: Text(l10n.statePreviewSignInAction),
          ),
        ],
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
    final colors = context.theme.colors;
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
                horizontal: Spacing.level4,
                vertical: Spacing.level2,
              ),
              color: SemanticColor.warning.subtle(context),
              child: Row(
                children: [
                  Icon(
                    SemanticIcons.statusWarning,
                    size: 18,
                    color: SemanticColor.warning.solid(context),
                  ),
                  const SizedBox(width: Spacing.level2),
                  Expanded(
                    child: Text(
                      l10n.todayLoadingSlowHint,
                      style: context.theme.typography.body.xs.copyWith(
                        color: colors.mutedForeground,
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
