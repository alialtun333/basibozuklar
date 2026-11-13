import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/game_model.dart';
import '../models/badge_model.dart';
import '../models/inventory_model.dart';
import '../models/game_summary_model.dart';
import '../models/announcement_model.dart';
import '../services/app_data.dart';
import '../services/helpers.dart';
import '../widgets/common_widgets.dart';
import 'survey_screen.dart';
import 'team_assignment_screen.dart';
import 'inventory_screen.dart';

class AdminScreen extends StatefulWidget {
  final UserModel user;
  final VoidCallback refresh;
  const AdminScreen({super.key, required this.user, required this.refresh});
  @override
  State<AdminScreen> createState() => _AS();
}

class _AS extends State<AdminScreen> {
  final _locationCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _gameName = TextEditingController();
  final _scenarioCtrl = TextEditingController();
  DateTime? _gameDT, _surveyEndDT;
  String _participationRestriction = 'all';
  String _surveyRestriction = 'all';
  final _invName = TextEditingController();
  final _invCat = TextEditingController();
  final _annTitle = TextEditingController();
  final _annContent = TextEditingController();
  final _badgeName = TextEditingController();
  final _badgeDesc = TextEditingController();
  String _badgeIcon = 'star';
  String _badgeColor = 'amber';
  String _badgeAutoRule = 'none';

