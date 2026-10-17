import 'dart:convert';
import 'dart:io';

import '../support.dart';

Future<void> main(List<String> args) async {
  final context = ToolContext.fromScript(Platform.script);

  try {
    final parsed = _parseNamedArgs(args);
    if (parsed.showHelp) {
      stdout.writeln(_usage);
      return;
    }

    final lucentOpenApi = resolveRequiredOpenApiFile(
      parsed.openApiPath,
      defaultLucentRoot: context.lucentRoot,
      repoRoot: context.repoRoot,
    );
    final generatedClientRoot = Directory(
      '${context.repoRoot.path}${Platform.pathSeparator}generated'
      '${Platform.pathSeparator}lucent_api',
    );

    if (!generatedClientRoot.existsSync()) {
      throw StateError(
        'Generated client directory not found: ${generatedClientRoot.path}',
      );
    }

    verifyOpenApiJson(lucentOpenApi);
    stdout.writeln('Lucent OpenAPI file resolved: ${lucentOpenApi.path}');
    stdout.writeln(
      'Generated client directory resolved: ${generatedClientRoot.path}',
    );
    _verifyGeneratedClientLayout(generatedClientRoot);
    _verifyClientMatchesSpec(lucentOpenApi, generatedClientRoot);
  } on ProcessException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(
      'OpenAPI/client verification command failed. Run `dart run scripts/contract/bootstrap.dart` after exporting Lucent OpenAPI if the generated client needs to be refreshed.',
    );
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

_ParsedArgs _parseNamedArgs(List<String> args) {
  String? openApiPath;
  var showHelp = false;

  for (var index = 0; index < args.length; index += 1) {
    final argument = args[index];
    if (argument == '--help' || argument == '-h') {
      showHelp = true;
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

  return _ParsedArgs(openApiPath: openApiPath, showHelp: showHelp);
}

void _verifyGeneratedClientLayout(Directory generatedClientRoot) {
  final requiredPaths = <String>[
    'pubspec.yaml',
    'lib/lucent_api.dart',
    'lib/src/api.dart',
    'lib/src/deserialize.dart',
  ];

  for (final relativePath in requiredPaths) {
    final file = File(
      '${generatedClientRoot.path}${Platform.pathSeparator}'
      '${relativePath.replaceAll('/', Platform.pathSeparator)}',
    );
    if (!file.existsSync()) {
      throw StateError(
        'Generated client is missing required file: ${file.path}',
      );
    }
  }

  final todayAnalysisApi = File(
    '${generatedClientRoot.path}${Platform.pathSeparator}lib'
    '${Platform.pathSeparator}src${Platform.pathSeparator}api'
    '${Platform.pathSeparator}today_analysis_api.dart',
  );
  final source = todayAnalysisApi.readAsStringSync();
  for (final methodName in const ['read', 'refreshTodayAnalysis']) {
    if (!source.contains(methodName)) {
      throw StateError(
        'Generated Today Analysis API is missing required endpoint method '
        '$methodName: ${todayAnalysisApi.path}',
      );
    }
  }
}

/// Compares the committed generated client against [openApiFile].
///
/// Regenerating the client is the only supported way to track the contract, so
/// a client that predates a Lucent export is *silently* wrong: it still
/// compiles, it simply cannot express values the backend now sends. A stale
/// client and an under-specified client both used to pass every gate, which is
/// how `MedicineDetailResponseDetailKindEnum` ended up able to represent only
/// one of the two `kind` values the contract allows. Both classes of drift are
/// reported here instead of reaching a user.
void _verifyClientMatchesSpec(File openApiFile, Directory generatedClientRoot) {
  final decoded = jsonDecode(openApiFile.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    throw StateError('Lucent OpenAPI file is not a JSON object.');
  }
  final components = decoded['components'];
  final schemas = components is Map<String, dynamic>
      ? components['schemas']
      : null;
  if (schemas is! Map<String, dynamic>) {
    throw StateError(
      'Lucent OpenAPI file is missing components.schemas, so the generated '
      'client cannot be compared against it.',
    );
  }

  final modelDirectory = Directory(
    '${generatedClientRoot.path}${Platform.pathSeparator}lib'
    '${Platform.pathSeparator}src${Platform.pathSeparator}model',
  );
  if (!modelDirectory.existsSync()) {
    throw StateError(
      'Generated client is missing its model directory: '
      '${modelDirectory.path}',
    );
  }

  // Flatten the spec the way the generator does — inline branches collapse into
  // one class named after their parent plus the property that holds them — so
  // every enum value a class must be able to deserialize is known. Comparing
  // the whole model set is not attempted here: `bootstrap.dart` generates
  // filtered slice clients and the generator invents mechanical names, so the
  // file set is not a stable 1:1 mirror. Enum coverage is the property that
  // silently breaks at runtime, so it is the property checked.
  final shapes = <_NamedShape>[];
  final visited = <String>{};
  for (final entry in schemas.entries) {
    final schema = entry.value;
    if (schema is! Map<String, dynamic>) continue;
    _walkShape(_pascal(entry.key), schema, shapes, visited);
  }
  final problems = _verifyEnumCoverage(shapes, modelDirectory);

  if (problems.isEmpty) return;
  throw StateError(
    'Generated Lucent client does not match '
    '${openApiFile.path}.\n'
    'Run `dart run scripts/contract/bootstrap.dart` to regenerate it.\n'
    '${problems.map((problem) => '  - $problem').join('\n')}',
  );
}

/// Every enum value reachable from a spec shape must be expressible by the
/// generated class that deserializes that shape.
///
/// A union's branches are walked under their parent's class name, so a value
/// that only one branch may send still has to exist on the flattened wrapper —
/// exactly the case that used to be lost.
List<String> _verifyEnumCoverage(
  List<_NamedShape> shapes,
  Directory modelDirectory,
) {
  final expected = <String, Set<String>>{};

  for (final shape in shapes) {
    final properties = shape.node['properties'];
    if (properties is! Map<String, dynamic>) continue;
    for (final entry in properties.entries) {
      final property = entry.value;
      if (property is! Map<String, dynamic>) continue;
      final values = property['enum'];
      if (values is! List) continue;
      for (final value in values) {
        if (value is! String) continue;
        expected.putIfAbsent(shape.name, () => <String>{}).add(value);
      }
    }
  }

  final problems = <String>[];
  for (final entry in expected.entries) {
    final file = File(
      '${modelDirectory.path}${Platform.pathSeparator}'
      '${_snake(entry.key)}.dart',
    );
    // Mechanical / filtered slice names do not map to a spec schema on their
    // own; only a class that exists has a contract to honour.
    if (!file.existsSync()) continue;
    final source = file.readAsStringSync();
    for (final value in entry.value.toList()..sort()) {
      if (!source.contains("r'$value'")) {
        problems.add(
          '${entry.key} cannot represent the contract value '
          "'$value' (missing from ${file.path})",
        );
      }
    }
  }
  return problems;
}

/// Collects `(generatedClass, schemaNode)` pairs, mirroring the generator's
/// flattening: a property that is an inline object or union becomes a sibling
/// class named `<Parent><Property>`, and a union's branches are merged into the
/// class they belong to rather than getting files of their own.
void _walkShape(
  String name,
  Map<String, dynamic> node,
  List<_NamedShape> out,
  Set<String> visited,
) {
  if (!visited.add('$name@${identityHashCode(node)}')) return;
  out.add(_NamedShape(name, node));

  final properties = node['properties'];
  if (properties is Map<String, dynamic>) {
    for (final entry in properties.entries) {
      final child = entry.value;
      if (child is! Map<String, dynamic>) continue;
      if (child[r'$ref'] != null) continue;
      _walkShape('$name${_pascal(entry.key)}', child, out, visited);
    }
  }

  for (final branchKey in const ['oneOf', 'anyOf', 'allOf']) {
    final branches = node[branchKey];
    if (branches is! List) continue;
    for (final branch in branches) {
      if (branch is! Map<String, dynamic>) continue;
      if (branch[r'$ref'] != null) continue;
      _walkShape(name, branch, out, visited);
    }
  }
}

String _pascal(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

/// PascalCase spec identifier -> snake_case generated file stem, matching the
/// dart-dio naming convention (`MedicineDetailResponse` ->
/// `medicine_detail_response`).
String _snake(String value) {
  final buffer = StringBuffer();
  for (var index = 0; index < value.length; index += 1) {
    final character = value[index];
    if (_isUpper(character) && index > 0) {
      final previous = value[index - 1];
      final next = index + 1 < value.length ? value[index + 1] : '';
      if (_isLower(previous) || (_isUpper(previous) && _isLower(next))) {
        buffer.write('_');
      }
    }
    buffer.write(character.toLowerCase());
  }
  return buffer.toString();
}

bool _isUpper(String character) =>
    character.toUpperCase() == character &&
    character.toLowerCase() != character;

bool _isLower(String character) =>
    character.toLowerCase() == character &&
    character.toUpperCase() != character;

class _NamedShape {
  const _NamedShape(this.name, this.node);

  final String name;
  final Map<String, dynamic> node;
}

class _ParsedArgs {
  const _ParsedArgs({required this.openApiPath, required this.showHelp});

  final String? openApiPath;
  final bool showHelp;
}

const _usage = '''
Usage: dart run scripts/contract/verify_openapi.dart [options]

Options:
  --openapi <path>   Verify against an explicit Lucent OpenAPI file path.
  --help             Show this help text.
''';
