import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'
    show DebugSemanticsDumpOrder, SemanticsNode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/report/data/providers/review.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/domain/repositories/review.dart';
import 'package:luminous/features/report/presentation/pages/page.dart';
import 'package:luminous/features/report/presentation/widgets/views/review_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';
import 'review_fixtures.dart';

/// Task 9 a11y 校验：TalkBack/VoiceOver 语义遍历顺序。
///
/// 要求：事件标题 → 状态/结果 → 四段（发生了什么/有什么变化/完成了什么/
/// 接下来怎么办）→ 历史 → More。测试按语义树深度优先遍历收集 label，
/// 用首次出现位置断言相对顺序（中间允许存在日期、用药数等次要 label）。
void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  // ── 工具 ────────────────────────────────────────────────────────

  /// 按语义遍历顺序收集整个语义树的 (label, isButton, isTappable)。
  List<({String label, bool isButton})> collectSemantics(
    WidgetTester tester,
    Finder finder,
  ) {
    final result = <({String label, bool isButton})>[];
    final root = tester.getSemantics(finder);
    void walk(SemanticsNode node) {
      final label = node.label.trim();
      if (label.isNotEmpty) {
        result.add((label: label, isButton: node.flagsCollection.isButton));
      }
      for (final child in node.debugListChildrenInOrder(
        DebugSemanticsDumpOrder.traversalOrder,
      )) {
        walk(child);
      }
    }

    walk(root);
    return result;
  }

  /// 断言 [requiredOrder] 中各 label 按首次出现位置严格递增。
  void expectOrder(
    List<({String label, bool isButton})> semantics, {
    required List<String> requiredOrder,
    String? reason,
  }) {
    final positions = <String, int>{
      for (final key in requiredOrder)
        key: semantics.indexWhere((item) => item.label == key),
    };
    final missing = requiredOrder.where((key) => positions[key] == -1);
    expect(
      missing,
      isEmpty,
      reason: '语义树缺少 $missing；实际顺序：${semantics.map((e) => e.label).toList()}',
    );
    for (var index = 0; index < requiredOrder.length - 1; index += 1) {
      expect(
        positions[requiredOrder[index]]!,
        lessThan(positions[requiredOrder[index + 1]]!),
        reason:
            '$reason\n"${requiredOrder[index]}" 应排在 "${requiredOrder[index + 1]}" 之前；'
            '实际顺序：${semantics.map((e) => e.label).toList()}',
      );
    }
  }

  Future<void> pumpReviewView(
    WidgetTester tester, {
    required AsyncValue<EventReview?> current,
    AsyncValue<ReviewEventPage>? history,
    bool canAccessProtectedData = true,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReviewView(
              currentAsync: current,
              cachedReview: null,
              historyAsync:
                  history ??
                  const AsyncValue<ReviewEventPage>.data(
                    ReviewEventPage(items: [], total: 0),
                  ),
              canAccessProtectedData: canAccessProtectedData,
              isPreview: false,
              onRetry: () {},
              onStartObservation: () {},
              onCheckIn: () {},
              onEndEvent: () {},
              onSignIn: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  // ── 内容区语义顺序（ReviewView 直接装配） ───────────────────────

  testWidgets('active 语义顺序：事件标题 → 状态 → 四段 → 历史', (tester) async {
    await pumpReviewView(
      tester,
      current: AsyncValue<EventReview?>.data(reviewActive()),
      history: AsyncValue<ReviewEventPage>.data(
        reviewHistoryPage([reviewEventItem(id: 'evt-2', title: '嗓子疼观察')]),
      ),
    );

    final semantics = collectSemantics(tester, find.byType(ReviewView));

    expectOrder(
      semantics,
      requiredOrder: [
        '感冒观察',
        l10n.reportReviewStatusActive,
        l10n.reportReviewSectionWhatHappened,
        l10n.reportReviewSectionKeyChanges,
        l10n.reportReviewSectionCompletedActions,
        l10n.reportReviewSectionNextStep,
        l10n.reportReviewHistoryTitle,
      ],
      reason: 'active 状态',
    );
    // 头部状态 chip 先于四段出现（历史筛选按钮的「进行中」不应抢先）。
    final chipIndex = semantics.indexWhere(
      (item) =>
          item.label == l10n.reportReviewStatusActive && item.isButton == false,
    );
    expect(chipIndex, isNot(-1));
  });

  testWidgets('ended 语义顺序：事件标题 → 已结束 → 结果 → 四段 → 历史', (tester) async {
    await pumpReviewView(
      tester,
      current: AsyncValue<EventReview?>.data(reviewEnded()),
      history: AsyncValue<ReviewEventPage>.data(
        reviewHistoryPage([reviewEventItem(id: 'evt-2', title: '嗓子疼观察')]),
      ),
    );

    final semantics = collectSemantics(tester, find.byType(ReviewView));

    expectOrder(
      semantics,
      requiredOrder: [
        '感冒观察',
        l10n.reportReviewStatusEnded,
        l10n.reportReviewOutcomeLabel,
        l10n.reportReviewOutcomeImproved,
        l10n.reportReviewSectionWhatHappened,
        l10n.reportReviewSectionKeyChanges,
        l10n.reportReviewSectionCompletedActions,
        l10n.reportReviewSectionNextStep,
        l10n.reportReviewHistoryTitle,
      ],
      reason: 'ended 状态',
    );
  });

  testWidgets('partial 语义顺序：未知段落不打断 标题 → 状态 → 可用段落 → 历史', (tester) async {
    await pumpReviewView(
      tester,
      current: AsyncValue<EventReview?>.data(reviewPartial()),
      history: AsyncValue<ReviewEventPage>.data(
        reviewHistoryPage([reviewEventItem(id: 'evt-2', title: '嗓子疼观察')]),
      ),
    );

    final semantics = collectSemantics(tester, find.byType(ReviewView));

    expectOrder(
      semantics,
      requiredOrder: [
        '感冒观察',
        l10n.reportReviewStatusActive,
        l10n.reportReviewSectionWhatHappened,
        l10n.reportReviewReasonNoObservations,
        l10n.reportReviewReasonNoCompletedActions,
        l10n.reportReviewSectionNextStep,
        l10n.reportReviewHistoryTitle,
      ],
      reason: 'partial 状态',
    );
  });

  testWidgets('no-event 语义顺序：开始观察入口 → 历史', (tester) async {
    await pumpReviewView(
      tester,
      current: const AsyncValue<EventReview?>.data(null),
      history: AsyncValue<ReviewEventPage>.data(
        reviewHistoryPage([reviewEventItem(id: 'evt-1', title: '头痛观察')]),
      ),
    );

    final semantics = collectSemantics(tester, find.byType(ReviewView));

    expectOrder(
      semantics,
      requiredOrder: [
        l10n.reportReviewNoEventTitle,
        l10n.reportReviewNoEventDescription,
        l10n.reportReviewStartObservationAction,
        l10n.reportReviewHistoryTitle,
        '头痛观察',
      ],
      reason: 'no-event 状态',
    );
  });

  // ── 整页（含顶栏 More）语义顺序 ────────────────────────────────

  testWidgets('整页语义：内容 标题 → 状态 → 四段 → 历史 之后是 More 动作', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          reviewRepositoryProvider.overrideWithValue(
            _PageReviewRepository(
              current: reviewActive(),
              page: reviewHistoryPage([
                reviewEventItem(id: 'evt-2', title: '嗓子疼观察'),
              ]),
            ),
          ),
        ],
        child: const TestForuiApp(home: ReportPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final semantics = collectSemantics(tester, find.byType(ReportPage));

    // More 按钮：独立节点、带「更多」label、按钮语义。
    final more = semantics.where(
      (item) => item.label == l10n.reportMoreTitle && item.isButton,
    );
    expect(more, isNotEmpty, reason: '顶栏应有可读的 More 按钮语义');

    // 页面级 ListView 会把整段正文文本合并进一个语义节点（label 用换行
    // 拼接），因此顺序断言用「按遍历顺序拼接的文本流」做子串位置检查，
    // 覆盖合并节点内部与跨节点的相对顺序。
    final stream = semantics.map((item) => item.label).join('\n');
    final requiredOrder = [
      '感冒观察',
      l10n.reportReviewStatusActive,
      l10n.reportReviewSectionWhatHappened,
      l10n.reportReviewSectionKeyChanges,
      l10n.reportReviewSectionCompletedActions,
      l10n.reportReviewSectionNextStep,
      l10n.reportReviewHistoryTitle,
      l10n.reportMoreTitle,
    ];
    var cursor = -1;
    for (final label in requiredOrder) {
      final index = stream.indexOf(label, cursor + 1);
      expect(
        index,
        greaterThan(cursor),
        reason:
            '语义流中应依序出现 $label（要求：标题 → 状态 → 四段 → 历史 → More）；'
            '实际语义流：$stream',
      );
      cursor = index;
    }
  });
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}

class _PageReviewRepository implements ReviewRepository {
  _PageReviewRepository({required this.current, required this.page});

  final EventReview? current;
  final ReviewEventPage page;

  @override
  Future<EventReview?> fetchCurrentReview() async => current;

  @override
  Future<ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) async {
    return page;
  }

  @override
  Future<EventReview> fetchReview(String eventId) async {
    throw UnimplementedError();
  }
}
