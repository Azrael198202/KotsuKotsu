import 'package:flutter/material.dart';

import '../models/navigation_args.dart';
import '../services/monetization_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  static const String routeName = '/payment';

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

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
    final grade = paymentArgs.grade;

    return Scaffold(
      appBar: AppBar(title: const Text('課金/会員')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$grade年生 ${paymentArgs.taskName ?? ''}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _purchased
                  ? '購入済み: すべての課題が解放されています'
                  : '前3課題は無料です。以降は課金で解放されます。',
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text('買い切り解放 (Grade $grade 含む全課題)'),
              subtitle: Text('¥${MonetizationService.unlockAllPriceYen}'),
              trailing: FilledButton(
                onPressed: _processing || _purchased ? null : _purchase,
                child: Text(_purchased ? '購入済み' : '購入'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '※ 本番ではアプリ内課金の復元機能で、再インストール後も購入状態を復元します。',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
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
