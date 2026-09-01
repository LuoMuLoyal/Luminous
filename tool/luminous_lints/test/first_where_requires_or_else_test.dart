import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:luminous_lints/luminous_lints.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FirstWhereRequiresOrElseRuleTest);
  });
}

@reflectiveTest
class FirstWhereRequiresOrElseRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = FirstWhereRequiresOrElseRule();
    super.setUp();
  }

  Future<void> test_withoutOrElse_isReported() async {
    await assertDiagnostics(
      r'''
void f(List<int> items) {
  items.firstWhere((item) => item > 0);
}
''',
      [lint(34, 10)],
    );
  }

  Future<void> test_withOrElse_isNotReported() async {
    await assertNoDiagnostics(r'''
void f(List<int> items) {
  items.firstWhere((item) => item > 0, orElse: () => -1);
}
''');
  }

  Future<void> test_chainedWithoutOrElse_isReported() async {
    await assertDiagnostics(
      r'''
void f(List<int> items) {
  items.where((item) => item > 0).firstWhere((item) => item.isEven);
}
''',
      [lint(60, 10)],
    );
  }

  Future<void> test_chainedWithOrElse_isNotReported() async {
    await assertNoDiagnostics(r'''
void f(List<int> items) {
  items.where((item) => item > 0).firstWhere(
        (item) => item.isEven,
        orElse: () => 0,
      );
}
''');
  }
}
