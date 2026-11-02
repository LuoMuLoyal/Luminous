// 循环依赖本地检查（arch_guard）——不接 pre-push / daily / CI，只在本地手动跑：
//
//   dart run scripts/arch/guard.dart
//
// 权威分层是 tool/luminous_lints --clean-layers（R1–R9）；arch_guard 只补它
// 没覆盖的那一类问题：循环依赖。配置见 arch_guard.yaml，冻结清单见
// arch_guard_baseline.json。
import 'dart:io';

import 'package:arch_guard/arch_guard.dart';

/// 只拦新增循环依赖，不拦层违规 / 禁用包导入。
///
/// 理由：arch_guard 的 layers 是 luminous_lints 的粗粒度镜像，仍有约 190 条
/// 层违规属于白名单接缝（core→app seam、生成 l10n、跨 feature providers
/// 接缝），把它们设为阻断会让每次改动都因行号漂移"变新"、沦为刷 baseline；
/// 层违规由 `luminous_lints --clean-layers` 负责。循环依赖是 arch_guard 独有、
/// luminous_lints 完全没覆盖的一类问题，存量已冻结在 baseline 里。
void main(List<String> args) async {
  final root = _resolveRepoRoot();
  final analysis = await ArchAnalysis.run(
    projectPath: root.path,
    useBaseline: true,
  );

  if (analysis.scan.files.isEmpty) {
    // 扫描到 0 个文件时"通过"是假绿：路径解析或 --scan-dir 出错都会这样。
    stderr.writeln('arch_guard: scanned no files under ${root.path}/lib.');
    exit(2);
  }

  final configProblems = [
    ...analysis.config.warnings,
    ...analysis.warnings,
    if (analysis.coverage.unassignedFiles.isNotEmpty)
      '${analysis.coverage.unassignedFiles.length} file(s) belong to no layer: '
          '${analysis.coverage.unassignedFiles.take(5).join(', ')}'
          '${analysis.coverage.unassignedFiles.length > 5 ? ', ...' : ''}',
  ];
  final coverageProblems = analysis.coverage.unassignedFiles.isNotEmpty;

  final newCycles = analysis.newCycles;
  final knownCycles = analysis.cycles.length - newCycles.length;

  stdout.writeln(
    'arch_guard: ${analysis.scan.files.length} file(s), '
    '${analysis.scan.edges.length} edge(s).',
  );
  stdout.writeln(
    '  cycle groups: ${analysis.cycles.length} '
    '(known $knownCycles, new ${newCycles.length})',
  );
  stdout.writeln(
    '  layer violations (tracked, not gating): '
    '${analysis.layerViolations.length}',
  );
  stdout.writeln(
    '  forbidden package imports (tracked, not gating): '
    '${analysis.packageViolations.length}',
  );

  for (final problem in configProblems) {
    stderr.writeln('arch_guard config warning: $problem');
  }

  if (newCycles.isNotEmpty) {
    stderr.writeln('');
    stderr.writeln('New circular dependency group(s):');
    for (final cycle in newCycles) {
      final files = cycle.files;
      final preview = cycle.exampleChain.join(' -> ');
      final more = files.length > cycle.exampleChain.length
          ? ' (+${files.length - cycle.exampleChain.length} more)'
          : '';
      stderr.writeln('  - ${files.length} file(s): $preview$more');
    }
    stderr.writeln('');
    stderr.writeln(
      'Break the cycle (invert the dependency or move the code). If the '
      'cycle is intentional and permanent, run '
      '`dart run arch_guard --update-baseline` and review the baseline diff.',
    );
  }

  final failed = newCycles.isNotEmpty || coverageProblems;
  stdout.writeln(failed ? 'arch_guard: FAILED.' : 'arch_guard: clean.');
  exit(failed ? 1 : 0);
}

/// 从脚本位置向上找 pubspec.yaml：兼容 `dart run scripts/arch/guard.dart`
/// 以及 build_runner 包装后的临时脚本路径。
Directory _resolveRepoRoot() {
  var dir = File.fromUri(Platform.script).parent.absolute;
  while (true) {
    if (File('${dir.path}${Platform.pathSeparator}pubspec.yaml').existsSync()) {
      return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      return File.fromUri(Platform.script).parent.parent.absolute;
    }
    dir = parent;
  }
}
