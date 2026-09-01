import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:luminous_lints/luminous_lints.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(EmptyCatchRequiresCommentRuleTest);
  });
}

@reflectiveTest
class EmptyCatchRequiresCommentRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = EmptyCatchRequiresCommentRule();
    super.setUp();
  }

  Future<void> test_emptyCatchNoComment_isReported() async {
    await assertDiagnostics(
      r'''
void f() {
  try {} catch (_) {}
}
''',
      [lint(20, 12)],
    );
  }

  Future<void> test_onCatchEmptyNoComment_isReported() async {
    await assertDiagnostics(
      r'''
void f() {
  try {} on FormatException {}
}
''',
      [lint(20, 21)],
    );
  }

  Future<void> test_emptyCatchWithComment_isNotReported() async {
    await assertNoDiagnostics(r'''
void f() {
  try {} catch (_) {
    // Intentional: best-effort cleanup, nothing to recover.
  }
}
''');
  }

  Future<void> test_catchWithStatement_isNotReported() async {
    await assertNoDiagnostics(r'''
void f() {
  try {} catch (e) {
    print(e);
  }
}
''');
  }

  Future<void> test_outsideLib_isNotReported() async {
    final path = convertPath('/home/test/tool/gen.dart');
    newFile(path, r'''
void f() {
  try {} catch (_) {}
}
''');
    await assertNoDiagnosticsInFile(path);
  }
}
