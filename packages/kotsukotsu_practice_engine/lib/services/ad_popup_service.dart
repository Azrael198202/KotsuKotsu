import 'package:flutter/material.dart';

import 'monetization_service.dart';

class AdPopupService {
  static const String adImageAsset = 'assets/ads/promo.png';
  static bool _shownThisLaunch = false;

  static Future<void> showLocalAdPopup(BuildContext context) async {
    if (_shownThisLaunch) return;
    final status = await MonetizationService.status();
    if (status.purchased) return;
    _shownThisLaunch = true;

    final message = status.inLaunchFreeWeek
        ? 'リリース記念: 全課題無料\n残り ${status.freeDaysRemaining} 日'
        : '前3課題は無料です。\n全課題解放はアプリ内課金をご利用ください。';

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'お知らせ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    adImageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: const Color(0xFFECEFF1),
                      alignment: Alignment.center,
                      child: const Text('広告画像を読み込めませんでした'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('閉じる'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
