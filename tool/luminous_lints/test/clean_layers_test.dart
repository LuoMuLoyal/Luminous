import 'package:luminous_lints/src/clean_layers.dart';
import 'package:luminous_lints/src/directory_shape.dart';
import 'package:test/test.dart';

/// The strict Clean Architecture rules are a single pure predicate
/// ([checkImportPath]) plus the two directory predicates. Testing the predicate
/// directly keeps the suite fast and lets the CLI driver and the AST rules share
/// exactly one implementation.
void main() {
  group('domain_purity (R1/R2)', () {
    test('same feature domain is allowed', () {
      expect(
        checkImportPath(
          importer: 'lib/features/record/domain/entities/daily.dart',
          target: 'lib/features/record/domain/entities/record.dart',
        ),
        isNull,
      );
    });

    test('domain importing its own data layer is reported', () {
      expect(
        checkImportPath(
          importer: 'lib/features/medicine/domain/services/planner.dart',
          target: 'lib/features/medicine/data/datasources/remote.dart',
        ),
        'domain_purity',
      );
    });

    test('domain importing another feature domain is reported', () {
      expect(
        checkImportPath(
          importer: 'lib/features/record/domain/entities/daily.dart',
          target: 'lib/features/medicine/domain/entities/medicine.dart',
        ),
        'domain_purity',
      );
    });

    test('domain importing core is reported', () {
      expect(
        checkImportPath(
          importer: 'lib/features/record/domain/entities/daily.dart',
          target: 'lib/core/utils/date_format.dart',
        ),
        'domain_purity',
      );
    });

    test('domain importing the shared kernel is allowed', () {
      expect(
        checkImportPath(
          importer: 'lib/features/record/domain/repositories/daily.dart',
          target: 'lib/shared/domain/failure.dart',
        ),
        isNull,
      );
    });
  });

  group('application_layer (R3)', () {
    test('same feature domain is allowed', () {
      expect(
        checkImportPath(
          importer: 'lib/features/record/application/use_cases/log_water.dart',
          target: 'lib/features/record/domain/repositories/daily.dart',
        ),
        isNull,
      );
    });

    test('another feature domain is allowed (published language)', () {
      // AGENTS.md §Cross-Feature Import Rules: "application -> domain allowed:
      // the application layer may import other features' domain layer for
      // cross-feature orchestration".
      expect(
        checkImportPath(
          importer: 'lib/features/today/application/use_cases/skip_dose.dart',
          target: 'lib/features/medicine/domain/repositories/dose_log.dart',
        ),
        isNull,
      );
    });

    test('shared kernel is allowed', () {
      expect(
        checkImportPath(
          importer: 'lib/features/record/application/use_cases/log_water.dart',
          target: 'lib/shared/domain/failure.dart',
        ),
        isNull,
      );
    });

    test('application importing presentation is reported', () {
      expect(
        checkImportPath(
          importer: 'lib/features/record/application/use_cases/log_water.dart',
          target: 'lib/features/record/presentation/providers/dashboard.dart',
        ),
        'application_layer',
      );
    });

    test('application importing data is reported', () {
      expect(
        checkImportPath(
          importer: 'lib/features/record/application/use_cases/log_water.dart',
          target: 'lib/features/record/data/repositories/lucent.dart',
        ),
        'application_layer',
      );
    });
  });

  group('presentation_layer (R5)', () {
    test('presentation reading its own providers is allowed', () {
      expect(
        checkImportPath(
          importer: 'lib/features/today/presentation/pages/page.dart',
          target: 'lib/features/today/presentation/providers/dashboard.dart',
        ),
        isNull,
      );
    });

    test('presentation importing data is reported (no provider carve-out)', () {
      expect(
        checkImportPath(
          importer: 'lib/features/today/presentation/providers/dashboard.dart',
          target: 'lib/features/today/data/repositories/lucent.dart',
        ),
        'presentation_layer',
      );
    });

    test('presentation importing generated localizations is allowed', () {
      expect(
        checkImportPath(
          importer: 'lib/features/today/presentation/pages/page.dart',
          target: 'lib/l10n/app_localizations.dart',
        ),
        isNull,
      );
    });

    test('presentation importing the auth session adapter is allowed', () {
      // `AuthSessionState.user` is `Object?` in the feature-free core layer; the
      // app-level adapter gives presentation its typed `AuthUser` accessor.
      expect(
        checkImportPath(
          importer: 'lib/features/settings/presentation/pages/profile.dart',
          target: 'lib/app/auth_session_adapter.dart',
        ),
        isNull,
      );
    });

    test('presentation importing core/auth is reported', () {
      expect(
        checkImportPath(
          importer:
              'lib/features/assistant/presentation/providers/conversation.dart',
          target: 'lib/core/auth/session_provider.dart',
        ),
        'presentation_layer',
      );
    });

    test('presentation importing core/design is allowed', () {
      expect(
        checkImportPath(
          importer: 'lib/features/today/presentation/pages/page.dart',
          target: 'lib/core/design/design.dart',
        ),
        isNull,
      );
    });
  });

  group('cross_feature_import (R6)', () {
    test('another feature domain is allowed (published language)', () {
      expect(
        checkImportPath(
          importer: 'lib/features/today/data/repositories/lucent.dart',
          target: 'lib/features/medicine/domain/entities/reminder.dart',
        ),
        isNull,
      );
    });

    test('another feature data is reported', () {
      expect(
        checkImportPath(
          importer: 'lib/features/today/data/repositories/lucent.dart',
          target: 'lib/features/medicine/data/repositories/lucent.dart',
        ),
        'cross_feature_import',
      );
    });

    test('another feature presentation page/widget is reported', () {
      expect(
        checkImportPath(
          importer: 'lib/features/scan/presentation/pages/barcode_scanner.dart',
          target: 'lib/features/search/presentation/widgets/result_card.dart',
        ),
        'cross_feature_import',
      );
    });

    // The two sanctioned seams (AGENTS.md §Cross-Feature Import Rules and the
    // observation-mode layered_import rule): cross-feature reads go through the
    // owner's `presentation/providers/`, and the tab shell is shared by every
    // tab root. Without the provider seam a component could not be mounted on a
    // second surface, because it would have no legal way to read that feature's
    // read model.
    test('another feature read-model providers are allowed', () {
      expect(
        checkImportPath(
          importer: 'lib/features/today/presentation/components/catalog.dart',
          target:
              'lib/features/medicine/presentation/providers/data_access.dart',
        ),
        isNull,
      );
    });

    test('cross-feature shell infrastructure is allowed', () {
      expect(
        checkImportPath(
          importer: 'lib/features/today/presentation/pages/page.dart',
          target: 'lib/features/shell/presentation/deferred_content.dart',
        ),
        isNull,
      );
    });

    test('another feature data is still reported', () {
      expect(
        checkImportPath(
          importer: 'lib/features/today/presentation/components/catalog.dart',
          target: 'lib/features/medicine/data/repositories/lucent.dart',
        ),
        'cross_feature_import',
      );
    });
  });

  group('data_layer (R4)', () {
    test('data importing its own domain is allowed', () {
      expect(
        checkImportPath(
          importer: 'lib/features/record/data/repositories/lucent.dart',
          target: 'lib/features/record/domain/repositories/daily.dart',
        ),
        isNull,
      );
    });

    test('data importing core/network is allowed', () {
      expect(
        checkImportPath(
          importer: 'lib/features/record/data/repositories/lucent.dart',
          target: 'lib/core/network/client/client.dart',
        ),
        isNull,
      );
    });

    test('data importing core/widgets is reported', () {
      expect(
        checkImportPath(
          importer: 'lib/features/record/data/utils/mappers.dart',
          target: 'lib/core/widgets/common/app_toast.dart',
        ),
        'data_layer',
      );
    });

    test('data importing its own presentation is reported', () {
      expect(
        checkImportPath(
          importer: 'lib/features/record/data/repositories/lucent.dart',
          target:
              'lib/features/record/presentation/utils/date_time_formatters.dart',
        ),
        'data_layer',
      );
    });
  });

  group('core_not_import_features (R7)', () {
    test('core importing a feature is reported (no carve-out)', () {
      expect(
        checkImportPath(
          importer: 'lib/core/auth/session_provider.dart',
          target: 'lib/features/auth/domain/entities/session.dart',
        ),
        'core_not_import_features',
      );
    });

    test('core importing core is allowed', () {
      expect(
        checkImportPath(
          importer: 'lib/core/auth/session_provider.dart',
          target: 'lib/core/network/client/client.dart',
        ),
        isNull,
      );
    });
  });

  group('directory_shape (R8/R9)', () {
    test('eight direct sources is allowed', () {
      expect(
        checkDirectory(
          directory: 'lib/features/x/presentation/pages',
          directSourceFileCount: 8,
        ),
        isNull,
      );
    });

    test('nine direct sources is reported', () {
      expect(
        checkDirectory(
          directory: 'lib/features/x/presentation/pages',
          directSourceFileCount: 9,
        ),
        startsWith('directory_file_cap'),
      );
    });

    test('data/providers is forbidden', () {
      expect(
        checkDirectory(
          directory: 'lib/features/x/data/providers',
          directSourceFileCount: 0,
        ),
        startsWith('forbidden_directory'),
      );
    });

    test('presentation/services is forbidden', () {
      expect(
        checkDirectory(
          directory: 'lib/features/x/presentation/services',
          directSourceFileCount: 1,
        ),
        startsWith('forbidden_directory'),
      );
    });

    test('generated sources are not counted', () {
      expect(isGeneratedSourceName('page.g.dart'), isTrue);
      expect(isGeneratedSourceName('page.freezed.dart'), isTrue);
      expect(isGeneratedSourceName('page.dart'), isFalse);
    });
  });
}
