// Plugin entrypoint. The analysis server generates bootstrap code that
// imports this file and references the top-level `plugin` variable, so the
// file name and the variable name are both load-bearing.
import 'dart:async';

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'package:luminous_lints/luminous_lints.dart';

final LuminousLintsPlugin plugin = LuminousLintsPlugin();

final class LuminousLintsPlugin extends Plugin {
  @override
  String get name => 'luminous_lints';

  @override
  FutureOr<void> register(PluginRegistry registry) {
    // All rules are warnings (enabled by default) for the observation period;
    // promote to errors after the backlog is cleared.
    for (final rule in luminousLintsRules) {
      registry.registerWarningRule(rule);
    }
  }
}
