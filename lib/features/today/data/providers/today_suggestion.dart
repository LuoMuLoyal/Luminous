/// The today dashboard aggregate repository is wired in the composition
/// root (`lib/app/composition/today_suggestion.dart`): it composes other
/// features' domain repositories, which `today/data/` may not import.
library;

export 'package:luminous/app/composition/today_suggestion.dart';
