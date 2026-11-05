import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/auth_session_adapter.dart';
import 'package:luminous/app/composition/health_context/health_context.dart';
import 'package:luminous/app/composition/record/record_access.dart';
import 'package:luminous/app/composition/snapshot/record.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/record/presentation/pages/page.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../helpers/composition.dart';
import '../../../helpers/feature_mocks.dart';
import '../../../helpers/kv_test_store.dart';
import '../../../helpers/test_forui_app.dart';

/// 记录页首屏的纵向间距。
///
/// 这一页顶部由三段高度叠出来：`FHeader`（状态栏 + 工具栏）、页面内容区的
/// 顶部内边距、日期条自身的高度。三者任一处变动都会让标题与日期条之间出现
/// 一块说不出理由的空白——真机 390×844 上曾经叠到约 40dp，标题看起来像
/// 「悬在半空」。断言因此盯着**标题文字与日期条的像素距离**，而不是盯某个
/// 具体的 padding 值：间距怎么实现可以改，读起来"不空"不许回退。
void main() {
  setUp(() => KvTestStore.install());

  /// 手机竖屏尺寸（与 `setMobileScreenSize` 同口径），这里显式指定以便
  /// 注释里给出的像素值可以直接对照。
  void usePhoneViewport(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
  }

  testWidgets('Record 标题与日期条之间不出现多余空白', (tester) async {
    usePhoneViewport(tester);
    await _pumpRecordPage(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 标题文字用页面级标题的 l10n 文案定位：`FHeader` 是 Forui 的私有实现，
    // 按类型取不到，按文字既稳定又正是用户看到的那一行。
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final title = find.text(l10n.tabRecord);
    final dateBar = find.byType(FLineCalendar);
    expect(title, findsOneWidget, reason: '记录页顶部应有标题');
    expect(dateBar, findsOneWidget, reason: '记录页首屏应有日期条');

    final titleRect = tester.getRect(title);
    final dateBarRect = tester.getRect(dateBar);

    // 标题文字底部 -> 日期条顶部。量文字而不是标题栏外框：外框高度里有一大段
    // 垂直居中的余量（58dp 的工具栏只放约 20dp 文字），那段余量正是曾经读起来
    // 「标题悬在半空」的来源。
    final gap = dateBarRect.top - titleRect.bottom;

    // 上界：标题文字与日期条之间最多一档常规间距。
    expect(
      gap,
      lessThanOrEqualTo(30.0),
      reason:
          '标题与日期条间距过大（实测 ${gap.toStringAsFixed(1)}dp）。'
          '检查 FHeader 的 padding 与页面 contentVerticalPadding 是否重复计数。',
    );

    // 下界：不能压到贴死，日期条需要与标题分离才读得出「下面是内容」。
    expect(
      gap,
      greaterThanOrEqualTo(4.0),
      reason: '标题与日期条贴死了（实测 ${gap.toStringAsFixed(1)}dp）',
    );
  });

  testWidgets('Record 日期条完整可见，首屏不被标题栏挤掉', (tester) async {
    usePhoneViewport(tester);
    await _pumpRecordPage(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final titleRect = tester.getRect(
      find.text(
        (await AppLocalizations.delegate.load(const Locale('zh'))).tabRecord,
      ),
    );
    final dateBarRect = tester.getRect(find.byType(FLineCalendar));

    expect(
      dateBarRect.top,
      greaterThanOrEqualTo(titleRect.bottom),
      reason: '日期条不应与标题重叠',
    );
    expect(dateBarRect.height, greaterThan(0), reason: '日期条高度为 0，说明它被父级约束压扁了');
  });
}

Future<void> _pumpRecordPage(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...compositionTestOverrides(),
        recordRepositoryProvider.overrideWithValue(
          const MockRecordRepository(),
        ),
        dailyRecordRepositoryProvider.overrideWithValue(
          _FakeDailyRecordRepository(),
        ),
        authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
        healthContextSnapshotProvider.overrideWith(
          (ref) async => const HealthContextSnapshot(
            summary: HealthSummary(
              age: 27,
              onboardingCompleted: true,
              activeAllergyCount: 0,
              conditionCount: 0,
              currentMedicineCount: 0,
              missingCoreProfileFields: [],
            ),
            profile: HealthProfile(
              birthDate: '1999-01-15',
              sexAtBirth: 'male',
              heightCm: null,
              weightKg: null,
              activityLevel: null,
              dietaryPreferences: null,
              locale: null,
              timezone: null,
              unitSystem: null,
              onboardingCompletedAt: '2026-01-01T00:00:00Z',
              extras: {},
            ),
            allergies: [],
            conditions: [],
            currentMedicines: [],
          ),
        ),
      ],
      child: const TestForuiApp(home: RecordPage()),
    ),
  );
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => AuthSessionState(
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

class _FakeDailyRecordRepository implements DailyRecordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