  Future<DateTime?> _pickDT({DateTime? init}) async {
    final d = await showDatePicker(
      context: context,
      initialDate: init ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d == null || !mounted) return null;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(init ?? DateTime.now()),
    );
    if (t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  void _zimmetDialog(InventoryModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: Text(
          '${item.name} Zimmetle',
          style: const TextStyle(color: Colors.amber, fontSize: 15),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.warehouse, color: Colors.green),
                title: const Text(
                  'Depoya İade',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    final oldOwner = item.owner;
                    item.owner = '-';
                    if (oldOwner != '-') {
                      final oldUser = users.firstWhere(
                        (u) => u.email == oldOwner,
                        orElse: () => users[0],
                      );
                      addZimmetLog(
                        item.name,
                        oldUser.name,
                        'İade Edildi',
                        widget.user.name,
                      );
                    }
                    firestoreDb
                        .collection('inventory')
                        .doc(item.id)
                        .set(item.toMap());
                  });
                  Navigator.pop(ctx);
                },
              ),
              const Divider(color: Colors.white12),
              ...users.map(
                (u) => ListTile(
                  leading: userAvatar(u, radius: 16),
                  title: Text(
                    '[${u.code}] ${u.name}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      item.owner = u.email;
                      addZimmetLog(
                        item.name,
                        u.name,
                        'Zimmetlendi',
                        widget.user.name,
                      );
                      firestoreDb
                          .collection('inventory')
                          .doc(item.id)
                          .set(item.toMap());
                    });
                    notifyU(
                      u.email,
                      'inventory',
                      'Demirbaş Zimmetlendi',
                      '${item.name} sana zimmetlendi.',
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${item.name}, ${u.name} üzerine zimmetlendi.',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _badgeAssignDialog(BadgeModel badge) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: Text(
          '${badge.name} — Kime Ata?',
          style: const TextStyle(color: Colors.amber, fontSize: 15),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: users.map((u) {
              final has = userBadges.any(
                (ub) => ub.userEmail == u.email && ub.badgeId == badge.id,
              );
              return ListTile(
                leading: userAvatar(u, radius: 16),
                title: Text(
                  '[${u.code}] ${u.name}',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: has
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    if (has) {
                      removeBadge(u.email, badge.id);
                    } else {
                      assignBadge(u.email, badge.id);
                    }
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        has ? 'Rozet kaldırıldı.' : 'Rozet atandı!',
                      ),
                      backgroundColor: has ? Colors.orange : Colors.green,
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showAttendanceApprovalDialog(GameModel game) {
    final attenders =
        users.where((u) => game.statuses[u.email] == 'Geliyorum').toList();
    final selected = <String>{...game.approvedAttendees};
    if (game.approvedAttendees.isEmpty) {
      selected.addAll(attenders.map((u) => u.email));
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSt) => AlertDialog(
          backgroundColor: const Color(0xFF121212),
          title: Text(
            '${game.title} Katılımcıları',
            style: const TextStyle(color: Colors.amber, fontSize: 14),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: attenders.isEmpty
                ? const Text(
                    'Geliyorum diyen kimse yok.',
                    style: TextStyle(color: Colors.white54),
                  )
                : ListView(
                    shrinkWrap: true,
                    children: attenders.map((u) {
                      final isChecked = selected.contains(u.email);
                      return CheckboxListTile(
                        title: Text(
                          '[${u.code}] ${u.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        value: isChecked,
                        activeColor: Colors.amber,
                        checkColor: Colors.black,
                        onChanged: (v) {
                          setSt(() {
                            if (v == true) {
                              selected.add(u.email);
                            } else {
                              selected.remove(u.email);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'İPTAL',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  game.approvedAttendees = selected.toList();
                  game.isAttendanceApproved = true;

                  final wc = <String, int>{};
                  for (var email in selected) {
                    final w = game.weapons[email];
                    if (w != null && w.isNotEmpty) wc[w] = (wc[w] ?? 0) + 1;
                  }
                  final newSummary = GameSummaryModel(
                    id: uid(),
                    gameTitle: game.title,
                    gameDate: game.gameDate,
                    attendance: selected.length,
                    weaponCounts: wc,
                  );

                  final existingSummaryIndex = gameSummaries.indexWhere(
                    (s) => s.gameTitle == game.title,
                  );
                  if (existingSummaryIndex != -1) {
                    gameSummaries[existingSummaryIndex] = newSummary;
                  } else {
                    gameSummaries.insert(0, newSummary);
                  }

                  firestoreDb
                      .collection('games')
                      .doc(game.id)
                      .set(game.toMap());

                  for (var email in selected) {
                    checkAutoBadges(email);
                  }
                });
                Navigator.pop(ctx);
                widget.refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Katılımcılar onaylandı ve rozetler kontrol edildi!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('ONAYLA'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inp(String l) => InputDecoration(
        labelText: l,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        filled: true,
        fillColor: Colors.black,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.amber),
        ),
      );

  Widget _acc(String t, IconData i, List<Widget> c) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
        ),
        child: ExpansionTile(
          leading: Icon(i, color: Colors.amber, size: 22),
          title: Text(
            t,
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          iconColor: Colors.amber,
          collapsedIconColor: Colors.grey,
          childrenPadding: const EdgeInsets.all(16),
          children: c,
        ),
      );

  @override
  Widget build(BuildContext c) {
    // YÜKLEME KONTROLÜ
    if (users.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    final pendingUsers = users.where((u) => !u.isApproved).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: const Text(
          'YÖNETİM',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          notifBtn(c, widget.user, widget.refresh),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (pendingUsers.isNotEmpty)
              _acc(
                'ONAY BEKLEYEN KAYITLAR (${pendingUsers.length})',
                Icons.pending_actions,
                [
                  ...pendingUsers.map(
                    (u) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          userAvatar(u, radius: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${u.name} (${u.code})',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${u.email} • ${u.membershipType}',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 24,
                            ),
                            onPressed: () {
                              setState(() => u.isApproved = true);
                              firestoreDb
                                  .collection('users')
                                  .doc(u.email)
                                  .set(u.toMap());
                              notifyU(
                                u.email,
                                'game',
                                'Hesabın Onaylandı!',
                                '${u.name}, artık uygulamayı kullanabilirsin!',
                              );
                              widget.refresh();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${u.name} onaylandı!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: 24,
                            ),
                            onPressed: () {
                              setState(() => users.remove(u));
                              firestoreDb
                                  .collection('users')
                                  .doc(u.email)
                                  .delete();
                              widget.refresh();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${u.name} reddedildi.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            // GÜNCELLENMİŞ MAÇ SONU ONAY BÖLÜMÜ (Her zaman görünür)
            _acc(
              'MAÇ SONU KATILIMCI ONAYI',
              Icons.fact_check,
              [
                if (pastGames.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Onaylanacak geçmiş oyun bulunmuyor.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  )
                else
                  ...pastGames.map((g) {
                    final isApproved = g.isAttendanceApproved;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        g.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        '${fmtDT(g.gameDate)} • ${isApproved ? "Onaylandı" : "Onay Bekliyor"}',
                        style: TextStyle(
                          color: isApproved ? Colors.green : Colors.orange,
                          fontSize: 11,
                        ),
                      ),
                      trailing: Icon(
                        isApproved
                            ? Icons.check_circle
                            : Icons.arrow_forward_ios,
                        color: isApproved ? Colors.green : Colors.amber,
                        size: 18,
                      ),
                      onTap: isApproved
                          ? null
                          : () => _showAttendanceApprovalDialog(g),
                    );
                  }),
              ],
            ),

            _acc('YENİ OYUN OLUŞTUR', Icons.add_circle, [
              TextField(
                controller: _gameName,
                style: const TextStyle(color: Colors.white),
                decoration: _inp('Oyun Adı'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _scenarioCtrl,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: _inp('Oyun Senaryosu (Açıklama)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _locationCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inp('Oyun Konumu (örn: Ormanlık Alan, Eskişehir)'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _latCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inp('Enlem (örn: 39.766)'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _lngCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inp('Boylam (örn: 30.525)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final p = await _pickDT(init: _gameDT);
                  if (p != null) setState(() => _gameDT = p);
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
                        _gameDT == null
                            ? 'Oyun Tarihi & Saati'
                            : 'Oyun: ${fmtDT(_gameDT!)}',
                        style: TextStyle(
                          color:
                              _gameDT == null ? Colors.white54 : Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      const Icon(Icons.event, color: Colors.amber, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final p = await _pickDT(init: _surveyEndDT);
                  if (p != null) setState(() => _surveyEndDT = p);
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
                        _surveyEndDT == null
                            ? 'Anket Bitiş Tarihi & Saati'
                            : 'Anket Bitiş: ${fmtDT(_surveyEndDT!)}',
                        style: TextStyle(
                          color: _surveyEndDT == null
                              ? Colors.white54
                              : Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      const Icon(Icons.timer, color: Colors.amber, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KİMLER KATILABİLİR?',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _participationRestriction,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF121212),
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.amber, fontSize: 12),
                      items: restrictionOptions
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(restrictionLabel(r)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(
                        () => _participationRestriction = v ?? 'all',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KİMLER ANKETE KATILABİLİR?',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _surveyRestriction,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF121212),
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.amber, fontSize: 12),
                      items: restrictionOptions
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(restrictionLabel(r)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _surveyRestriction = v ?? 'all'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('KAYDET VE BİLDİRİM GÖNDER'),
                  onPressed: () {
                    if (_gameName.text.isEmpty ||
                        _gameDT == null ||
                        _surveyEndDT == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tüm alanları doldur!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      activeGame = GameModel(
                        id: uid(),
                        title: _gameName.text,
                        gameDate: _gameDT!,
                        surveyDeadline: _surveyEndDT!,
                        participationRestriction: _participationRestriction,
                        surveyRestriction: _surveyRestriction,
                        scenario: _scenarioCtrl.text,
                        location: _locationCtrl.text,
                        latitude: double.tryParse(_latCtrl.text),
                        longitude: double.tryParse(_lngCtrl.text),
                      );
                      for (var u in users) {
                        u.status = 'Belirsiz';
                      }
                      notifyAll(
                        'game',
                        'Yeni Oyun: ${_gameName.text}',
                        'Oyun: ${fmtDT(_gameDT!)}\nAnket bitiş: ${fmtDT(_surveyEndDT!)}',
                      );
                      firestoreDb
                          .collection('games')
                          .doc(activeGame!.id)
                          .set(activeGame!.toMap());
                    });
                    widget.refresh();
                    _gameName.clear();
                    _scenarioCtrl.clear();
                    _locationCtrl.clear();
                    _latCtrl.clear();
                    _lngCtrl.clear();
                    _gameDT = null;
                    _surveyEndDT = null;
                    _participationRestriction = 'all';
                    _surveyRestriction = 'all';
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Oyun oluşturuldu!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white12),
              const Text(
                'MEVCUT OYUNLARI SİL:',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
              if (activeGame != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Aktif: ${activeGame!.title}',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        firestoreDb
                            .collection('games')
                            .doc(activeGame!.id)
                            .delete();
                        activeGame = null;
                      });
                      widget.refresh();
                    },
                  ),
                ),
              ...pastGames.map((g) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Geçmiş: ${g.title}',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          firestoreDb.collection('games').doc(g.id).delete();
                          pastGames.remove(g);
                        });
                        widget.refresh();
                      },
                    ),
                  )),
            ]),
            _acc('YENİ ANKET OLUŞTUR', Icons.how_to_vote, [
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('ANKET FORMU AÇ'),
                  onPressed: () async {
                    await Navigator.push(
                      c,
                      MaterialPageRoute(
                        builder: (_) => const SurveyCreateScreen(),
                      ),
                    );
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 10),
              if (surveys.isNotEmpty) ...[
                const Text(
                  'MEVCUT ANKETLER (Silmek için çöp kutusuna bas):',
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
                ...surveys.map(
                  (s) => Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Bitiş: ${fmtDT(s.endDate)}',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 20),
                          onPressed: () {
                            setState(() {
                              firestoreDb
                                  .collection('surveys')
                                  .doc(s.id)
                                  .delete();
                              surveys.remove(s);
                            });
                            widget.refresh();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ]),
            _acc('DUYURU OLUŞTUR', Icons.campaign, [
              TextField(
                controller: _annTitle,
                style: const TextStyle(color: Colors.white),
                decoration: _inp('Duyuru Başlığı'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _annContent,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _inp('Duyuru İçeriği'),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('DUYURU YAYINLA'),
                  onPressed: () {
                    if (_annTitle.text.isEmpty || _annContent.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Başlık ve içerik zorunlu!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      final ann = AnnouncementModel(
                        id: uid(),
                        title: _annTitle.text,
                        content: _annContent.text,
                        adminEmail: widget.user.email,
                        createdAt: DateTime.now(),
                      );
                      announcements.insert(0, ann);
                      firestoreDb
                          .collection('announcements')
                          .doc(ann.id)
                          .set(ann.toMap());
                      notifyAll(
                        'game',
                        'Yeni Duyuru: ${_annTitle.text}',
                        _annContent.text,
                      );
                    });
                    widget.refresh();
                    _annTitle.clear();
                    _annContent.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Duyuru yayınlandı!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white12),
              const Text(
                'YAYINDAKİ DUYURULAR (Silmek için çöp kutusuna bas):',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
              ...announcements.map((ann) => Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: ListTile(
                      title: Text(ann.title,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                      subtitle: Text(fmtDT(ann.createdAt),
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 10)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 20),
                        onPressed: () {
                          setState(() {
                            firestoreDb
                                .collection('announcements')
                                .doc(ann.id)
                                .delete();
                            announcements.remove(ann);
                          });
                          widget.refresh();
                        },
                      ),
                    ),
                  )),
            ]),
            _acc('KADRO, YÖNETİCİ VE KAPTAN ATAMA', Icons.assignment_ind, [
              ...users.map(
                (u) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          userAvatar(u, radius: 12),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '[${u.code}] ${u.name}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                                if (!u.isApproved)
                                  const Text(
                                    'Onay bekliyor',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 9,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (u.email != widget.user.email)
                            IconButton(
                              icon: Icon(
                                u.isAdmin
                                    ? Icons.admin_panel_settings
                                    : Icons.person_outline,
                                color: u.isAdmin ? Colors.amber : Colors.grey,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() => u.isAdmin = !u.isAdmin);
                                firestoreDb
                                    .collection('users')
                                    .doc(u.email)
                                    .set(u.toMap());
                                widget.refresh();
                              },
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(
                                Icons.shield,
                                color: Colors.amber,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Dropdown'ları sığdırmak için Wrap kullanıyoruz
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          DropdownButton<String>(
                            value: u.membershipType,
                            dropdownColor: const Color(0xFF121212),
                            underline: const SizedBox(),
                            style: const TextStyle(
                              color: Colors.cyan,
                              fontSize: 10,
                            ),
                            items: membershipTypes
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() => u.membershipType = v ?? 'Acemi');
                              firestoreDb
                                  .collection('users')
                                  .doc(u.email)
                                  .set(u.toMap());
                              widget.refresh();
                            },
                          ),
                          DropdownButton<String>(
                            value: u.squad == 'Sarı Takım' ||
                                    u.squad == 'Mavi Takım'
                                ? 'Atanmadı'
                                : u.squad,
                            dropdownColor: const Color(0xFF121212),
                            underline: const SizedBox(),
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 10,
                            ),
                            items: squadOptions
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() => u.squad = v ?? 'Atanmadı');
                              firestoreDb
                                  .collection('users')
                                  .doc(u.email)
                                  .set(u.toMap());
                              widget.refresh();
                            },
                          ),
                          DropdownButton<String>(
                            value: u.squadRole,
                            dropdownColor: const Color(0xFF121212),
                            underline: const SizedBox(),
                            style: const TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 10,
                            ),
                            items: squadRoleOptions
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() => u.squadRole = v ?? 'Yok');
                              firestoreDb
                                  .collection('users')
                                  .doc(u.email)
                                  .set(u.toMap());
                              notifyU(u.email, 'team', 'Rol Güncellendi',
                                  'Takım içi rolünüz "$v" olarak güncellendi.');
                              widget.refresh();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: Colors.white12),
              if (activeGame != null &&
                  !activeGame!.isSurveyOpen &&
                  !activeGame!.teamsAssigned)
                SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.groups, size: 18),
                    label: const Text('TAKIM ATAMASINI YAP'),
                    onPressed: () async {
                      await Navigator.push(
                        c,
                        MaterialPageRoute(
                          builder: (_) =>
                              TeamAssignmentScreen(game: activeGame!),
                        ),
                      );
                      widget.refresh();
                      setState(() {});
                    },
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Takım ataması, oyun anketi kapandıktan sonra aktif olur.',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
            ]),
            _acc('DEMİRBAŞ EKLE / ZİMMET', Icons.inventory_2, [
              TextField(
                controller: _invName,
                style: const TextStyle(color: Colors.white),
                decoration: _inp('Eşya Adı'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _invCat,
                style: const TextStyle(color: Colors.white),
                decoration: _inp('Kategori'),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('DEMİRBAŞ EKLE'),
                  onPressed: () {
                    if (_invName.text.isEmpty) return;
                    setState(() {
                      final inv = InventoryModel(
                        id: uid(),
                        name: _invName.text,
                        category: _invCat.text.isEmpty ? 'Diğer' : _invCat.text,
                      );
                      inventoryList.add(inv);
                      firestoreDb
                          .collection('inventory')
                          .doc(inv.id)
                          .set(inv.toMap());
                    });
                    _invName.clear();
                    _invCat.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demirbaş eklendi!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              // MEVCUT EŞYALARI BULUTA YÜKLE BUTONU
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('MEVCUT EŞYALARI BULUTA YÜKLE'),
                  onPressed: () async {
                    for (var item in inventoryList) {
                      await firestoreDb
                          .collection('inventory')
                          .doc(item.id)
                          .set(item.toMap());
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Tüm eşyalar Firebase\'e yüklendi!'),
                          backgroundColor: Colors.green),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              ...inventoryList.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.owner == '-' ? Icons.warehouse : Icons.person,
                        color: item.owner == '-' ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              item.category,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.owner == '-'
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.owner == '-'
                              ? 'Depoda'
                              : users
                                  .firstWhere(
                                    (u) => u.email == item.owner,
                                    orElse: () => users[0],
                                  )
                                  .name,
                          style: TextStyle(
                            color:
                                item.owner == '-' ? Colors.green : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.amber,
                          size: 18,
                        ),
                        onPressed: () => _zimmetDialog(item),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 18,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF121212),
                              title: const Text('Demirbaşı Sil',
                                  style: TextStyle(
                                      color: Colors.amber, fontSize: 15)),
                              content: Text(
                                  '${item.name} eşyasını silmek istediğinize emin misiniz?',
                                  style:
                                      const TextStyle(color: Colors.white70)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('İPTAL',
                                      style: TextStyle(color: Colors.white54)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      firestoreDb
                                          .collection('inventory')
                                          .doc(item.id)
                                          .delete();
                                      inventoryList
                                          .removeWhere((i) => i.id == item.id);
                                    });
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Demirbaş silindi!'),
                                          backgroundColor: Colors.green),
                                    );
                                  },
                                  child: const Text('SİL',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => Navigator.push(
                  c,
                  MaterialPageRoute(builder: (_) => const ZimmetLogScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: Colors.blue, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Zimmet Geçmişi',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        '${zimmetLogs.length} kayıt',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.blue,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            _acc('ROZET YÖNETİMİ', Icons.workspace_premium, [
              const Text(
                'YENİ ROZET OLUŞTUR',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _badgeName,
                style: const TextStyle(color: Colors.white),
                decoration: _inp('Rozet Adı'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _badgeDesc,
                style: const TextStyle(color: Colors.white),
                decoration: _inp('Açıklama'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _badgeIcon,
                      dropdownColor: const Color(0xFF121212),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: _inp('İkon'),
                      items: [
                        'star',
                        'gps_fixed',
                        'favorite',
                        'person_add',
                        'military_tech',
                        'shield',
                        'bolt',
                        'whatshot',
                        'emoji_events',
                      ]
                          .map(
                            (i) => DropdownMenuItem(
                              value: i,
                              child: Row(
                                children: [
                                  Icon(
                                    badgeIcon(i),
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    i,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _badgeIcon = v ?? 'star'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _badgeColor,
                      dropdownColor: const Color(0xFF121212),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: _inp('Renk'),
                      items:
                          ['amber', 'green', 'blue', 'red', 'purple', 'orange']
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: badgeColor(c),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        c,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (v) =>
                          setState(() => _badgeColor = v ?? 'amber'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _badgeAutoRule,
                dropdownColor: const Color(0xFF121212),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: _inp('Otomatik Atama Kuralı'),
                items: [
                  'none',
                  'first_game',
                  'veteran_10',
                  'sniper_master',
                  'loyal',
                ]
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(
                          r,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _badgeAutoRule = v ?? 'none'),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('YENİ ROZET OLUŞTUR'),
                  onPressed: () {
                    if (_badgeName.text.isEmpty) return;
                    setState(() {
                      final b = BadgeModel(
                        id: uid(),
                        name: _badgeName.text,
                        description: _badgeDesc.text,
                        iconName: _badgeIcon,
                        color: _badgeColor,
                        autoRule: _badgeAutoRule,
                      );
                      badges.add(b);
                      firestoreDb.collection('badges').doc(b.id).set(b.toMap());
                    });
                    _badgeName.clear();
                    _badgeDesc.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rozet oluşturuldu!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'MEVCUT ROZETLER (atamak için tıkla)',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...badges.map((b) {
                final col = badgeColor(b.color);
                final assignCount =
                    userBadges.where((ub) => ub.badgeId == b.id).length;
                return InkWell(
                  onTap: () => _badgeAssignDialog(b),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: col.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: col.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            badgeIcon(b.iconName),
                            color: col,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    b.name,
                                    style: TextStyle(
                                      color: col,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (b.autoRule != 'none') ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white12,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: const Text(
                                        'Oto',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                b.description,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$assignCount',
                              style: TextStyle(
                                color: col,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'kişide',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 16,
                          ),
                          onPressed: () {
                            setState(() {
                              userBadges.removeWhere(
                                (ub) => ub.badgeId == b.id,
                              );
                              badges.remove(b);
                            });
                            firestoreDb.collection('badges').doc(b.id).delete();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ]),
          ],
        ),
      ),
    );
  }
}
