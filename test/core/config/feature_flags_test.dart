import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/ai/runtime_config.dart';
import 'package:luminous/core/config/env_keys.dart';
import 'package:luminous/core/config/env_reader.dart';
import 'package:luminous/core/config/feature_flags.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  ProviderContainer buildContainer({Map<String, Object>? initialValues}) {
    SharedPreferences.setMockInitialValues(
      initialValues ?? const <String, Object>{},
    );
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    EnvReader.clearTestValues();
  });

  tearDown(() {
    EnvReader.clearTestValues();
  });

  group('FeatureFlagsState.enabledCount', () {
    test('returns 1 for default state (assistantStreamMode defaults true)', () {
      const state = FeatureFlagsState();
      expect(state.enabledCount, 1);
    });

    test('counts onDeviceAiRuntime in addition to default', () {
      const state = FeatureFlagsState(onDeviceAiRuntime: true);
      expect(state.enabledCount, 2);
    });

    test('counts genUiEnabled in addition to default', () {
      const state = FeatureFlagsState(genUiEnabled: true);
      expect(state.enabledCount, 2);
    });

    test('counts assistantStreamMode', () {
      const state = FeatureFlagsState(assistantStreamMode: true);
      expect(state.enabledCount, 1);
    });

    test('counts medicineBarcodeScan in addition to default', () {
      const state = FeatureFlagsState(medicineBarcodeScan: true);
      expect(state.enabledCount, 2);
    });

    test('counts reportExportPdf in addition to default', () {
      const state = FeatureFlagsState(reportExportPdf: true);
      expect(state.enabledCount, 2);
    });

    test('returns 0 when all flags are disabled', () {
      const state = FeatureFlagsState(assistantStreamMode: false);
      expect(state.enabledCount, 0);
    });

    test('counts all enabled flags', () {
      const state = FeatureFlagsState(
        onDeviceAiRuntime: true,
        genUiEnabled: true,
        assistantStreamMode: true,
        medicineBarcodeScan: true,
        reportExportPdf: true,
      );
      expect(state.enabledCount, 5);
    });

    test('totalCount is 5', () {
      expect(FeatureFlagsState.totalCount, 5);
    });
  });

  group('FeatureFlagsController.build', () {
    test('uses default values when no preferences are stored', () async {
      container = buildContainer();

      final state = await container.read(featureFlagsControllerProvider.future);

      expect(state.onDeviceAiRuntime, isFalse);
      expect(state.aiRuntimeProvider, AiRuntimeProviderKind.none);
      expect(state.genUiEnabled, isFalse);
      expect(state.assistantStreamMode, isTrue);
      expect(state.medicineBarcodeScan, isFalse);
      expect(state.reportExportPdf, isFalse);
    });

    test('loads persisted values', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'featureFlags.onDeviceAiRuntime': true,
          'featureFlags.aiRuntimeProvider': 'aiToolkit',
          'featureFlags.genUiEnabled': true,
          'featureFlags.assistantStreamMode': false,
          'featureFlags.medicineBarcodeScan': true,
          'featureFlags.reportExportPdf': true,
        },
      );

      final state = await container.read(featureFlagsControllerProvider.future);

      expect(state.onDeviceAiRuntime, isTrue);
      expect(state.aiRuntimeProvider, AiRuntimeProviderKind.aiToolkit);
      expect(state.genUiEnabled, isTrue);
      expect(state.assistantStreamMode, isFalse);
      expect(state.medicineBarcodeScan, isTrue);
      expect(state.reportExportPdf, isTrue);
    });

    test('seeds from env on first launch when no preferences stored', () async {
      EnvReader.setTestValue(EnvKey.luminousExperimentalAiRuntime, 'true');
      EnvReader.setTestValue(EnvKey.luminousAiRuntimeProvider, 'ai_toolkit');
      EnvReader.setTestValue(EnvKey.luminousEnableGenUi, 'true');

      container = buildContainer();

      final state = await container.read(featureFlagsControllerProvider.future);

      expect(state.onDeviceAiRuntime, isTrue);
      expect(state.aiRuntimeProvider, AiRuntimeProviderKind.aiToolkit);
      expect(state.genUiEnabled, isTrue);
    });

    test('falls back to default for unknown aiRuntimeProvider', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'featureFlags.aiRuntimeProvider': 'unknown_provider',
        },
      );

      final state = await container.read(featureFlagsControllerProvider.future);

      // Falls back to envConfig.provider which is 'none' in tests
      expect(state.aiRuntimeProvider, AiRuntimeProviderKind.none);
    });
  });

  group('setOnDeviceAiRuntime', () {
    test('updates state and persists the value', () async {
      container = buildContainer();

      await container.read(featureFlagsControllerProvider.future);

      await container
          .read(featureFlagsControllerProvider.notifier)
          .setOnDeviceAiRuntime(true);

      final state = container.read(featureFlagsControllerProvider);
      expect(state.value?.onDeviceAiRuntime, isTrue);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getBool('featureFlags.onDeviceAiRuntime'), isTrue);
    });
  });

  group('setAiRuntimeProvider', () {
    test('updates state and persists the value', () async {
      container = buildContainer();

      await container.read(featureFlagsControllerProvider.future);

      await container
          .read(featureFlagsControllerProvider.notifier)
          .setAiRuntimeProvider(AiRuntimeProviderKind.genUi);

      final state = container.read(featureFlagsControllerProvider);
      expect(state.value?.aiRuntimeProvider, AiRuntimeProviderKind.genUi);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('featureFlags.aiRuntimeProvider'), 'genUi');
    });
  });

  group('setGenUiEnabled', () {
    test('updates state and persists the value', () async {
      container = buildContainer();

      await container.read(featureFlagsControllerProvider.future);

      await container
          .read(featureFlagsControllerProvider.notifier)
          .setGenUiEnabled(true);

      final state = container.read(featureFlagsControllerProvider);
      expect(state.value?.genUiEnabled, isTrue);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getBool('featureFlags.genUiEnabled'), isTrue);
    });
  });

  group('setAssistantStreamMode', () {
    test('updates state and persists the value', () async {
      container = buildContainer();

      await container.read(featureFlagsControllerProvider.future);

      await container
          .read(featureFlagsControllerProvider.notifier)
          .setAssistantStreamMode(false);

      final state = container.read(featureFlagsControllerProvider);
      expect(state.value?.assistantStreamMode, isFalse);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getBool('featureFlags.assistantStreamMode'), isFalse);
    });
  });

  group('setMedicineBarcodeScan', () {
    test('updates state and persists the value', () async {
      container = buildContainer();

      await container.read(featureFlagsControllerProvider.future);

      await container
          .read(featureFlagsControllerProvider.notifier)
          .setMedicineBarcodeScan(true);

      final state = container.read(featureFlagsControllerProvider);
      expect(state.value?.medicineBarcodeScan, isTrue);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getBool('featureFlags.medicineBarcodeScan'), isTrue);
    });
  });

  group('setReportExportPdf', () {
    test('updates state and persists the value', () async {
      container = buildContainer();

      await container.read(featureFlagsControllerProvider.future);

      await container
          .read(featureFlagsControllerProvider.notifier)
          .setReportExportPdf(true);

      final state = container.read(featureFlagsControllerProvider);
      expect(state.value?.reportExportPdf, isTrue);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getBool('featureFlags.reportExportPdf'), isTrue);
    });
  });

  group('reset', () {
    test('clears all feature flag keys and restores defaults', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'featureFlags.onDeviceAiRuntime': true,
          'featureFlags.aiRuntimeProvider': 'genUi',
          'featureFlags.genUiEnabled': true,
          'featureFlags.assistantStreamMode': false,
          'featureFlags.medicineBarcodeScan': true,
          'featureFlags.reportExportPdf': true,
        },
      );

      await container.read(featureFlagsControllerProvider.future);

      await container.read(featureFlagsControllerProvider.notifier).reset();

      final state = container.read(featureFlagsControllerProvider);
      expect(state.value?.onDeviceAiRuntime, isFalse);
      expect(state.value?.aiRuntimeProvider, AiRuntimeProviderKind.none);
      expect(state.value?.genUiEnabled, isFalse);
      expect(state.value?.assistantStreamMode, isTrue);
      expect(state.value?.medicineBarcodeScan, isFalse);
      expect(state.value?.reportExportPdf, isFalse);

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.containsKey('featureFlags.onDeviceAiRuntime'),
        isFalse,
      );
      expect(
        preferences.containsKey('featureFlags.aiRuntimeProvider'),
        isFalse,
      );
      expect(preferences.containsKey('featureFlags.genUiEnabled'), isFalse);
      expect(
        preferences.containsKey('featureFlags.assistantStreamMode'),
        isFalse,
      );
      expect(
        preferences.containsKey('featureFlags.medicineBarcodeScan'),
        isFalse,
      );
      expect(preferences.containsKey('featureFlags.reportExportPdf'), isFalse);
    });
  });
}
