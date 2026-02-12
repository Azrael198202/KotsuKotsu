class AuthSession {
  const AuthSession({
    required this.userId,
    required this.createdAt,
    required this.expiresAt,
  });

  final String userId;
  final DateTime createdAt;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
