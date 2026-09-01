import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:luminous_lints/luminous_lints.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoBangOnResponseDataRuleTest);
  });
}

@reflectiveTest
class NoBangOnResponseDataRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoBangOnResponseDataRule();
    super.setUp();
  }

  Future<void> test_bangInDataLayer_isReported() async {
    final path = convertPath(
      '/home/test/lib/features/record/data/repositories/water.dart',
    );
    newFile(path, r'''
void f(dynamic response) {
  final value = response.data!;
}
''');
    await assertDiagnosticsInFile(path, [lint(43, 14)]);
  }

  Future<void> test_bangOutsideDataLayer_isNotReported() async {
    final path = convertPath(
      '/home/test/lib/features/record/presentation/page.dart',
    );
    newFile(path, r'''
void f(dynamic response) {
  final value = response.data!;
}
''');
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_nullAwareInDataLayer_isNotReported() async {
    final path = convertPath(
      '/home/test/lib/features/record/data/repositories/water.dart',
    );
    newFile(path, r'''
void f(dynamic response) {
  final value = response?.data;
}
''');
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_indexBangInDataLayer_isReported() async {
    final path = convertPath(
      '/home/test/lib/features/record/data/repositories/water.dart',
    );
    newFile(path, r'''
void f(List<int?> items) {
  final first = items[0]!;
}
''');
    await assertDiagnosticsInFile(path, [lint(43, 9)]);
  }
}
