import 'dart:io';

import '../support.dart';

Future<void> main(List<String> args) async {
  final context = ToolContext.fromScript(Platform.script);

  try {
    final parsed = _parseArgs(args);
    if (parsed.showHelp) {
      stdout.writeln(_usage);
      return;
    }

    await bootstrapGeneratedSources(
      context,
      openApiPath: parsed.openApiPath,
      skipClient: parsed.skipClient,
      skipPubGet: parsed.skipPubGet,
      skipAppCodegen: parsed.skipAppCodegen,
    );
  } on ProcessException catch (error) {
    stderr.writeln(error.message);
    exitCode = error.errorCode;
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln('');
    stderr.writeln(_usage);
    exitCode = 64;
  } on StateError catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}

Future<void> bootstrapGeneratedSources(
  ToolContext context, {
  String? openApiPath,
  bool skipClient = false,
  bool skipPubGet = false,
  bool skipAppCodegen = false,
}) async {
  if (!skipPubGet) {
    await runLoggedCommand(
      'flutter',
      ['pub', 'get'],
      workingDirectory: context.repoRoot,
      stepName: 'flutter pub get',
    );
    stdout.writeln('');
  }

  // Build the client branch and app codegen branch in parallel — they
  // have no dependency on each other after root pub get completes.
  final futures = <Future<void>>[];

  if (!skipClient) {
    futures.add(_buildClient(context, openApiPath: openApiPath));
  }

  if (!skipAppCodegen) {
    futures.add(_buildAppCodegen(context));
  }

  if (futures.isNotEmpty) {
    await Future.wait(futures);
  }
}

