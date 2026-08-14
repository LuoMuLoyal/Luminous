import 'dart:io';

import 'tooling_support.dart';

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

  final filteredOutputs = <Directory>[];
  final supportingOutput = await Directory.systemTemp.createTemp(
    'luminous-openapi-supporting-',
  );

  try {
    // openapi-generator-cli 7.x 的 --global-property 只接受单值 apis，
    // 因此每个过滤客户端（TodayAnalysis、Reports 等）各跑一次生成再合并
    // 拷贝。新增 API 面只需在 _filteredClients 里加一条配置。
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
    // 过滤生成（apis=X,models=Y）只产出命名 schema 模型，不会生成内联响应
    // 模型；而 deserialize.dart 由全量 supporting 生成并引用它们。从全量
    // 输出补齐过滤客户端实际引用的内联响应模型（与既有
    // today_suggestion_controller_..._v1202_response 的遗留处理一致）。
    for (final model in _inlineResponseModels) {
      final relative = 'lib/src/model/$model';
      final source = File(
        '${supportingOutput.path}${Platform.pathSeparator}'
        '${relative.replaceAll('/', Platform.pathSeparator)}',
      );
      if (source.existsSync()) {
        _copyGeneratedFile(supportingOutput, generatedClientRoot, relative);
      }
    }
  } finally {
    for (final output in filteredOutputs) {
      await output.delete(recursive: true);
    }
    await supportingOutput.delete(recursive: true);
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
Usage: dart run scripts/bootstrap_generated_sources.dart [options]

Options:
  --openapi <path>        Use an explicit Lucent OpenAPI file path.
  --skip-client           Skip generated/lucent_api pub get + build_runner.
  --skip-pub-get          Skip root flutter pub get.
  --skip-app-codegen      Skip flutter gen-l10n and root build_runner.
  --help                  Show this help text.
''';

const _todayAnalysisModels = [
  'GenerateTodayAnalysisDto',
  'TodayAnalysisAsyncJobDataDto',
  'TodayAnalysisAsyncResponseDto',
  'TodayAnalysisAsyncResponseDto_data',
  'TodayAnalysisAsyncResultDataDto',
  'TodayAnalysisAsyncStatusDataDto',
  'TodayAnalysisBulletDto',
  'TodayAnalysisDataDto',
  'TodayAnalysisGenerateResponseDto',
  'TodayAnalysisGenerateResponseDto_data',
  'TodayAnalysisReadDataDto',
  'TodayAnalysisReadResponseDto',
  'TodayAnalysisRefreshPendingDataDto',
  'TodayAnalysisRefreshReadyDataDto',
  'TodayAnalysisRefreshResponseDto',
  'TodayAnalysisRefreshResponseDto_data',
  'TodayAnalysisStreamErrorDto',
  'TodayAnalysisStreamResultDto',
  'TodayAnalysisStreamResultDto_data',
  'TodayAnalysisStreamSummaryDto',
  'ReportMetricDto',
  'ReportObservedMetricDto',
  'SuggestionItemDto',
  'SuggestionObservedMetricDto',
];

const _reviewModels = [
  'EventReviewCheckInCoverageDto',
  'EventReviewCoverageSummaryDto',
  'EventReviewDataDto',
  'EventReviewEventDto',
  'EventReviewListDataDto',
  'EventReviewListResponseDto',
  'EventReviewNullableResponseDto',
  'EventReviewObservedSourceDto',
  'EventReviewResponseDto',
  'EventReviewSectionDto',
  'EventReviewSectionFactsDto',
  'EventReviewSectionsDto',
  'EventReviewSourceTimestampsDto',
  'EventReviewTodayCheckInDto',
  'ClinicSummaryCoverageEntryDto',
  'ClinicSummaryCoverageDto',
  'ClinicSummaryProfileDto',
  'ClinicSummaryDto',
  'ClinicSummaryRequestDto',
  'ClinicSummaryShareScopeDto',
  'ClinicSummaryShareResponseDto',
  'ClinicSummaryShareListItemDto',
  'ClinicSummaryShareListDataDto',
  'ClinicSummaryShareListResponseDto',
];

const _productEventsModels = [
  'ProductEventName',
  'ProductEventSurface',
  'ProductEventResult',
  'UserDevicePlatform',
  'CreateProductEventDto',
  'CreateProductEventBatchDto',
];

/// 过滤生成无法产出的内联响应模型（openapi-generator 7.x 的 `models=` 只接受
/// 命名 schema，内联 schema 由生成器自动命名并输出 snake_case 文件名）。
/// 从 supporting 全量输出复制。
const _inlineResponseModels = <String>[
  'reports_controller_export_clinic_summary_pdf_async_v1201_response.dart',
  'reports_controller_export_clinic_summary_pdf_async_v1201_response_data.dart',
];

/// 过滤客户端的数据驱动配置：每一条对应一次 openapi-generator 过滤生成
/// 及一个 API 文件 + 一组模型的拷贝。新增合同面只需在此追加一条。
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
];
