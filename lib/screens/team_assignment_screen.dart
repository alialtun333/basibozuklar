import 'package:flutter/material.dart';

import '../models/game_model.dart';
import '../services/app_data.dart';
import '../services/helpers.dart';
import '../widgets/common_widgets.dart';

class TeamAssignmentScreen extends StatefulWidget {
  final GameModel game;
  const TeamAssignmentScreen({super.key, required this.game});
  @override
  State<TeamAssignmentScreen> createState() => _TAS();
}

class _TAS extends State<TeamAssignmentScreen> {
  // Silah güç puanları (denge için)
  static const Map<String, double> weaponScore = {
    'LMG': 5.0,
    'Bolt action': 4.5,
    'DMR': 3.5,
    'Assault': 3.0,
    'CQB': 2.0,
    'SMG': 2.0,
    'GBB': 1.5,
  };

  double _teamScore(String team) {
    return widget.game.assignments.entries.where((e) => e.value == team).fold(
      0.0,
      (s, e) {
        final w = widget.game.weapons[e.key] ?? 'Assault';
        return s + (weaponScore[w] ?? 3.0);
      },
    );
  }

  void _autoAssign() {
    final att = users
        .where((u) => widget.game.statuses[u.email] == 'Geliyorum')
        .toList();
    if (att.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geliyorum diyen oyuncu yok!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mevcut atamaları temizle
    widget.game.assignments.clear();

    // 1. Kaptan ve yardımcıları ayır
    final captains = att.where((u) => u.squadRole == 'Kaptan').toList();
    final viceCaptains = att
        .where((u) => u.squadRole == 'Kaptan Yardımcısı')
        .toList();
    final rest = att.where((u) => u.squadRole == 'Yok').toList();

    int capIdx = 0;
    for (var c in captains) {
      widget.game.assignments[c.email] = capIdx % 2 == 0 ? 'Sarı' : 'Mavi';
      capIdx++;
    }
    int vcIdx = 0;
    for (var vc in viceCaptains) {
      widget.game.assignments[vc.email] = vcIdx % 2 == 0 ? 'Mavi' : 'Sarı';
      vcIdx++;
    }

    // 2. Kalanları silah puanına göre sırala (yüksekten düşüğe)
    rest.sort((a, b) {
      final aW = widget.game.weapons[a.email] ?? 'Assault';
      final bW = widget.game.weapons[b.email] ?? 'Assault';
      return (weaponScore[bW] ?? 3).compareTo(weaponScore[aW] ?? 3);
    });

    // 3. Greedy: her oyuncuyu düşük puanlı takıma ekle
    for (var u in rest) {
      final sariScore = _teamScore('Sarı');
      final maviScore = _teamScore('Mavi');
      widget.game.assignments[u.email] = sariScore <= maviScore
          ? 'Sarı'
          : 'Mavi';
    }

    setState(() {});

    final sariC = att
        .where((u) => widget.game.assignments[u.email] == 'Sarı')
        .length;
    final maviC = att
        .where((u) => widget.game.assignments[u.email] == 'Mavi')
        .length;
    final sariScore = _teamScore('Sarı');
    final maviScore = _teamScore('Mavi');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Otomatik Dağıtım → Sarı: $sariC kişi (${sariScore.toStringAsFixed(1)} puan) | Mavi: $maviC kişi (${maviScore.toStringAsFixed(1)} puan)',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext c) {
    final att = users
        .where((u) => widget.game.statuses[u.email] == 'Geliyorum')
        .toList();
    final sariC = att
        .where((u) => widget.game.assignments[u.email] == 'Sarı')
        .length;
    final maviC = att
        .where((u) => widget.game.assignments[u.email] == 'Mavi')
        .length;
    final sariScore = _teamScore('Sarı');
    final maviScore = _teamScore('Mavi');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: const Text(
          'TAKIM ATAMASI',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.amber),
            tooltip: 'Otomatik Dağıt',
            onPressed: _autoAssign,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.auto_awesome),
                label: const Text(
                  'OTOMATİK DAĞIT (Silah Dengesine Göre)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                onPressed: _autoAssign,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.4)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DENGE KURALLARI',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Sniper, LMG, DMR gibi güçlü silahlar iki takıma dengeli dağıtılır.\n'
                    '• Kaptan ve Kaptan Yardımcısı farklı takımlara atanır.\n'
                    '• GBB (az şarjör) oyuncular puanla telafi edilir.\n'
                    '• Toplam silah gücü iki takımda eşitlenmeye çalışılır.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _tc('SARI', '$sariC', sariScore, Colors.amber)),
                const SizedBox(width: 10),
                Expanded(child: _tc('MAVİ', '$maviC', maviScore, Colors.blue)),
              ],
            ),
            const SizedBox(height: 16),
            ...att.map((u) {
              final cur = widget.game.assignments[u.email];
              final w = widget.game.weapons[u.email] ?? '-';
              final score = weaponScore[w] ?? 3.0;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        userAvatar(u, radius: 12),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '[${u.code}] ${u.name}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (u.squadRole != 'Yok') ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      u.squadRole == 'Kaptan'
                                          ? Icons.star
                                          : Icons.star_half,
                                      color: Colors.amberAccent,
                                      size: 12,
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                'Güç: ${score.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            w,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(
                              () => widget.game.assignments[u.email] = 'Sarı',
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: cur == 'Sarı'
                                    ? Colors.amber.withValues(alpha: 0.3)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: cur == 'Sarı'
                                      ? Colors.amber
                                      : Colors.white24,
                                  width: cur == 'Sarı' ? 2 : 1,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'SARI',
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(
                              () => widget.game.assignments[u.email] = 'Mavi',
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: cur == 'Mavi'
                                    ? Colors.blue.withValues(alpha: 0.3)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: cur == 'Mavi'
                                      ? Colors.blue
                                      : Colors.white24,
                                  width: cur == 'Mavi' ? 2 : 1,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'MAVİ',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                setState(() {
                  widget.game.teamsAssigned = true;
                  for (var u in att) {
                    final team = widget.game.assignments[u.email] ?? '-';
                    notifyU(
                      u.email,
                      'team',
                      'Takım Ataman Yapıldı',
                      '${widget.game.title} oyunu için takımın: $team',
                    );
                  }
                  // Firestore'a yaz
                  firestoreDb
                      .collection('games')
                      .doc(widget.game.id)
                      .set(widget.game.toMap());
                  pastGames.insert(0, widget.game);
                  activeGame = null;
                });
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Takımlar atandı! Maç sonu onayı Yönetim panelinde bekliyor.',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text(
                'KAYDET VE YAYINLA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tc(String name, String cnt, double score, Color col) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: col.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: col.withValues(alpha: 0.5)),
    ),
    child: Column(
      children: [
        Text(
          name,
          style: TextStyle(
            color: col,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          cnt,
          style: TextStyle(
            color: col,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Güç: ${score.toStringAsFixed(1)}',
          style: TextStyle(color: col.withValues(alpha: 0.7), fontSize: 10),
        ),
      ],
    ),
  );
}