Future<void> _buildClient(ToolContext context, {String? openApiPath}) async {
  final openApiFile = resolveRequiredOpenApiFile(
    openApiPath,
    defaultLucentRoot: context.lucentRoot,
    repoRoot: context.repoRoot,
  );
  verifyOpenApiJson(openApiFile);

  final generatedClientRoot = Directory(
    '${context.repoRoot.path}${Platform.pathSeparator}generated'
    '${Platform.pathSeparator}lucent_api',
  );
  if (!generatedClientRoot.existsSync()) {
    throw StateError(
      'Generated client directory not found: ${generatedClientRoot.path}',
    );
  }

  final generatorConfig = File(
    '${context.repoRoot.path}${Platform.pathSeparator}openapi_gen_config.json',
  );
  if (!generatorConfig.existsSync()) {
    throw StateError(
      'OpenAPI generator config not found: ${generatorConfig.path}',
    );
  }

  // 生成前清空 tracked client 的 lib 旧产物:openapi 再生成只做合并拷贝,若合同
  // 侧删除/重命名了 schema 或 endpoint,旧版生成的 api/model/supporting 文件会
  // 残留(如按参数/属性命名的空 model),随后 build_runner 在畸形文件上解析失败。
  // lib 下全部是生成物(lucent_api.dart、src/api、src/model、src/auth 及由
  // build_runner 落盘的 *.g.dart),整树删除后由下面的拷贝步骤重建精确镜像。
  final generatedLib = Directory(
    '${generatedClientRoot.path}${Platform.pathSeparator}lib',
  );
  if (generatedLib.existsSync()) {
    await generatedLib.delete(recursive: true);
  }

  final filteredOutputs = <Directory>[];
  final supportingOutput = await Directory.systemTemp.createTemp(
    'luminous-openapi-supporting-',
  );
  final fullOutput = await Directory.systemTemp.createTemp(
    'luminous-openapi-full-',
  );

  try {
    // 阶段 1（全量）:一次生成全部 apis/models/supporting 到临时目录，把
    // 完整 lib 树（含 _filteredClients 未覆盖的客户端，如
    // MedicineRemindersApi）归一化拷贝进 generated/lucent_api。
    // 与过滤再生相同：关闭 docs/tests 生成（模型测试模板使用 null-aware
    // 元素语法，会重写跟踪中的既有测试并破坏构建），且 pubspec.yaml 等
    // 模板文件不拷贝（保留仓库跟踪的 SDK 约束）。
    await _generateFullApiClient(
      context,
      openApiFile: openApiFile,
      generatorConfig: generatorConfig,
      outputDirectory: fullOutput,
    );
    _copyGeneratedLibTree(fullOutput, generatedClientRoot);

    // 阶段 2（过滤）:openapi-generator-cli 7.x 的 --global-property 只接受
    // 单值 apis，因此每个过滤客户端（TodayAnalysis、Reports 等）各跑一次
    // 生成再合并拷贝，覆盖阶段 1 的对应文件（api 文件 + models 清单列出的
    // 模型；请求体/内联响应模型同样按清单产出）。清单命名必须是生成器解析
    // 出的原始 schema 名（components.schemas 键，或 InlineModelResolver 对
    // 内联 schema 起的 <parent>_<property> 名）；openapi-generator 对清单里
    // 不存在的名字是静默忽略，因此每次过滤生成后由
    // _verifyFilteredModelsProduced 断言每个清单名都产出了对应模型文件——
    // 合同漂移（改名/删 schema）会在此 fail-fast，而不是静默埋雷。新增 API
    // 面只需在 _filteredClients 里加一条配置（并把该客户端用到的模型补进
    // 对应清单）。
    for (final client in _filteredClients) {
      final output = await Directory.systemTemp.createTemp(
        'luminous-openapi-${client.apis.toLowerCase()}-',
      );
      filteredOutputs.add(output);
      await _generateFilteredApiClient(
        context,
        openApiFile: openApiFile,
        generatorConfig: generatorConfig,
        outputDirectory: output,
        apis: client.apis,
        models: client.models,
      );
      _verifyFilteredModelsProduced(
        sliceName: client.apis,
        models: client.models,
        outputDirectory: output,
      );
      _copyGeneratedFile(
        output,
        generatedClientRoot,
        'lib/src/api/${client.apiFile}',
      );
      _copyGeneratedModels(output, generatedClientRoot);
    }
    await _generateSupportingFiles(
      context,
      openApiFile: openApiFile,
      generatorConfig: generatorConfig,
      outputDirectory: supportingOutput,
    );

    _copyGeneratedFile(
      supportingOutput,
      generatedClientRoot,
      'lib/lucent_api.dart',
    );
    _copyGeneratedFile(
      supportingOutput,
      generatedClientRoot,
      'lib/src/deserialize.dart',
    );
  } finally {
    for (final output in filteredOutputs) {
      await output.delete(recursive: true);
    }
    await supportingOutput.delete(recursive: true);
    await fullOutput.delete(recursive: true);
  }

  await runLoggedCommand(
    'dart',
    ['pub', 'get'],
    workingDirectory: generatedClientRoot,
    stepName: 'dart pub get (generated/lucent_api)',
  );
  stdout.writeln('');

  await runLoggedCommand(
    'dart',
    ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    workingDirectory: generatedClientRoot,
    stepName:
        'dart run build_runner build --delete-conflicting-outputs '
        '(generated/lucent_api)',
    maxRetries: 1,
  );
  stdout.writeln('');

  // Format generated code so that diffs only show semantic changes,
  // not formatting drift from the generator.
  await runLoggedCommand(
    'dart',
    ['format', generatedClientRoot.path],
    workingDirectory: context.repoRoot,
    stepName: 'dart format generated/lucent_api',
  );
  stdout.writeln('');
}

