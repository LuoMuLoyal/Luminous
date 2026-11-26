/// One reviewed medication safety tip, as delivered by
/// `GET /api/v1/medicines/safety-tips`.
///
/// Rendered by `SafetyTipCard` through the `safety.tip_card` component; the
/// text is already localised server-side, so there is no client-side copy here.
class MedicineSafetyTip {
  const MedicineSafetyTip({
    required this.id,
    required this.text,
    required this.category,
  });

  final String id;
  final String text;
  final String category;
}
