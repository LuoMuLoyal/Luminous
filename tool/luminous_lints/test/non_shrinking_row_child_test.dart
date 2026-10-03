import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:luminous_lints/luminous_lints.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NonShrinkingRowChildRuleTest);
  });
}

/// The stubs at the bottom of each snippet stand in for the Flutter/Forui
/// widgets: the rule matches constructor and static-type names, so the tests
/// need no Flutter dependency.
@reflectiveTest
class NonShrinkingRowChildRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NonShrinkingRowChildRule();
    super.setUp();
  }

  Future<void> test_textAndFBadge_isReported() async {
    await assertDiagnostics(
      r'''
void f() {
  Row(children: [Text('Status'), FBadge()]);
}

class Row {
  Row({required List<Object> children});
}

class Text {
  Text(String data);
}

class FBadge {
  FBadge();
}
''',
      [lint(13, 41)],
    );
  }

  Future<void> test_expandedTextAndHandRolledPill_isReported() async {
    // The hand-rolled `_*Pill` wrapper matches the type-name shape; the flex
    // child makes the text sibling implicit rather than a bare `Text`.
    await assertDiagnostics(
      r'''
void f() {
  Row(
    children: [
      Expanded(child: Text('Status')),
      const _StatusPill(),
    ],
  );
}

class Row {
  Row({required List<Object> children});
}

class Expanded {
  Expanded({required Object child});
}

class Text {
  Text(String data);
}

class _StatusPill {
  const _StatusPill();
}
''',
      [lint(13, 97)],
    );
  }

  Future<void> test_fButton_isReported() async {
    await assertDiagnostics(
      r'''
void f() {
  Row(children: [Text('Label'), FButton()]);
}

class Row {
  Row({required List<Object> children});
}

class Text {
  Text(String data);
}

class FButton {
  FButton();
}
''',
      [lint(13, 41)],
    );
  }

  Future<void> test_badgeWrappedInFlexible_isNotReported() async {
    await assertNoDiagnostics(r'''
void f() {
  Row(children: [Text('Status'), Flexible(child: FBadge())]);
}

class Row {
  Row({required List<Object> children});
}

class Text {
  Text(String data);
}

class Flexible {
  Flexible({required Object child});
}

class FBadge {
  FBadge();
}
''');
  }

  Future<void> test_badgeWrappedInSizedBoxWithWidth_isNotReported() async {
    await assertNoDiagnostics(r'''
void f() {
  Row(children: [Text('Status'), SizedBox(width: 96, child: FBadge())]);
}

class Row {
  Row({required List<Object> children});
}

class Text {
  Text(String data);
}

class SizedBox {
  SizedBox({double? width, required Object child});
}

class FBadge {
  FBadge();
}
''');
  }

  Future<void> test_badgeWrappedInConstrainedBox_isNotReported() async {
    await assertNoDiagnostics(r'''
void f() {
  Row(children: [
    Text('Status'),
    ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 96),
      child: FBadge(),
    ),
  ]);
}

class Row {
  Row({required List<Object> children});
}

class Text {
  Text(String data);
}

class ConstrainedBox {
  ConstrainedBox({required Object constraints, required Object child});
}

class BoxConstraints {
  const BoxConstraints({double? maxWidth});
}

class FBadge {
  FBadge();
}
''');
  }

  Future<void> test_wrapInsteadOfRow_isNotReported() async {
    // `Wrap` shrink-wraps its children, so the same child is safe there.
    await assertNoDiagnostics(r'''
void f() {
  Wrap(children: [Text('Status'), FBadge()]);
}

class Wrap {
  Wrap({required List<Object> children});
}

class Text {
  Text(String data);
}

class FBadge {
  FBadge();
}
''');
  }

  Future<void> test_rowWithoutBadge_isNotReported() async {
    await assertNoDiagnostics(r'''
void f() {
  Row(children: [Text('Status'), Icon()]);
}

class Row {
  Row({required List<Object> children});
}

class Text {
  Text(String data);
}

class Icon {
  Icon();
}
''');
  }

  Future<void> test_rowWithoutTextSibling_isNotReported() async {
    await assertNoDiagnostics(r'''
void f() {
  Row(children: [Icon(), FBadge()]);
}

class Row {
  Row({required List<Object> children});
}

class Icon {
  Icon();
}

class FBadge {
  FBadge();
}
''');
  }

  Future<void> test_nonWidgetSibling_isNotReported() async {
    // `Spacer` is flexible and contributes no text; a `Text` elsewhere in the
    // tree does not make this row a squeeze candidate.
    await assertNoDiagnostics(r'''
void f() {
  Row(children: [Icon(), Spacer(), FBadge()]);
}

class Row {
  Row({required List<Object> children});
}

class Icon {
  Icon();
}

class Spacer {
  Spacer();
}

class FBadge {
  FBadge();
}
''');
  }

  Future<void> test_nonListChildren_isNotReported() async {
    await assertNoDiagnostics(r'''
void f(List<Object> children) {
  Row(children: children);
}

class Row {
  Row({required List<Object> children});
}
''');
  }

  Future<void> test_outsideLib_isNotReported() async {
    final path = convertPath('/home/test/tool/widget.dart');
    newFile(path, r'''
void f() {
  Row(children: [Text('Status'), FBadge()]);
}

class Row {
  Row({required List<Object> children});
}

class Text {
  Text(String data);
}

class FBadge {
  FBadge();
}
''');
    await assertNoDiagnosticsInFile(path);
  }
}