Future<void> _generateFilteredApiClient(
  ToolContext context, {
  required File openApiFile,
  required File generatorConfig,
  required Directory outputDirectory,
  required String apis,
  required List<String> models,
}) async {
  final modelList = models.join(':');
  await runLoggedCommand(
    'openapi-generator-cli',
    [
      'generate',
      '-i',
      openApiFile.path,
      '-g',
      'dart-dio',
      '-o',
      outputDirectory.path,
      '-c',
      generatorConfig.path,
      '--global-property=apis=$apis,models=$modelList',
      '--global-property=modelDocs=false,apiDocs=false,modelTests=false,apiTests=false',
    ],
    workingDirectory: context.repoRoot,
    stepName: 'openapi-generator (filtered $apis client)',
  );
  stdout.writeln('');
}

/// Fail-fast guard for one filtered generation: openapi-generator 7.x
/// *silently ignores* model names in `models=` that do not resolve against the
/// current spec, so a stale/renamed entry would otherwise pass with exit 0 and
/// leave the tracked client silently depending on the stage-1 (full) copy.
/// After [Directory] [outputDirectory] was produced by
/// [_generateFilteredApiClient], assert that every listed raw schema name
/// actually emitted its model file under `lib/src/model/`.
void _verifyFilteredModelsProduced({
  required String sliceName,
  required List<String> models,
  required Directory outputDirectory,
}) {
  final missing = <String>[];
  for (final rawName in models) {
    final expectedFile = '${_generatedModelFileName(rawName)}.dart';
    final file = File(
      '${outputDirectory.path}${Platform.pathSeparator}lib'
      '${Platform.pathSeparator}src${Platform.pathSeparator}model'
      '${Platform.pathSeparator}$expectedFile',
    );
    if (!file.existsSync()) {
      missing.add('$rawName → $expectedFile');
    }
  }
  if (missing.isNotEmpty) {
    throw StateError(
      'Filtered client "$sliceName": openapi-generator did not produce model '
      'files for ${missing.length} of ${models.length} listed schema(s). '
      'These names are stale or drifted from the OpenAPI contract and were '
      'silently ignored by the generator:\n'
      '  ${missing.join('\n  ')}\n'
      'Update the corresponding model list in scripts/contract/bootstrap.dart '
      'to the current raw schema names (components.schemas keys or '
      'InlineModelResolver names such as <Controller>_<action>_v1_request).',
    );
  }
}

/// Expected basename of the model file the dart-dio generator writes for the
/// raw schema name [rawName] (a components.schemas key, or the name the
/// InlineModelResolver assigned to an inline schema). Mirrors the generator's
/// naming pipeline: segment-capitalize to the Dart class name, then split
/// camel boundaries into snake_case. Validated 1:1 against the generated
/// model corpus (components + inline names ↔ 243 model files).
String _generatedModelFileName(String rawName) {
  final className = rawName
      .split('_')
      .map(
        (segment) => segment.isEmpty
            ? segment
            : segment[0].toUpperCase() + segment.substring(1),
      )
      .join();
  var underscored = className.replaceAllMapped(
    RegExp(r'([a-z0-9])([A-Z])'),
    (match) => '${match[1]}_${match[2]}',
  );
  underscored = underscored.replaceAllMapped(
    RegExp(r'([A-Z]+)([A-Z][a-z])'),
    (match) => '${match[1]}_${match[2]}',
  );
  return underscored.toLowerCase();
}

/// Runs one full dart-dio generation (all apis + models + supporting files)
/// with docs/tests disabled. The raw output is copied into the tracked client
/// by [_copyGeneratedLibTree], which applies the same normalization as the
/// filtered copies. Model tests stay disabled: the current generator's test
/// templates use null-aware element syntax that would rewrite the tracked
/// test snapshot and break parsing under the repo's pinned SDK.
Future<void> _generateFullApiClient(
  ToolContext context, {
  required File openApiFile,
  required File generatorConfig,
  required Directory outputDirectory,
}) async {
  await runLoggedCommand(
    'openapi-generator-cli',
    [
      'generate',
      '-i',
      openApiFile.path,
      '-g',
      'dart-dio',
      '-o',
      outputDirectory.path,
      '-c',
      generatorConfig.path,
      '--global-property=modelDocs=false,apiDocs=false,modelTests=false,apiTests=false',
    ],
    workingDirectory: context.repoRoot,
    stepName: 'openapi-generator (full client)',
  );
  stdout.writeln('');
}

