class AppUser {
  const AppUser({
    required this.userId,
    required this.displayName,
    required this.loginName,
    this.isActive = true,
  });

  final String userId;
  final String displayName;
  final String loginName;
  final bool isActive;

  AppUser copyWith({
    String? userId,
    String? displayName,
    String? loginName,
    bool? isActive,
  }) {
    return AppUser(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      loginName: loginName ?? this.loginName,
      isActive: isActive ?? this.isActive,
    );
  }
}
