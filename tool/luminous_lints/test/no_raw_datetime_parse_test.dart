import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:luminous_lints/luminous_lints.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoRawDatetimeParseRuleTest);
  });
}

@reflectiveTest
class NoRawDatetimeParseRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoRawDatetimeParseRule();
    super.setUp();
  }

  Future<void> test_directParse_isReported() async {
    await assertDiagnostics(
      r'''
void f(String raw) {
  DateTime.parse(raw);
}

class DateTime {
  DateTime._();
  static DateTime parse(String input) => DateTime._();
}
''',
      [lint(23, 19)],
    );
  }

  Future<void> test_safeWrapper_isNotReported() async {
    await assertNoDiagnostics(r'''
DateTime? parseDateTimeOrNull(Object? value) => null;

void f(String raw) {
  parseDateTimeOrNull(raw);
}
''');
  }

  Future<void> test_outsideLib_isNotReported() async {
    final path = convertPath('/home/test/tool/gen.dart');
    newFile(path, r'''
void f(String raw) {
  DateTime.parse(raw);
}

void main() {
  f('2026-08-31');
}

class DateTime {
  DateTime._();
  static DateTime parse(String input) => DateTime._();
}
''');
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_parseInToolScript_isNotReported() async {
    final path = convertPath('/home/test/test/sync_test.dart');
    newFile(path, r'''
void f(String raw) {
  DateTime.parse(raw);
}

void main() {
  f('2026-08-31');
}

class DateTime {
  DateTime._();
  static DateTime parse(String input) => DateTime._();
}
''');
    await assertNoDiagnosticsInFile(path);
  }
}
