import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../widgets/common_widgets.dart';

class RulesScreen extends StatelessWidget {
  final UserModel user;
  final VoidCallback refresh;
  const RulesScreen({super.key, required this.user, required this.refresh});

  Widget _rep(
    String t,
    String fps,
    String m,
    String a,
    String d,
    String note,
  ) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF121212),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t,
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
              ),
              child: Text(
                '$fps FPS',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const Divider(color: Colors.white12, height: 16),
        _ir('Min. Atış Mesafesi', m),
        _ir('Maks. Mühimmat', a),
        _ir('Azami Donanım', d),
        const SizedBox(height: 8),
        Text(
          note,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ],
    ),
  );

  Widget _ir(String l, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '$l: ',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            v,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );

  Widget _spec(String title, String content, IconData icon) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF121212),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.amber,
      title: const Text(
        'KURALLAR & FPS',
        style: TextStyle(
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      actions: [notifBtn(c, user, refresh), const SizedBox(width: 4)],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GENEL KURALLAR',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Oyun başlangıcında tüm replikalar, tek bir chrono ile ölçülür. Tüm değerler 0.20gr BB içindir.\n• High Capacity şarjör yasaklanmıştır.\n• Tüm ölçümlerde en fazla +5 FPS tolerans uygulanır.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'REPLİKA SINIFLARI VE FPS SINIRLAMALARI',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _rep(
            'ASSAULT',
            '400',
            '10M',
            'Sınırsız Lowcap / 2+1 Midcap',
            '-',
            '0.20gr BB.',
          ),
          _rep(
            'DMR',
            '450',
            '20M',
            'Sınırsız Lowcap / 2+1 Midcap',
            'Dürbün',
            'Tekli atış, seri atış yasak.',
          ),
          _rep('PİSTOL', '330', 'Yok', 'Sınırsız', '-', 'Sadece tekli atış.'),
          _rep(
            'SNIPER',
            '550',
            '25M',
            'Sınırsız',
            'Dürbün',
            'Yaylı kurmalı. Pistol harici replika alınamaz.',
          ),
          _rep(
            'SMG - CQB',
            '330',
            '10M İçi Tekli / Dışı Oto',
            'Sınırsız Lowcap / 2+1 Midcap',
            '-',
            '10m içi tekli, dışı seri.',
          ),
          _rep(
            'LMG',
            '450',
            '20M',
            '1+1 Tambur',
            '5KG',
            'M249, M60, Mg3, Mg4, PKM vb.',
          ),
          _rep(
            'AMR',
            '500',
            '25M',
            '2+1',
            'Dürbün / 8KG',
            'Barret m82 gibi .50 cal. Tekli atış.',
          ),
          const SizedBox(height: 20),
          const Text(
            'ÖZEL EKİPMAN KURALLARI',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _spec(
            'KALKAN (5KG)',
            'Plastik, ahşap, metal (şeffaf olamaz). Max 130cm x 80cm.\n\nKalkan taşıyan oyuncu sadece tabanca ile oynayabilir.',
            Icons.shield,
          ),
          _spec(
            'EL BOMBASI / SİS / GL',
            'Kapalı mekanda: Sert arkasında korunmayan herkes ölü. Oda büyükse 3m içi ölü.\n\nAçık alanda: Patlama noktasına 3m içi ve BB çarpan herkes ölü.',
            Icons.local_fire_department,
          ),
        ],
      ),
    ),
  );
}
