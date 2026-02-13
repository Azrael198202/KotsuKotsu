import 'package:flutter/material.dart';

import '../models/navigation_args.dart';
import '../services/monetization_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  static const String routeName = '/payment';

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

enum _PlanKind { low, high, all }

class _PaymentScreenState extends State<PaymentScreen> {
  bool _processing = false;
  bool _purchased = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final paymentArgs = args is PaymentArgs ? args : const PaymentArgs(grade: 1);
    final activePlan = _activePlanByGrade(paymentArgs.grade);

    return Scaffold(
      appBar: AppBar(
        title: const Text('コツコツプラン'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7FBF1), Color(0xFFE9F6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDCE7D2)),
                ),
                child: Text(
                  _purchased
                      ? 'こうにゅう かんりょう: すべて の がくねん が つかえます'
                      : 'えらんだ がくねん の プランを かくにん してください',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF285D2A),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _PlanCard(
                title: '低学年プラン',
                subtitle: '1-3ねんせい',
                price: '1,000円',
                imageAsset: 'assets/bg/low.png',
                accent: const Color(0xFF4CAF50),
                enabled: _purchased || activePlan == _PlanKind.low,
                purchased: _purchased,
                processing: _processing,
                onPressed: _purchased || activePlan != _PlanKind.low ? null : _purchase,
              ),
              const SizedBox(height: 12),
              _PlanCard(
                title: '高学年プラン',
                subtitle: '4-6ねんせい',
                price: '2,500円',
                imageAsset: 'assets/bg/high.png',
                accent: const Color(0xFFFF9800),
                enabled: _purchased || activePlan == _PlanKind.high,
                purchased: _purchased,
                processing: _processing,
                onPressed: _purchased || activePlan != _PlanKind.high ? null : _purchase,
              ),
              const SizedBox(height: 12),
              _PlanCard(
                title: '全学年プラン',
                subtitle: '1-6ねんせい',
                price: '8,400円',
                imageAsset: 'assets/bg/all.png',
                accent: const Color(0xFFFF7043),
                enabled: _purchased || activePlan == _PlanKind.all,
                purchased: _purchased,
                processing: _processing,
                onPressed: _purchased || activePlan != _PlanKind.all ? null : _purchase,
              ),
              const SizedBox(height: 12),
              const Text(
                '※ひょうじ かかく は すべて ぜいこみ です',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5B6B73),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _PlanKind _activePlanByGrade(int grade) {
    if (grade >= 1 && grade <= 3) return _PlanKind.low;
    if (grade >= 4 && grade <= 6) return _PlanKind.high;
    return _PlanKind.all;
  }

  Future<void> _load() async {
    final purchased = await MonetizationService.isPurchased();
    if (!mounted) return;
    setState(() {
      _purchased = purchased;
    });
  }

  Future<void> _purchase() async {
    setState(() => _processing = true);
    await MonetizationService.purchaseUnlockAll();
    if (!mounted) return;
    setState(() {
      _processing = false;
      _purchased = true;
    });
    Navigator.pop(context, true);
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imageAsset,
    required this.accent,
    required this.enabled,
    required this.purchased,
    required this.processing,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String price;
  final String imageAsset;
  final Color accent;
  final bool enabled;
  final bool purchased;
  final bool processing;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final opacity = enabled ? 1.0 : 0.42;
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5E5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 86,
                height: 86,
                color: const Color(0xFFF3F8EF),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFF94A3B8),
                    size: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: accent,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF425466),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                      height: 0.95,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: enabled ? accent : const Color(0xFFB9C2CC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onPressed: onPressed,
              child: Text(
                purchased
                    ? 'こうにゅうずみ'
                    : processing
                    ? 'しょりちゅう'
                    : enabled
                    ? 'えらぶ'
                    : 'たいしょうがい',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