/// Copies every non-generated Dart file under the full regen output's `lib/`
/// into the tracked client, applying [_normalizeGeneratedDart]. Generator
/// template files outside `lib/` (pubspec.yaml, .gitignore, README, ...) are
/// deliberately not copied so the tracked SDK constraint and ignore rules are
/// preserved.
void _copyGeneratedLibTree(Directory sourceRoot, Directory targetRoot) {
  final sourceLib = Directory('${sourceRoot.path}${Platform.pathSeparator}lib');
  if (!sourceLib.existsSync()) {
    throw StateError('OpenAPI generator did not produce lib sources.');
  }

  for (final entity in sourceLib.listSync(recursive: true)) {
    if (entity is! File ||
        !entity.path.endsWith('.dart') ||
        entity.path.endsWith('.g.dart')) {
      continue;
    }
    final relative = entity.path
        .substring(sourceLib.path.length + 1)
        .replaceAll(Platform.pathSeparator, '/');
    _copyGeneratedFile(sourceRoot, targetRoot, 'lib/$relative');
  }
}

Future<void> _generateSupportingFiles(
  ToolContext context, {
  required File openApiFile,
  required File generatorConfig,
  required Directory outputDirectory,
}) async {
  for (final supportingFile in const ['lucent_api.dart', 'deserialize.dart']) {
    await runLoggedCommand(
      'openapi-generator-cli',
      [
        'generate',
        '-i',
        openApiFile.path,
        '-g',
        'dart-dio',
        '-o',
        outputDirectory.path,
        '-c',
        generatorConfig.path,
        '--global-property=models,apis,supportingFiles=$supportingFile',
        '--global-property=modelDocs=false,apiDocs=false,modelTests=false,apiTests=false',
      ],
      workingDirectory: context.repoRoot,
      stepName: 'openapi-generator (supporting $supportingFile)',
    );
  }
  stdout.writeln('');
}

void _copyGeneratedFile(
  Directory sourceRoot,
  Directory targetRoot,
  String relativePath,
) {
  final normalizedPath = relativePath.replaceAll('/', Platform.pathSeparator);
  final source = File(
    '${sourceRoot.path}${Platform.pathSeparator}$normalizedPath',
  );
  if (!source.existsSync()) {
    throw StateError('OpenAPI generator did not produce ${source.path}');
  }

  final target = File(
    '${targetRoot.path}${Platform.pathSeparator}$normalizedPath',
  );
  target.parent.createSync(recursive: true);
  target.writeAsStringSync(_normalizeGeneratedDart(source.readAsStringSync()));
}

void _copyGeneratedModels(Directory sourceRoot, Directory targetRoot) {
  final sourceDirectory = Directory(
    '${sourceRoot.path}${Platform.pathSeparator}lib'
    '${Platform.pathSeparator}src${Platform.pathSeparator}model',
  );
  if (!sourceDirectory.existsSync()) {
    throw StateError('OpenAPI generator did not produce model sources.');
  }

  for (final entity in sourceDirectory.listSync()) {
    if (entity is! File ||
        !entity.path.endsWith('.dart') ||
        entity.path.endsWith('.g.dart')) {
      continue;
    }
    final target = File(
      '${targetRoot.path}${Platform.pathSeparator}lib'
      '${Platform.pathSeparator}src${Platform.pathSeparator}model'
      '${Platform.pathSeparator}${entity.uri.pathSegments.last}',
    );
    target.parent.createSync(recursive: true);
    target.writeAsStringSync(
      _normalizeGeneratedDart(entity.readAsStringSync()),
    );
  }
}

String _normalizeGeneratedDart(String source) {
  final lines = source.split('\n');
  lines.removeWhere(
    (line) => line.trimLeft().startsWith('unknownEnumValue: List<'),
  );
  return lines.join('\n');
}

