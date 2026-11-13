import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/game_model.dart';
import '../models/survey_model.dart';
import '../services/app_data.dart';
import '../services/helpers.dart';

// ============================================================
// ANKET KATILIM AKIŞI (3 ADIM)
// ============================================================
class SurveyFlowScreen extends StatefulWidget {
  final UserModel user;
  final GameModel game;
  const SurveyFlowScreen({super.key, required this.user, required this.game});
  @override
  State<SurveyFlowScreen> createState() => _SFS();
}

class _SFS extends State<SurveyFlowScreen> {
  int _step = 0;
  String _att = 'Belirsiz';
  String _wep = 'Assault';

  @override
  void initState() {
    super.initState();
    _att = widget.game.statuses[widget.user.email] ?? 'Belirsiz';
    _wep = widget.game.weapons[widget.user.email] ?? 'Assault';
  }

  void _next() {
    if (_step == 0) {
      if (_att == 'Geliyorum') {
        setState(() => _step = 1);
      } else {
        _save();
      }
    } else if (_step == 1) {
      setState(() => _step = 2);
    } else {
      _save();
    }
  }

  void _save() {
    widget.game.statuses[widget.user.email] = _att;
    if (_att == 'Geliyorum') widget.game.weapons[widget.user.email] = _wep;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anket kaydedildi!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _ab(String l, IconData ic, Color col) {
    final sel = _att == l;
    return InkWell(
      onTap: () => setState(() => _att = l),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: sel ? col.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? col : Colors.white12,
            width: sel ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(ic, color: col, size: 24),
            const SizedBox(width: 12),
            Text(
              l,
              style: TextStyle(
                color: sel ? col : Colors.white70,
                fontSize: 15,
                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sumRow(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(l, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const Spacer(),
        Text(
          v,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
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
      title: Text(
        'ADIM ${_step + 1}/3',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= _step ? Colors.amber : Colors.white12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          if (_step == 0) ...[
            const Text(
              'KATILIM DURUMU',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Oyuna katılıp katılmayacağını belirt:',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _ab('Geliyorum', Icons.check_circle, Colors.green),
            const SizedBox(height: 10),
            _ab('Belirsiz', Icons.help, Colors.orange),
            const SizedBox(height: 10),
            _ab('Gelmiyorum', Icons.cancel, Colors.red),
          ] else if (_step == 1) ...[
            const Text(
              'ANA SİLAH',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Oyun sırasında kullanacağın ana silahı seç:',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ...weaponList.map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => setState(() => _wep = w),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _wep == w
                          ? Colors.amber.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _wep == w ? Colors.amber : Colors.white12,
                        width: _wep == w ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.gps_fixed,
                          color: _wep == w ? Colors.amber : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          w,
                          style: TextStyle(
                            color: _wep == w ? Colors.white : Colors.white70,
                            fontWeight: _wep == w
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            const Text(
              'ÖZET',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  _sumRow('Katılım', _att),
                  const Divider(color: Colors.white12),
                  _sumRow('Ana Silah', _wep),
                ],
              ),
            ),
          ],
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _next,
            child: Text(
              _step == 2 ? 'KAYDET VE ÇIK' : 'DEVAM ET',
              style: const TextStyle(
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

// ============================================================
// ANKETLER LİSTESİ VE OY VERME
// ============================================================
class SurveysScreen extends StatefulWidget {
  final UserModel user;
  const SurveysScreen({super.key, required this.user});
  @override
  State<SurveysScreen> createState() => _SS();
}

class _SS extends State<SurveysScreen> {
  String get _curEmail => widget.user.email;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    // YÜKLEME KONTROLÜ
    if (users.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: const Text(
          'ANKETLER',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: surveys.isEmpty
          ? const Center(
              child: Text(
                'Henüz anket yok.',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: surveys.length,
              itemBuilder: (c, i) {
                final s = surveys[i];
                final now = DateTime.now();
                final isActive = now.isBefore(s.endDate);
                final left = s.endDate.difference(now);
                final totalVotes = s.votes.length;
                final myVote = s.votes[_curEmail];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? Colors.amber.withValues(alpha: 0.4)
                          : Colors.white12,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : Colors.grey.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isActive ? 'Aktif' : 'Kapandı',
                              style: TextStyle(
                                color: isActive ? Colors.green : Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Bitiş: ${fmtDT(s.endDate)}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.title,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.description,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.timer,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Kalan:',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                fmtDur(left),
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.how_to_vote,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Toplam $totalVotes oy',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...s.options.map((o) {
                        final voters = s.votes.entries
                            .where((e) => e.value == o.id)
                            .map((e) => e.key)
                            .toList();
                        final cnt = voters.length;
                        final pct = totalVotes == 0 ? 0.0 : cnt / totalVotes;
                        final isMine = myVote == o.id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMine
                                ? Colors.green.withValues(alpha: 0.08)
                                : Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isMine ? Colors.green : Colors.white12,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isMine
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: isMine ? Colors.green : Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      o.text,
                                      style: TextStyle(
                                        color: isMine
                                            ? Colors.green
                                            : Colors.white,
                                        fontWeight: isMine
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$cnt oy (%${(pct * 100).toStringAsFixed(0)})',
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 4,
                                  backgroundColor: Colors.white12,
                                  valueColor: AlwaysStoppedAnimation(
                                    isMine ? Colors.green : Colors.amber,
                                  ),
                                ),
                              ),
                              if (voters.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Theme(
                                  data: Theme.of(
                                    c,
                                  ).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    tilePadding: EdgeInsets.zero,
                                    childrenPadding: const EdgeInsets.only(
                                      left: 8,
                                      bottom: 4,
                                    ),
                                    dense: true,
                                    leading: const Icon(
                                      Icons.people,
                                      color: Colors.white54,
                                      size: 14,
                                    ),
                                    title: Text(
                                      'Kimler oy verdi (${voters.length})',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 10,
                                      ),
                                    ),
                                    iconColor: Colors.white54,
                                    collapsedIconColor: Colors.white54,
                                    children: voters.map((em) {
                                      final u = users.firstWhere(
                                        (x) => x.email == em,
                                        orElse: () => users[0],
                                      );
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 10,
                                              backgroundColor: Colors.amber
                                                  .withValues(alpha: 0.2),
                                              child: Text(
                                                u.name[0],
                                                style: const TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '[${u.code}] ${u.name}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      if (isActive) ...[
                        if (myVote != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '"${s.options.firstWhere((o) => o.id == myVote).text}" oyu verdin',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.amber,
                              side: const BorderSide(color: Colors.amber),
                            ),
                            onPressed: () async {
                              final v = await showDialog<String>(
                                context: c,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: const Color(0xFF121212),
                                  title: Text(
                                    s.title,
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 14,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: s.options
                                        .map(
                                          (o) => ListTile(
                                            title: Text(
                                              o.text,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            trailing: myVote == o.id
                                                ? const Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                  )
                                                : null,
                                            onTap: () =>
                                                Navigator.pop(ctx, o.id),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              );
                              if (v != null) {
                                setState(() => s.votes[_curEmail] = v);
                                try {
                                  await firestoreDb
                                      .collection('surveys')
                                      .doc(s.id)
                                      .set(s.toMap());
                                  if (c.mounted) {
                                    ScaffoldMessenger.of(c).showSnackBar(
                                      const SnackBar(
                                        content: Text('Oyunuz kaydedildi!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (c.mounted) {
                                    ScaffoldMessenger.of(c).showSnackBar(
                                      SnackBar(
                                        content: Text('Oy kaydedilemedi: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: Text(
                              myVote != null ? 'OYUNU DEĞİŞTİR' : 'OY VER',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (!isActive)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Text(
                              'Bu anket kapandı.',
                              style: TextStyle(color: Colors.red, fontSize: 11),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ============================================================
// ANKET OLUŞTUR
// ============================================================
class SurveyCreateScreen extends StatefulWidget {
  const SurveyCreateScreen({super.key});
  @override
  State<SurveyCreateScreen> createState() => _SCS();
}

class _SCS extends State<SurveyCreateScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final List<TextEditingController> _opts = [
    TextEditingController(),
    TextEditingController(),
  ];
  DateTime? _end;

  void _addOpt() => setState(() => _opts.add(TextEditingController()));

  Future<DateTime?> _pick() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d == null || !mounted) return null;
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
    );
    if (t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  InputDecoration _inp(String l) => InputDecoration(
    labelText: l,
    labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
    filled: true,
    fillColor: Colors.black,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.white12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.amber),
    ),
  );

  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.amber,
      title: const Text(
        'ANKET OLUŞTUR',
        style: TextStyle(
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _title,
            style: const TextStyle(color: Colors.white),
            decoration: _inp('Anket Başlığı'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _desc,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: _inp('Açıklama'),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final p = await _pick();
              if (p != null) setState(() => _end = p);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _end == null
                        ? 'Bitiş Tarihi & Saati'
                        : 'Bitiş: ${fmtDT(_end!)}',
                    style: TextStyle(
                      color: _end == null ? Colors.white54 : Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  const Icon(Icons.event, color: Colors.amber, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'SEÇENEKLER',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ..._opts.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: e.value,
                style: const TextStyle(color: Colors.white),
                decoration: _inp('Seçenek ${e.key + 1}'),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _addOpt,
            icon: const Icon(Icons.add, color: Colors.amber),
            label: const Text(
              'SEÇENEK EKLE',
              style: TextStyle(color: Colors.amber),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              if (_title.text.isEmpty || _end == null) return;
              final opts = _opts.where((c) => c.text.isNotEmpty).toList();
              if (opts.length < 2) return;
              setState(() {
                final s = SurveyModel(
                  id: uid(),
                  title: _title.text,
                  description: _desc.text,
                  type: 'Karar',
                  endDate: _end!,
                  options: opts
                      .asMap()
                      .entries
                      .map(
                        (e) => SurveyOption(id: '${e.key}', text: e.value.text),
                      )
                      .toList(),
                );
                surveys.add(s);
                firestoreDb.collection('surveys').doc(s.id).set(s.toMap());
                notifyAll(
                  'survey',
                  'Yeni Anket: ${_title.text}',
                  '${_desc.text}\nBitiş: ${fmtDT(_end!)}',
                );
              });
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Anket oluşturuldu ve bildirim gönderildi!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'OLUŞTUR VE BİLDİRİM GÖNDER',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
          ),
        ],
      ),
    ),
  );
}
