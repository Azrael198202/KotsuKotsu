import 'package:shared_preferences/shared_preferences.dart';

class MonetizationStatus {
  const MonetizationStatus({
    required this.purchased,
    required this.inLaunchFreeWeek,
    required this.freeDaysRemaining,
  });

  final bool purchased;
  final bool inLaunchFreeWeek;
  final int freeDaysRemaining;
}

class MonetizationService {
  static const String _purchaseKey = 'kk_purchase_unlock_all';

  // Adjust this before release.
  static final DateTime launchDate = DateTime(2026, 2, 12);

  static const int unlockAllPriceYen = 1000;
  static const int freeTasksAfterWeek = 3;

  static Future<bool> isPurchased() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_purchaseKey) ?? false;
  }

  static Future<void> purchaseUnlockAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_purchaseKey, true);
  }

  static Future<MonetizationStatus> status() async {
    final purchased = await isPurchased();
    final now = DateTime.now();
    final freeEnd = launchDate.add(const Duration(days: 7));
    final inFreeWeek = !now.isBefore(launchDate) && now.isBefore(freeEnd);
    final remain = inFreeWeek ? freeEnd.difference(now).inDays + 1 : 0;
    return MonetizationStatus(
      purchased: purchased,
      inLaunchFreeWeek: inFreeWeek,
      freeDaysRemaining: remain,
    );
  }

  static bool isTaskLocked({
    required int taskIndex,
    required MonetizationStatus status,
  }) {
    if (status.purchased) return false;
    if (status.inLaunchFreeWeek) return false;
    return taskIndex >= freeTasksAfterWeek;
  }
}
