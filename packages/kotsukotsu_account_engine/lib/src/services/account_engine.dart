import 'dart:math';

import '../models/app_user.dart';
import '../models/auth_session.dart';
import '../models/subscription_status.dart';

class AccountEngine {
  final Map<String, _Credential> _credentialsByLogin = <String, _Credential>{};
  final Map<String, AppUser> _usersById = <String, AppUser>{};
  final Map<String, SubscriptionStatus> _subscriptionsByUserId =
      <String, SubscriptionStatus>{};

  AuthSession? _session;

  AppUser register({
    required String loginName,
    required String password,
    required String displayName,
  }) {
    final key = loginName.trim().toLowerCase();
    if (key.isEmpty || password.isEmpty) {
      throw StateError('loginName/password cannot be empty');
    }
    if (_credentialsByLogin.containsKey(key)) {
      throw StateError('login already exists');
    }

    final user = AppUser(
      userId: _newId(),
      displayName: displayName.trim().isEmpty ? loginName : displayName.trim(),
      loginName: loginName,
    );
    _usersById[user.userId] = user;
    _credentialsByLogin[key] = _Credential(userId: user.userId, password: password);
    return user;
  }

  AuthSession login({required String loginName, required String password}) {
    final key = loginName.trim().toLowerCase();
    final credential = _credentialsByLogin[key];
    if (credential == null || credential.password != password) {
      throw StateError('invalid credentials');
    }

    final now = DateTime.now();
    _session = AuthSession(
      userId: credential.userId,
      createdAt: now,
      expiresAt: now.add(const Duration(days: 7)),
    );
    return _session!;
  }

  void logout() {
    _session = null;
  }

  AppUser? currentUser() {
    final session = _session;
    if (session == null || session.isExpired) {
      return null;
    }
    return _usersById[session.userId];
  }

  SubscriptionStatus updateSubscription({
    required String userId,
    required String planCode,
    required bool isPaid,
    DateTime? expireAt,
  }) {
    final user = _usersById[userId];
    if (user == null) {
      throw StateError('user not found');
    }
    final status = SubscriptionStatus(
      userId: userId,
      planCode: planCode,
      isPaid: isPaid,
      expireAt: expireAt,
    );
    _subscriptionsByUserId[userId] = status;
    return status;
  }

  SubscriptionStatus? subscriptionOf(String userId) {
    return _subscriptionsByUserId[userId];
  }

  List<AppUser> listUsers() {
    return _usersById.values.toList(growable: false)
      ..sort((a, b) => a.userId.compareTo(b.userId));
  }

  String _newId() {
    final rand = Random();
    final millis = DateTime.now().millisecondsSinceEpoch;
    final suffix = rand.nextInt(1 << 20).toRadixString(16);
    return 'u_${millis}_$suffix';
  }
}

class _Credential {
  const _Credential({required this.userId, required this.password});

  final String userId;
  final String password;
}
