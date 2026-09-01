/// In-house analyzer plugin for the Luminous app.
///
/// Encodes the recurring code issues found in historical review reports as
/// seven analysis rules. All rules are registered as warning rules (enabled
/// by default); they are intended to be promoted to errors once existing
/// findings are cleaned up.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';

import 'src/empty_catch_requires_comment.dart';
import 'src/enum_parse_unknown_branch.dart';
import 'src/first_where_requires_or_else.dart';
import 'src/layered_import.dart';
import 'src/no_bang_on_response_data.dart';
import 'src/no_direct_navigator.dart';
import 'src/no_raw_datetime_parse.dart';

export 'src/empty_catch_requires_comment.dart';
export 'src/enum_parse_unknown_branch.dart';
export 'src/first_where_requires_or_else.dart';
export 'src/layered_import.dart';
export 'src/no_bang_on_response_data.dart';
export 'src/no_direct_navigator.dart';
export 'src/no_raw_datetime_parse.dart';

/// All analysis rules provided by this plugin, in stable listing order.
final List<AnalysisRule> luminousLintsRules = [
  LayeredImportRule(),
  NoDirectNavigatorRule(),
  FirstWhereRequiresOrElseRule(),
  NoBangOnResponseDataRule(),
  EmptyCatchRequiresCommentRule(),
  EnumParseUnknownBranchRule(),
  NoRawDatetimeParseRule(),
];