Future<void> _buildAppCodegen(ToolContext context) async {
  await runLoggedCommand(
    'flutter',
    ['gen-l10n'],
    workingDirectory: context.repoRoot,
    stepName: 'flutter gen-l10n',
  );
  stdout.writeln('');

  await runLoggedCommand(
    'dart',
    ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    workingDirectory: context.repoRoot,
    stepName: 'dart run build_runner build --delete-conflicting-outputs',
    maxRetries: 1,
  );
}

_ParsedArgs _parseArgs(List<String> args) {
  String? openApiPath;
  var showHelp = false;
  var skipClient = false;
  var skipPubGet = false;
  var skipAppCodegen = false;

  for (var index = 0; index < args.length; index += 1) {
    final argument = args[index];
    if (argument == '--help' || argument == '-h') {
      showHelp = true;
      continue;
    }
    if (argument == '--skip-client') {
      skipClient = true;
      continue;
    }
    if (argument == '--skip-pub-get') {
      skipPubGet = true;
      continue;
    }
    if (argument == '--skip-app-codegen') {
      skipAppCodegen = true;
      continue;
    }
    if (argument == '--openapi') {
      if (index + 1 >= args.length) {
        throw const FormatException('Missing value for argument: --openapi');
      }
      openApiPath = args[index + 1];
      index += 1;
      continue;
    }
    if (argument.startsWith('--openapi=')) {
      final value = argument.substring('--openapi='.length);
      if (value.isEmpty) {
        throw const FormatException('Missing value for argument: --openapi');
      }
      openApiPath = value;
      continue;
    }
    throw FormatException('Unexpected argument: $argument');
  }

  return _ParsedArgs(
    openApiPath: openApiPath,
    showHelp: showHelp,
    skipClient: skipClient,
    skipPubGet: skipPubGet,
    skipAppCodegen: skipAppCodegen,
  );
}

class _ParsedArgs {
  const _ParsedArgs({
    required this.openApiPath,
    required this.showHelp,
    required this.skipClient,
    required this.skipPubGet,
    required this.skipAppCodegen,
  });

  final String? openApiPath;
  final bool showHelp;
  final bool skipClient;
  final bool skipPubGet;
  final bool skipAppCodegen;
}

const _usage = '''
Usage: dart run scripts/contract/bootstrap.dart [options]

Options:
  --openapi <path>        Use an explicit Lucent OpenAPI file path.
  --skip-client           Skip generated/lucent_api pub get + build_runner.
  --skip-pub-get          Skip root flutter pub get.
  --skip-app-codegen      Skip flutter gen-l10n and root build_runner.
  --help                  Show this help text.
''';

// 过滤清单命名口径：openapi-generator 7.x 的 --global-property=models= 只接受
// 生成器解析出的「原始 schema 名」——components.schemas 键（PascalCase，如
// TodayAnalysisReadResponseDto），以及 InlineModelResolver 给内联 schema 起的
// 名（下划线小驼峰，如 TodayAnalysisController_refresh_v1_request、
// TodayAnalysisReadResponseDto_analysis_bullets_inner）。类名 / 文件名都不是
// 可接受的等价写法（写错即被静默忽略）。清单内容 = 该切片 API 的 model import
// 闭包（见 _filteredClients 下的机制注释），逐名校验交给生成后的
// _verifyFilteredModelsProduced。
const _todayAnalysisModels = [
  'EnqueueAnalysisGenerationRequest',
  'GenerateRequest',
  'GenerateStreamRequest',
  'RefreshTodayAnalysisRequest',
  'TodayAnalysisAsyncStatusData',
  'TodayAnalysisData',
  'TodayAnalysisDataBullets',
  'TodayAnalysisDataMetrics',
  'TodayAnalysisDataMetricsObservedMetric',
  'TodayAnalysisReadData',
  'TodayAnalysisReadDataAnalysis',
  'TodayAnalysisReadDataAnalysisBullets',
  'TodayAnalysisReadDataAnalysisMetrics',
  'TodayAnalysisReadDataAnalysisMetricsObservedMetric',
  'TodayAnalysisReadResponse',
  'TodayAnalysisReadResponseAnalysis',
  'TodayAnalysisReadResponseAnalysisBullets',
  'TodayAnalysisReadResponseAnalysisMetrics',
  'TodayAnalysisReadResponseAnalysisMetricsObservedMetric',
  'TodayAnalysisRefreshReadyData',
  'TodayAnalysisRefreshReadyDataAnalysis',
  'TodayAnalysisRefreshReadyDataAnalysisBullets',
  'TodayAnalysisRefreshReadyDataAnalysisMetrics',
  'TodayAnalysisRefreshReadyDataAnalysisMetricsObservedMetric',
  'TodayRecommendationItem',
];

