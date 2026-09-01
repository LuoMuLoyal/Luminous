import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:luminous_lints/luminous_lints.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(LayeredImportRuleTest);
  });
}

@reflectiveTest
class LayeredImportRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    // Stub `package:luminous` so that `package:luminous/...` imports resolve
    // inside the test workspace.
    newPackage('luminous')
      ..addFile(
        'lib/features/settings/data/repositories/lucent.dart',
        'class LucentSettingsRepository {}',
      )
      ..addFile(
        'lib/features/settings/domain/repositories/user_settings.dart',
        'class UserSettingsRepository {}',
      )
      ..addFile(
        'lib/features/settings/presentation/widgets/banner.dart',
        'class SettingsBanner {}',
      )
      ..addFile(
        'lib/features/health_context/data/providers/health_context.dart',
        'final healthContextSnapshotProvider = 0;',
      )
      ..addFile(
        'lib/features/record/domain/entities/daily.dart',
        'class DailyRecord {}',
      );
    rule = LayeredImportRule();
    super.setUp();
  }

  Future<void> test_crossFeaturePresentationImport_isReported() async {
    final path = convertPath(
      '/home/test/lib/features/record/presentation/page.dart',
    );
    newFile(path, r'''
import 'package:luminous/features/settings/presentation/widgets/banner.dart';

final usesStub = SettingsBanner();
''');
    await assertDiagnosticsInFile(path, [lint(7, 69)]);
  }

  Future<void> test_crossFeatureDataImport_isReported() async {
    final path = convertPath(
      '/home/test/lib/features/record/data/providers/water.dart',
    );
    newFile(path, r'''
import 'package:luminous/features/settings/data/repositories/lucent.dart';

final usesStub = LucentSettingsRepository();
''');
    await assertDiagnosticsInFile(path, [lint(7, 66)]);
  }

  Future<void> test_coreImportingFeature_isReported() async {
    final path = convertPath('/home/test/lib/core/utils/date.dart');
    newFile(path, r'''
import 'package:luminous/features/health_context/data/providers/health_context.dart';

final usesStub = healthContextSnapshotProvider;
''');
    await assertDiagnosticsInFile(path, [lint(7, 77)]);
  }

  Future<void> test_relativeCrossFeatureImport_isReported() async {
    final path = convertPath(
      '/home/test/lib/features/record/presentation/page.dart',
    );
    newFile(
      '/home/test/lib/features/settings/presentation/widgets/banner.dart',
      'class SettingsBanner {}',
    );
    newFile(path, r'''
import '../../settings/presentation/widgets/banner.dart';

final usesStub = SettingsBanner();
''');
    await assertDiagnosticsInFile(path, [lint(7, 49)]);
  }

  Future<void> test_sameFeatureImport_isNotReported() async {
    final path = convertPath(
      '/home/test/lib/features/record/presentation/page.dart',
    );
    newFile(path, r'''
import 'package:luminous/features/record/domain/entities/daily.dart';

final usesTarget = DailyRecord();
''');
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_dataLayerReadingOtherFeatureDomain_isNotReported() async {
    // Sanctioned by AGENTS.md rule 1: cross-feature reads go through the
    // owning feature's domain interfaces.
    final path = convertPath(
      '/home/test/lib/features/record/data/providers/water.dart',
    );
    newFile(path, r'''
import 'package:luminous/features/settings/domain/repositories/user_settings.dart';

final usesTarget = UserSettingsRepository();
''');
    await assertNoDiagnosticsInFile(path);
  }

  Future<void>
  test_presentationReadingOtherFeatureDataProvider_isNotReported() async {
    // Sanctioned by AGENTS.md rule 2: the shared snapshot hub
    // (healthContextSnapshotProvider) is the documented cross-feature seam.
    final path = convertPath(
      '/home/test/lib/features/record/presentation/page.dart',
    );
    newFile(path, r'''
import 'package:luminous/features/health_context/data/providers/health_context.dart';

final usesTarget = healthContextSnapshotProvider;
''');
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_applicationReadingOtherFeatureDomain_isNotReported() async {
    // Sanctioned by AGENTS.md rule 3: application may import other features'
    // domain layer for cross-feature orchestration.
    final path = convertPath(
      '/home/test/lib/features/record/application/sync.dart',
    );
    newFile(path, r'''
import 'package:luminous/features/settings/domain/repositories/user_settings.dart';

final usesTarget = UserSettingsRepository();
''');
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_nonFeatureFileImportingFeature_isNotReported() async {
    final path = convertPath('/home/test/lib/l10n/bridge.dart');
    newFile(path, r'''
import 'package:luminous/features/record/domain/entities/daily.dart';

final usesTarget = DailyRecord();
''');
    await assertNoDiagnosticsInFile(path);
  }
}
