import 'package:flutter/material.dart';

class LegalSafetyScreen extends StatelessWidget {
  const LegalSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F4),
      appBar: AppBar(
        title: const Text(
          'けんり・あんぜん',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
        children: const [
          _InfoCard(
            icon: Icons.copyright,
            iconColor: Color(0xFF6FA8DC),
            title: 'ちょさくけん (著作権)',
            content:
                'このアプリにふくまれる もんだい・がぞう・デザイン・ぶんしょう などの\n'
                'すべてのコンテンツの ちょさくけんは\n'
                'コツコツ学習アプリ運営に きぞくします。',
          ),
          SizedBox(height: 10),
          _InfoCard(
            icon: Icons.not_interested_rounded,
            iconColor: Color(0xFFE08A7A),
            title: 'つぎのことは きんし されています:',
            bullets: [
              'アプリのないようを むだんで コピーすること',
              'かめんを さつえいして はいふすること',
              'インターネットへの むだん けいさい',
              'しょうよう もくてきでの りよう',
            ],
            content:
                'がっこう・かてい学習での りようは\n'
                'このアプリ内のみで おたのしみください。',
          ),
          SizedBox(height: 10),
          _InfoCard(
            icon: Icons.verified_user_rounded,
            iconColor: Color(0xFF8BC47E),
            title: 'あんぜん (安全について)',
            content: 'お子さまが あんしんして 学習できるよう つぎの点に ごちゅういください。',
            bullets: [
              'ながい時間 つづけて使わず、てきどに きゅうけいを とりましょう',
              'めを 画面に ちかづけすぎないように しましょう',
              'あかるい ばしょで 学習してください',
              '小さなお子さまは 保護者の方と いっしょに ご利用ください',
            ],
          ),
          SizedBox(height: 10),
          _InfoCard(
            icon: Icons.monetization_on_rounded,
            iconColor: Color(0xFFE5B24A),
            title: 'かきん (課金について)',
            bullets: [
              '課金は 保護者の方が 行ってください',
              '一度 購入すると 同じ Apple ID / Google アカウントで 再インストール後も 利用できます',
              '無料を 受けたばあいも もどせません',
            ],
          ),
          SizedBox(height: 10),
          _InfoCard(
            icon: Icons.help_outline_rounded,
            iconColor: Color(0xFFF0A74A),
            title: 'お問い合わせ',
            content: 'ご不明な点がございましたら\nアプリ内のおしらせをご確認ください。',
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.content,
    this.bullets = const [],
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? content;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 30),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF36414A),
                  ),
                ),
              ),
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: 8),
            Text(
              content!,
              style: const TextStyle(
                fontSize: 16,
                height: 1.45,
                color: Color(0xFF505B63),
              ),
            ),
          ],
          if (bullets.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final bullet in bullets) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Icon(
                      Icons.circle,
                      size: 5,
                      color: Color(0xFFD89A86),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bullet,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        color: Color(0xFF505B63),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
            ],
          ],
        ],
      ),
    );
  }
}