const _reviewModels = [
  'ClinicSummaryExportJobResponse',
  'ClinicSummaryResponse',
  'ClinicSummaryResponseAllergies',
  'ClinicSummaryResponseConditions',
  'ClinicSummaryResponseCoverage',
  'ClinicSummaryResponseCoverageCheckIns',
  'ClinicSummaryResponseCoverageDose',
  'ClinicSummaryResponseCoverageSleep',
  'ClinicSummaryResponseCoverageWater',
  'ClinicSummaryResponseCurrentMedicines',
  'ClinicSummaryResponseNoteEntries',
  'ClinicSummaryResponseProfile',
  'ClinicSummaryResponseSleepEntries',
  'ClinicSummaryResponseWaterEntries',
  'ClinicSummaryShareListResponse',
  'ClinicSummaryShareListResponseItems',
  'ClinicSummaryShareListResponseItemsScope',
  'ClinicSummaryShareResponse',
  'ClinicSummaryShareResponseScope',
  'DownloadClinicSummaryPdfRequest',
  'EnqueueClinicSummaryPdfExportRequest',
  'EnqueueSummaryGenerationRequest',
  'EventReviewData',
  'EventReviewDataCoverage',
  'EventReviewDataCoverageCheckIns',
  'EventReviewDataCoverageCheckInsTodayCheckIn',
  'EventReviewDataCoverageDailyRecords',
  'EventReviewDataCoverageDoseLogs',
  'EventReviewDataEvent',
  'EventReviewDataSections',
  'EventReviewDataSectionsCompletedActions',
  'EventReviewDataSectionsCompletedActionsFacts',
  'EventReviewDataSectionsKeyChanges',
  'EventReviewDataSectionsKeyChangesFacts',
  'EventReviewDataSectionsNextStep',
  'EventReviewDataSectionsNextStepFacts',
  'EventReviewDataSectionsWhatHappened',
  'EventReviewDataSectionsWhatHappenedFacts',
  'EventReviewDataSourceTimestamps',
  'EventReviewListResponse',
  'EventReviewListResponseItems',
  'EventReviewResponse',
  'EventReviewResponseCoverage',
  'EventReviewResponseCoverageCheckIns',
  'EventReviewResponseCoverageCheckInsTodayCheckIn',
  'EventReviewResponseCoverageDailyRecords',
  'EventReviewResponseCoverageDoseLogs',
  'EventReviewResponseEvent',
  'EventReviewResponseSections',
  'EventReviewResponseSectionsCompletedActions',
  'EventReviewResponseSectionsCompletedActionsFacts',
  'EventReviewResponseSectionsKeyChanges',
  'EventReviewResponseSectionsKeyChangesFacts',
  'EventReviewResponseSectionsNextStep',
  'EventReviewResponseSectionsNextStepFacts',
  'EventReviewResponseSectionsWhatHappened',
  'EventReviewResponseSectionsWhatHappenedFacts',
  'EventReviewResponseSourceTimestamps',
  'GenerateSummaryRequest',
  'GenerateSummaryStreamRequest',
  'PreviewClinicSummaryRequest',
  'ReportDashboardResponse',
  'ReportDashboardResponseFindings',
  'ReportDashboardResponseMetrics',
  'ReportDashboardResponseMetricsObservedMetric',
  'ReportDashboardResponsePatterns',
  'ReportDashboardResponseTrends',
  'ReportDashboardResponseTrendsObservedMetric',
  'ReportSummaryJobResponse',
  'ReportSummaryJobResponseResult',
  'ReportSummaryJobResponseResultCoverage',
  'ReportSummaryJobResponseResultCoverageMedication',
  'ReportSummaryJobResponseResultCoverageSleep',
  'ReportSummaryJobResponseResultCoverageWater',
  'ReportSummaryJobResponseResultLowRiskAction',
  'ReportSummaryJobResponseResultObservedPattern',
  'ReportSummaryResponse',
  'ReportSummaryResponseCoverage',
  'ReportSummaryResponseCoverageMedication',
  'ReportSummaryResponseCoverageSleep',
  'ReportSummaryResponseCoverageWater',
  'ReportSummaryResponseLowRiskAction',
  'ReportSummaryResponseObservedPattern',
  'ShareClinicSummaryRequest',
];

