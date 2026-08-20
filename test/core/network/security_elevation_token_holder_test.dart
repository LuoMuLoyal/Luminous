import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/security_elevation_token_holder.dart';

void main() {
  test('treats a token at its exact expiry boundary as expired', () {
    final now = DateTime(2026, 8, 20, 12);
    final holder = SecurityElevationTokenHolder(now: () => now);

    holder.set('exact-boundary-token', now);

    expect(holder.token, isNull);
    expect(holder.hasValidToken, isFalse);
  });

  test('keeps a token valid strictly before its expiry boundary', () {
    final now = DateTime(2026, 8, 20, 12);
    final holder = SecurityElevationTokenHolder(now: () => now);

    holder.set('valid-token', now.add(const Duration(seconds: 1)));

    expect(holder.token, 'valid-token');
    expect(holder.hasValidToken, isTrue);
  });
}
