import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:luminous/app/composition/components/registry.dart';

/// Component-system overrides for widget tests.
///
/// The app installs the same overrides in `main.dart` (composition root). A test
/// that renders a whole page or a section needs them too, otherwise
/// `ComponentHost` finds an empty registry and renders nothing.
List<Override> compositionTestOverrides() => compositionProviderOverrides();