const _productEventsModels = [
  'FunnelResponse',
  'FunnelResponseDaily',
  'FunnelResponseOptional',
  'FunnelResponseTotals',
  'FunnelResponseWindow',
  'ProblemDetailsDto',
  'RecordBatchRequest',
  'RecordBatchRequestEvents',
];

const _notificationsModels = [
  'CreateNotificationRequest',
  'NotificationDetailResponse',
  'NotificationListResponse',
  'NotificationListResponseItems',
  'ProblemDetailsDto',
  'UnreadCountResponse',
];

const _userSettingsModels = [
  'ProblemDetailsDto',
  'UpdateSettingsRequest',
  'UpdateSettingsRequestAssistantContext',
  'UserSettingsResponse',
  'UserSettingsResponseAssistantContext',
];

const _reminderDeliveriesModels = [
  'LocalCapabilityResponse',
  'ProblemDetailsDto',
  'RecordReceiptRequest',
  'ReminderDeliveryListResponse',
  'ReminderDeliveryListResponseItems',
  'ReminderDeliveryReceiptResponse',
  'ReminderDeliveryReceiptResponseItem',
  'ReportLocalCapabilityRequest',
];

/// 过滤客户端的数据驱动配置：每一条对应一次 openapi-generator 过滤生成
/// 及一个 API 文件 + 一组模型的拷贝。新增合同面只需在此追加一条。
///
/// 每个 [models] 清单 = 该切片 API 的 model import 闭包（api 文件直接引用 +
/// 模型文件间传递引用），且必须使用生成器解析出的原始 schema 名（见各常量
/// 顶部注释）。清单与当前合同不同步（旧 *Dto 名、漏加新请求模型）时，
/// _verifyFilteredModelsProduced 会在该切片过滤生成后 fail-fast。
const _filteredClients = <({String apis, String apiFile, List<String> models})>[
  (
    apis: 'TodayAnalysis',
    apiFile: 'today_analysis_api.dart',
    models: _todayAnalysisModels,
  ),
  (apis: 'Reports', apiFile: 'reports_api.dart', models: _reviewModels),
  (
    apis: 'ProductEvents',
    apiFile: 'product_events_api.dart',
    models: _productEventsModels,
  ),
  (
    apis: 'Notifications',
    apiFile: 'notifications_api.dart',
    models: _notificationsModels,
  ),
  (
    apis: 'UserSettings',
    apiFile: 'user_settings_api.dart',
    models: _userSettingsModels,
  ),
  (
    apis: 'ReminderDeliveries',
    apiFile: 'reminder_deliveries_api.dart',
    models: _reminderDeliveriesModels,
  ),
];
