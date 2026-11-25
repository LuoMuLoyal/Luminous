import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/medicine/domain/entities/adverse_reaction.dart';

/// The band function is the only place a raw `pred1` score is interpreted, so
/// its cut points are pinned here rather than only exercised through the widget.
void main() {
  group('ReactionConfidence.fromScore', () {
    test('bands at the measured corpus quartiles', () {
      // Cut points come from the full 6.7M-row distribution, not round numbers.
      expect(
        ReactionConfidence.fromScore(ReactionConfidence.highFloor),
        ReactionConfidence.high,
      );
      expect(
        ReactionConfidence.fromScore(ReactionConfidence.mediumFloor),
        ReactionConfidence.medium,
      );
      expect(
        ReactionConfidence.fromScore(ReactionConfidence.mediumFloor - 0.01),
        ReactionConfidence.low,
      );
    });

    test('a missing score is "unscored", never "low"', () {
      // The source omits a score on some rows. Rendering that as "limited
      // evidence" would invent a judgement the data does not contain.
      expect(ReactionConfidence.fromScore(null), ReactionConfidence.unscored);
    });

    test('the observed floor still bands low', () {
      // Observed minimum over the corpus is 3.258.
      expect(ReactionConfidence.fromScore(3.258), ReactionConfidence.low);
    });
  });

  group('ReactionSection.fromWire', () {
    test('maps the four known label sections', () {
      expect(ReactionSection.fromWire('AR'), ReactionSection.adverseReaction);
      expect(ReactionSection.fromWire('BW'), ReactionSection.boxedWarning);
      expect(
        ReactionSection.fromWire('WP'),
        ReactionSection.warningPrecautions,
      );
      expect(ReactionSection.fromWire('NA'), ReactionSection.notApplicable);
    });

    test('an unknown section code degrades instead of throwing', () {
      // A quarterly upstream release may add a section code; that must not
      // break the page.
      expect(ReactionSection.fromWire('ZZ'), ReactionSection.notApplicable);
    });
  });
}
