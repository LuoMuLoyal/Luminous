/// Domain entity for a verification code cooldown response.
class VerificationCooldown {
  const VerificationCooldown({
    required this.message,
    required this.cooldownSeconds,
  });

  final String message;
  final int cooldownSeconds;
}
