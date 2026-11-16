import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/shell/domain/entities/nav_config.dart';
import 'package:luminous/features/shell/domain/services/nav_rules.dart';

/// 导航的**纯规则**：名称清洗、编辑校验、配置补全。
///
/// 这些都是无 I/O 的纯函数，所以每条拒绝语义都用普通单测钉住，
/// 不需要 widget 测试——编排 UI 只是这些规则的调用方。
void main() {
  const allIds = {
    TabId.today,
    TabId.record,
    TabId.medicine,
    TabId.review,
    TabId.mine,
  };
  const defaultOrder = [
    TabId.today,
    TabId.record,
    TabId.medicine,
    TabId.review,
    TabId.mine,
  ];

  NavConfig configOf(List<TabPlacement> tabs) => NavConfig(tabs: tabs);

  NavConfig fullConfig({
    String? todayLabel,
    String? todayIcon,
    bool todayVisible = true,
    List<TabId>? order,
  }) {
    final ids = order ?? defaultOrder;
    return configOf([
      for (var i = 0; i < ids.length; i++)
        TabPlacement(
          tabId: ids[i],
          order: i,
          customLabel: ids[i] == TabId.today ? todayLabel : null,
          iconName: ids[i] == TabId.today ? todayIcon : null,
          isVisible: ids[i] == TabId.today ? todayVisible : true,
        ),
    ]);
  }

  group('validateTabLabel', () {
    test('accepts a plain Chinese label', () {
      final result = validateTabLabel('总结');
      expect(result.isAccepted, isTrue);
      expect(result.value, '总结');
    });

    test('trims surrounding whitespace', () {
      expect(validateTabLabel('  用药台  ').value, '用药台');
    });

    test('null means "use the default label" and is accepted', () {
      final result = validateTabLabel(null);
      expect(result.isAccepted, isTrue);
      expect(result.value, isNull);
    });

    test('rejects blank input', () {
      expect(validateTabLabel('   ').errorCode, TabLabelErrorCode.empty);
    });

    test('accepts exactly the grapheme limit', () {
      expect(validateTabLabel('a' * maxTabLabelGraphemes).isAccepted, isTrue);
    });

    test('rejects one past the grapheme limit', () {
      expect(
        validateTabLabel('a' * (maxTabLabelGraphemes + 1)).errorCode,
        TabLabelErrorCode.tooLong,
      );
    });

    test('counts CJK characters individually', () {
      // 中文按 12 个字素预算；12 个汉字通过，13 个被拒。
      expect(validateTabLabel('一二三四五六七八九十一二').isAccepted, isTrue);
      expect(
        validateTabLabel('一二三四五六七八九十一二三').errorCode,
        TabLabelErrorCode.tooLong,
      );
    });

    test('a combining accent does not consume a grapheme slot', () {
      // 'e' + U+0301 是一个字素；12 个组合字素仍在预算内。
      expect(validateTabLabel(('e\u0301') * 12).isAccepted, isTrue);
    });

    test('rejects zero-width characters', () {
      expect(
        validateTabLabel('用\u200B药').errorCode,
        TabLabelErrorCode.forbiddenCharacters,
      );
    });

    test('rejects bidi override characters', () {
      // 这类字符能把「用药」显示成别的样子。
      expect(
        validateTabLabel('\u202E用药').errorCode,
        TabLabelErrorCode.forbiddenCharacters,
      );
    });

    test('rejects the zero-width no-break space (BOM) mid-string', () {
      // 放在词中间：`trim()` 会剥掉首尾的空白（BOM 属于空白类），
      // 只有词内才是真正「能塞进去又看不见」的位置。
      expect(
        validateTabLabel('用\uFEFF药').errorCode,
        TabLabelErrorCode.forbiddenCharacters,
      );
    });
  });

  group('validateNavConfig – structural checks', () {
    test('accepts the default config unchanged', () {
      const config = NavConfig();
      final result = validateNavConfig(config, knownTabIds: allIds);
      expect(result.isAccepted, isTrue);
      expect(result.config, config);
    });

    test('rejects an unknown tab id', () {
      final config = configOf([
        const TabPlacement(tabId: TabId('nope'), order: 0),
        for (var i = 1; i < 5; i++)
          TabPlacement(tabId: defaultOrder[i], order: i),
      ]);

      final result = validateNavConfig(config, knownTabIds: allIds);

      expect(result.rejection, NavRuleViolation.unknownTabId);
      // 被拒绝时返回的仍是原配置，不是半成品。
      expect(result.config, config);
    });

    test('rejects a duplicate tab id', () {
      final config = configOf([
        const TabPlacement(tabId: TabId.today, order: 0),
        const TabPlacement(tabId: TabId.record, order: 1),
        const TabPlacement(tabId: TabId.medicine, order: 2),
        const TabPlacement(tabId: TabId.today, order: 3),
      ]);

      expect(
        validateNavConfig(config, knownTabIds: allIds).rejection,
        NavRuleViolation.duplicateTabId,
      );
    });

    test('rejects an invalid custom label', () {
      final config = fullConfig(todayLabel: 'a' * 30);

      expect(
        validateNavConfig(config, knownTabIds: allIds).rejection,
        NavRuleViolation.invalidLabel,
      );
    });

    test('rejects an unknown icon when a resolver is supplied', () {
      final config = fullConfig(todayIcon: 'not-an-icon');

      expect(
        validateNavConfig(
          config,
          knownTabIds: allIds,
          isKnownIcon: (name) => name == 'pill',
        ).rejection,
        NavRuleViolation.unknownIcon,
      );
    });

    test('accepts a known icon', () {
      final config = fullConfig(todayIcon: 'pill');

      expect(
        validateNavConfig(
          config,
          knownTabIds: allIds,
          isKnownIcon: (name) => name == 'pill',
        ).isAccepted,
        isTrue,
      );
    });

    test('skips icon validation when no resolver is supplied', () {
      final config = fullConfig(todayIcon: 'whatever');
      expect(validateNavConfig(config, knownTabIds: allIds).isAccepted, isTrue);
    });
  });

  group('validateNavConfig – visibility rules', () {
    test('rejects fewer than three visible tabs', () {
      final config = configOf([
        const TabPlacement(tabId: TabId.today, order: 0),
        const TabPlacement(tabId: TabId.record, order: 1),
        const TabPlacement(tabId: TabId.medicine, order: 2, isVisible: false),
        const TabPlacement(tabId: TabId.review, order: 3, isVisible: false),
        const TabPlacement(tabId: TabId.mine, order: 4, isVisible: false),
      ]);

      expect(
        validateNavConfig(config, knownTabIds: allIds).rejection,
        NavRuleViolation.tooFewVisible,
      );
    });

    test('accepts exactly three visible tabs', () {
      final config = configOf([
        const TabPlacement(tabId: TabId.today, order: 0),
        const TabPlacement(tabId: TabId.record, order: 1),
        const TabPlacement(tabId: TabId.medicine, order: 2),
        const TabPlacement(tabId: TabId.review, order: 3, isVisible: false),
        const TabPlacement(tabId: TabId.mine, order: 4, isVisible: false),
      ]);

      expect(validateNavConfig(config, knownTabIds: allIds).isAccepted, isTrue);
    });

    test('rejects hiding the home tab', () {
      // today 同时是冷启动落点，藏起来会让首屏无处可去。
      final config = fullConfig(todayVisible: false);

      expect(
        validateNavConfig(config, knownTabIds: allIds).rejection,
        NavRuleViolation.homeTabHidden,
      );
    });

    test('accepts hiding any non-home tab down to the minimum', () {
      final config = configOf([
        const TabPlacement(tabId: TabId.today, order: 0),
        const TabPlacement(tabId: TabId.record, order: 1, isVisible: false),
        const TabPlacement(tabId: TabId.medicine, order: 2, isVisible: false),
        const TabPlacement(tabId: TabId.review, order: 3),
        const TabPlacement(tabId: TabId.mine, order: 4),
      ]);

      expect(validateNavConfig(config, knownTabIds: allIds).isAccepted, isTrue);
    });
  });

  group('completeNavConfig', () {
    test('default config resolves to the registry order', () {
      final completed = completeNavConfig(const NavConfig(), defaultOrder);

      expect(completed.map((t) => t.tabId), defaultOrder);
      expect(completed.map((t) => t.order), [0, 1, 2, 3, 4]);
      expect(completed.every((t) => t.isVisible), isTrue);
    });

    test('preserves a user-defined order', () {
      const userOrder = [
        TabId.medicine,
        TabId.today,
        TabId.record,
        TabId.mine,
        TabId.review,
      ];
      final config = fullConfig(order: userOrder);

      final completed = completeNavConfig(config, defaultOrder);

      expect(completed.map((t) => t.tabId), userOrder);
    });

    test('normalises sparse orders into 0..n-1', () {
      final config = configOf([
        const TabPlacement(tabId: TabId.today, order: 100),
        const TabPlacement(tabId: TabId.record, order: 500),
        const TabPlacement(tabId: TabId.medicine, order: 900),
      ]);

      final completed = completeNavConfig(config, defaultOrder);

      // 注册表其余两项被补全回来，所有 order 重新归一成 0..n-1。
      expect(completed.map((t) => t.order), [0, 1, 2, 3, 4]);
      expect(completed.take(3).map((t) => t.tabId), [
        TabId.today,
        TabId.record,
        TabId.medicine,
      ]);
    });

    test('appends tabs added to the registry after the config was saved', () {
      // 老配置只认识前三个；注册表后来多了两个。
      final config = configOf([
        const TabPlacement(tabId: TabId.today, order: 0),
        const TabPlacement(tabId: TabId.record, order: 1),
        const TabPlacement(tabId: TabId.medicine, order: 2),
      ]);

      final completed = completeNavConfig(config, defaultOrder);

      expect(completed.map((t) => t.tabId), defaultOrder);
    });

    test('inserts a new tab at its default position, not at the end', () {
      // 保存时只知道 today/review；record 的默认位置在 today 之后。
      final config = configOf([
        const TabPlacement(tabId: TabId.today, order: 0),
        const TabPlacement(tabId: TabId.review, order: 1),
      ]);

      final completed = completeNavConfig(config, defaultOrder);

      final ids = completed.map((t) => t.tabId).toList();
      expect(ids.indexOf(TabId.record), ids.indexOf(TabId.today) + 1);
    });

    test('drops tabs removed from the registry', () {
      final config = configOf([
        const TabPlacement(tabId: TabId.today, order: 0),
        const TabPlacement(tabId: TabId('retired'), order: 1),
        const TabPlacement(tabId: TabId.record, order: 2),
      ]);

      final completed = completeNavConfig(config, defaultOrder);

      expect(
        completed.map((t) => t.tabId),
        isNot(contains(const TabId('retired'))),
      );
    });

    test('preserves visibility and custom fields through completion', () {
      final config = configOf([
        const TabPlacement(
          tabId: TabId.today,
          order: 0,
          customLabel: '总结',
          iconName: 'pill',
        ),
        const TabPlacement(tabId: TabId.record, order: 1, isVisible: false),
      ]);

      final completed = completeNavConfig(config, defaultOrder);
      final today = completed.firstWhere((t) => t.tabId == TabId.today);
      final record = completed.firstWhere((t) => t.tabId == TabId.record);

      expect(today.customLabel, '总结');
      expect(today.iconName, 'pill');
      expect(record.isVisible, isFalse);
    });

    test('never emits duplicate tab ids', () {
      final config = configOf([
        const TabPlacement(tabId: TabId.today, order: 0),
        const TabPlacement(tabId: TabId.today, order: 1),
      ]);

      final completed = completeNavConfig(config, defaultOrder);

      // 重复项去重后补全成完整注册表：5 项、id 互不相同、today 只出现一次。
      expect(completed, hasLength(defaultOrder.length));
      expect(
        completed.map((t) => t.tabId).toSet(),
        hasLength(defaultOrder.length),
      );
      expect(completed.where((t) => t.tabId == TabId.today), hasLength(1));
    });
  });

  group('visibleTabs', () {
    test('filters hidden tabs out', () {
      const tabs = [
        TabPlacement(tabId: TabId.today, order: 0),
        TabPlacement(tabId: TabId.record, order: 1, isVisible: false),
        TabPlacement(tabId: TabId.medicine, order: 2),
      ];

      expect(visibleTabs(tabs).map((t) => t.tabId), [
        TabId.today,
        TabId.medicine,
      ]);
    });
  });
}
