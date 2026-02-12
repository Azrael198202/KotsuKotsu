import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/student_profile.dart';

class AppUserService {
  static const int gradeUnlockPriceYen = 1000;
  static const int allUnlockPriceYen = 4800;

  static const String _usersKey = 'kk_users';
  static const String _currentUserKey = 'kk_current_user';
  static const String _unlockedGradesKey = 'kk_unlocked_grades';
  static const String _allUnlockedKey = 'kk_all_unlocked';
  static const String _profilePrefix = 'kk_profile_';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_currentUserKey) ?? '').isNotEmpty;
  }

  static Future<String?> currentLoginId() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_currentUserKey);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static Future<bool> register({
    required String loginId,
    required String password,
  }) async {
    final id = loginId.trim();
    if (id.isEmpty || password.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    final users = _readUsers(prefs);
    if (users.containsKey(id)) return false;
    users[id] = password;
    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.setString(_currentUserKey, id);
    return true;
  }

  static Future<bool> login({
    required String loginId,
    required String password,
  }) async {
    final id = loginId.trim();
    if (id.isEmpty || password.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    final users = _readUsers(prefs);
    if (users[id] != password) return false;
    await prefs.setString(_currentUserKey, id);
    return true;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  static Future<StudentProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final loginId = prefs.getString(_currentUserKey);
    if (loginId == null || loginId.isEmpty) return StudentProfile.empty();
    final raw = prefs.getString('$_profilePrefix$loginId');
    if (raw == null || raw.isEmpty) return StudentProfile.empty();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return StudentProfile.fromJson(decoded);
  }

  static Future<void> saveProfile(StudentProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final loginId = prefs.getString(_currentUserKey);
    if (loginId == null || loginId.isEmpty) return;
    await prefs.setString(
      '$_profilePrefix$loginId',
      jsonEncode(profile.toJson()),
    );
  }

  static Future<Set<int>> unlockedGrades() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_unlockedGradesKey) ?? const <String>[];
    return list.map(int.tryParse).whereType<int>().toSet();
  }

  static Future<bool> isGradeUnlocked(int grade) async {
    if (await isAllUnlocked()) return true;
    final grades = await unlockedGrades();
    return grades.contains(grade);
  }

  static Future<void> unlockGrade(int grade) async {
    final prefs = await SharedPreferences.getInstance();
    final grades = await unlockedGrades();
    grades.add(grade);
    await prefs.setStringList(
      _unlockedGradesKey,
      (grades.toList()..sort()).map((e) => e.toString()).toList(),
    );
  }

  static Future<bool> isAllUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_allUnlockedKey) ?? false;
  }

  static Future<void> unlockAllGrades() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_allUnlockedKey, true);
  }

  static Map<String, String> _readUsers(SharedPreferences prefs) {
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return <String, String>{};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }
}
