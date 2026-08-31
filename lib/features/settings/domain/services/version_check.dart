/// Compares two semantic version strings (e.g. "0.1.0" vs "0.2.0").
///
/// Returns a negative integer if [a] < [b], zero if equal, positive if [a] > [b].
/// Non-numeric segments are treated as 0. Versions with fewer segments are
/// zero-padded (e.g. "1.0" is treated as "1.0.0"). Build metadata and
/// pre-release suffixes are stripped before comparison.
int compareSemver(String a, String b) {
  final partsA = _parseSemver(a);
  final partsB = _parseSemver(b);
  final maxLen = partsA.length > partsB.length ? partsA.length : partsB.length;

  for (var i = 0; i < maxLen; i++) {
    final valueA = i < partsA.length ? partsA[i] : 0;
    final valueB = i < partsB.length ? partsB[i] : 0;
    if (valueA != valueB) {
      return valueA.compareTo(valueB);
    }
  }
  return 0;
}

List<int> _parseSemver(String version) {
  // Strip build metadata (e.g. "0.1.0+1" → "0.1.0") and pre-release
  // suffixes (e.g. "0.1.0-beta" → "0.1.0").
  final clean = version.split('+').first.split('-').first;
  return clean
      .split('.')
      .map((part) => int.tryParse(part.trim()) ?? 0)
      .toList();
}
