class SubscriptionStatus {
  const SubscriptionStatus({
    required this.userId,
    required this.planCode,
    required this.isPaid,
    this.expireAt,
  });

  final String userId;
  final String planCode;
  final bool isPaid;
  final DateTime? expireAt;

  bool get isValid {
    if (!isPaid) return false;
    if (expireAt == null) return true;
    return DateTime.now().isBefore(expireAt!);
  }
}
