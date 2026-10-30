import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/feedback/page_state.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:luminous/features/today/presentation/providers/surface.dart';
import 'package:luminous/features/today/presentation/widgets/sections/observation.dart';
import 'package:luminous/features/today/presentation/widgets/sections/quick_actions.dart';
import 'package:luminous/features/today/presentation/widgets/sections/suggestion.dart';
import 'package:luminous/features/today/presentation/widgets/sections/summary.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/features/today/presentation/widgets/views/health_event_section.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Components of the `today` surface.
///
/// Each one is an adapter around an existing section widget: the section keeps
/// its implementation, the adapter owns the id, the visibility decision and the
/// "nothing to show right now" answer. Ids are `<domain>.<view>` and never
/// mention `today` — the same component must be mountable on another surface
/// later (`summary.metrics` on the review surface, for instance).
///
/// `build` returning `null` means "skip me and my spacing"; this is what removes
/// the `SizedBox.shrink()` placeholders the hand-written page needed.
const todayPreviewBannerId = ComponentId('auth.preview_banner');
const todayGreetingId = ComponentId('daily.greeting');
const todayPrimarySuggestionId = ComponentId('suggestion.primary');
const todaySecondarySuggestionsId = ComponentId('suggestion.secondary');
const todaySummaryId = ComponentId('summary.metrics');
const todayHealthEventId = ComponentId('health_event.active');
const todayObservationId = ComponentId('observation.metrics');
const todayQuickActionsId = ComponentId('quick_action.strip');

/// Surface definition: what `today` may host and what it shows by default.
///
/// The default layout is the pre-composition section order, so P0 is a pure
/// refactor — a user who never edits anything sees the same page.
const todaySurfaceDefinition = SurfaceDefinition(
  surface: SurfaceId.today,
  owned: [
    todayPreviewBannerId,
    todayGreetingId,
    todayPrimarySuggestionId,
    todaySecondarySuggestionsId,
    todaySummaryId,
    todayHealthEventId,
    todayObservationId,
    todayQuickActionsId,
  ],
  defaultLayout: SurfaceLayout(
    placements: [
      ComponentPlacement(id: todayPreviewBannerId, size: ComponentSize.wide),
      ComponentPlacement(id: todayGreetingId),
      ComponentPlacement(id: todayPrimarySuggestionId),
      ComponentPlacement(id: todaySecondarySuggestionsId),
      ComponentPlacement(id: todaySummaryId),
      ComponentPlacement(id: todayHealthEventId),
      ComponentPlacement(id: todayObservationId),
      ComponentPlacement(id: todayQuickActionsId, size: ComponentSize.wide),
    ],
  ),
);

/// Registers every `today` component into [registry].
void registerTodayComponents(ComponentRegistry registry) {
  registry.registerDescriptor(const _PreviewBannerComponent());
  registry.registerDescriptor(const _GreetingComponent());
  registry.registerDescriptor(const _PrimarySuggestionComponent());
  registry.registerDescriptor(const _SecondarySuggestionsComponent());
  registry.registerDescriptor(const _SummaryComponent());
  registry.registerDescriptor(const _HealthEventComponent());
  registry.registerDescriptor(const _ObservationComponent());
  registry.registerDescriptor(const _QuickActionsComponent());
}

class _PreviewBannerComponent extends ComponentDescriptor<NoComponentConfig> {
  const _PreviewBannerComponent();

  @override
  ComponentId get id => todayPreviewBannerId;

  @override
  Set<ComponentSize> get supportedSizes => {ComponentSize.wide};

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    if (!ref.watch(todaySurfacePreviewProvider)) return null;
    final l10n = AppLocalizations.of(context)!;
    return SignInHintBanner(
      message: l10n.todayPreviewBannerMessage,
      onSignIn: () => requestSignIn(context),
    );
  }
}

class _GreetingComponent extends ComponentDescriptor<NoComponentConfig> {
  const _GreetingComponent();

