import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'monetization_service.dart';

class AdPopupService {
  static const String adImageAssetPortrait = 'assets/ads/promo_release.png';
  static const String adImageAssetLandscape = 'assets/ads/promo_release_h.png';
  static bool _shownThisLaunch = false;

  static Future<void> showLocalAdPopup(BuildContext context) async {
    if (kReleaseMode && _shownThisLaunch) return;
    final status = await MonetizationService.status();
    if (kReleaseMode && status.purchased) return;
    if (kReleaseMode) _shownThisLaunch = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final media = MediaQuery.of(context);
        final isLandscape = media.orientation == Orientation.landscape;
        final adImageAsset =
            isLandscape ? adImageAssetLandscape : adImageAssetPortrait;
        final safeWidth = media.size.width - media.padding.left - media.padding.right;
        final safeHeight =
            media.size.height - media.padding.top - media.padding.bottom;
        final dialogWidth = isLandscape
            ? (safeHeight * 1.48).clamp(safeWidth * 0.72, safeWidth * 0.88).toDouble()
            : safeWidth * 0.92;
        final dialogHeight = isLandscape ? safeHeight * 0.92 : safeHeight * 0.88;
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 6 : 20,
            vertical: isLandscape ? 10 : 24,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isLandscape ? 10 : 16,
                isLandscape ? 10 : 14,
                isLandscape ? 10 : 16,
                isLandscape ? 10 : 14,
              ),
              child: Column(
                children: [
                  const Text(
                    'おしらせ',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: isLandscape ? 6 : 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SizedBox(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            child: Image.asset(
                              adImageAsset,
                              fit: BoxFit.contain,
                              alignment: Alignment.topCenter,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFECEFF1),
                                alignment: Alignment.center,
                                child: const Text(
                                  'こうこく がぞうを\nよみこめませんでした',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: isLandscape ? 8 : 14),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                    child: const Text(
                      'とじる',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