  @override
  ComponentId get id => todayGreetingId;

  @override
  Set<ComponentSize> get supportedSizes => {
    ComponentSize.compact,
    ComponentSize.regular,
    ComponentSize.wide,
  };

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    final l10n = AppLocalizations.of(context)!;
    final dashboard = ref.watch(todaySurfaceDashboardProvider).dataOrNull;
    // 无数据时（首帧加载或加载失败）问候语没有可用的时间段信息，
    // 交给页面级的骨架/降级视图，组件自身不出内容。
    if (dashboard == null) return null;
    return Text(
      greetingSubtitle(l10n, dashboard),
      style: context.theme.typography.body.sm.copyWith(
        color: SemanticColor.neutral.solid(context),
      ),
    );
  }
}

class _PrimarySuggestionComponent
    extends ComponentDescriptor<NoComponentConfig> {
  const _PrimarySuggestionComponent();

  @override
  ComponentId get id => todayPrimarySuggestionId;

  @override
  Set<ComponentSize> get supportedSizes => {
    ComponentSize.regular,
    ComponentSize.wide,
  };

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const TodayPrimarySuggestionSection();
  }
}

class _SecondarySuggestionsComponent
    extends ComponentDescriptor<NoComponentConfig> {
  const _SecondarySuggestionsComponent();

  @override
  ComponentId get id => todaySecondarySuggestionsId;

  @override
  Set<ComponentSize> get supportedSizes => {
    ComponentSize.compact,
    ComponentSize.regular,
    ComponentSize.wide,
  };

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    // 这里判断的只是「这张卡是否值得占位」，不是「有没有数据」：
    //   data  → 真没有次要建议才移除该组件；
    //   loading / error → 保留占位，因为卡片内部已经自带骨架与错误态
    //   （SecondarySuggestionErrorState）。若在这里因 error 返回 null，
    //   用户会看不到失败提示，失败就被伪装成「本次没有次要建议」。
    final hasCards = ref
        .watch(todaySuggestionProvider)
        .when(
          data: TodaySecondarySuggestionsSection.hasCards,
          loading: () => true,
          error: (_, _) => true,
        );
    if (!hasCards) return null;
    return const TodaySecondarySuggestionsSection(
      key: Key('today-secondary-suggestions-card'),
    );
  }
}

class _SummaryComponent extends ComponentDescriptor<NoComponentConfig> {
  const _SummaryComponent();

  @override
  ComponentId get id => todaySummaryId;

  @override
  Set<ComponentSize> get supportedSizes => {
    ComponentSize.regular,
    ComponentSize.wide,
  };

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const TodaySummarySection();
  }
}

class _HealthEventComponent extends ComponentDescriptor<NoComponentConfig> {
  const _HealthEventComponent();

  @override
  ComponentId get id => todayHealthEventId;

  @override
  Set<ComponentSize> get supportedSizes => {
    ComponentSize.regular,
    ComponentSize.wide,
  };

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    // Preview mode has no protected data, so the card would only render its
    // empty state; skipping it also removes its spacing.
    if (ref.watch(todaySurfacePreviewProvider)) return null;
    return const HealthEventSection();
  }
}

class _ObservationComponent extends ComponentDescriptor<NoComponentConfig> {
  const _ObservationComponent();

  @override
  ComponentId get id => todayObservationId;

  @override
  Set<ComponentSize> get supportedSizes => {
    ComponentSize.compact,
    ComponentSize.regular,
    ComponentSize.wide,
  };

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const TodayObservationSection();
  }
}

class _QuickActionsComponent extends ComponentDescriptor<NoComponentConfig> {
  const _QuickActionsComponent();

  @override
  ComponentId get id => todayQuickActionsId;

  @override
  Set<ComponentSize> get supportedSizes => {ComponentSize.wide};

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const TodayQuickActionsSection();
  }
}
