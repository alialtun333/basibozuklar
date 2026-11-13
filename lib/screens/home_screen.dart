import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/app_data.dart';
import '../services/helpers.dart';
import '../widgets/common_widgets.dart';
import 'survey_screen.dart';
import 'inventory_screen.dart';
import 'info_screen.dart';
import 'announcements_screen.dart'; // YENİ EKLENDİ

class HomeScreen extends StatefulWidget {
  final UserModel user;
  final VoidCallback refresh;
  const HomeScreen({super.key, required this.user, required this.refresh});
  @override
  State<HomeScreen> createState() => _HomeS();
}

class _HomeS extends State<HomeScreen> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    // Sadece sayaçların (geri sayım vb.) her saniye güncellenmesi için Timer
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
    // ============================================================
    // YÜKLEME KONTROLÜ: Veriler (Stream'den) henüz gelmediyse
    // ============================================================
    if (users.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.amber),
              SizedBox(height: 16),
              Text(
                'Veriler yükleniyor...',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    // Değişkenlerin hesaplanması
    final att = activeGame != null
        ? activeGame!.statuses.values.where((s) => s == 'Geliyorum').length
        : 0;
    final no = activeGame != null
        ? activeGame!.statuses.values.where((s) => s == 'Gelmiyorum').length
        : 0;
    final un = activeGame != null
        ? activeGame!.statuses.values.where((s) => s == 'Belirsiz').length
        : 0;
    final tot = att + no + un;

    final activeS =
        surveys.where((s) => DateTime.now().isBefore(s.endDate)).toList();
    final activeAnns = getActiveAnnouncements();
    final myStatus = activeGame?.statuses[widget.user.email] ?? 'Belirsiz';

    final canJoinGame = activeGame != null &&
        userCanJoin(widget.user, activeGame!.participationRestriction);
    final canJoinSurvey = activeGame != null &&
        userCanJoin(widget.user, activeGame!.surveyRestriction);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: const Text(
          'BAŞIBOZUKLAR',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          // Kullanıcı Kodu Göstergesi
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: Text(
                widget.user.code,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          notifBtn(c, widget.user, widget.refresh),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hoş geldin, ${widget.user.name}.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Üyelik: ${widget.user.membershipType}',
              style: const TextStyle(color: Colors.cyan, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // ============================================================
            // DUYURULAR BÖLÜMÜ
            // ============================================================
            if (activeAnns.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DUYURULAR',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  // YENİ EKLENEN BUTON
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        c,
                        MaterialPageRoute(
                          builder: (_) =>
                              AnnouncementsScreen(user: widget.user),
                        ),
                      );
                    },
                    child: const Text(
                      'TÜMÜNÜ GÖR',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...activeAnns.map(
                (a) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1500),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.campaign,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              a.title,
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.content,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        fmtDT(a.createdAt),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              // Eğer hiç aktif duyuru yoksa yine de tüm duyurulara gidebilmek için buton
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('DUYURULAR',
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        c,
                        MaterialPageRoute(
                            builder: (_) =>
                                AnnouncementsScreen(user: widget.user)));
                  },
                  child: const Text('GEÇMİŞ DUYURULAR',
                      style: TextStyle(color: Colors.white54, fontSize: 10)),
                ),
              ]),
              const SizedBox(height: 10),
            ],

            // ============================================================
            // AKTİF OYUN BÖLÜMÜ
            // ============================================================
            if (activeGame != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'AKTİF OYUN',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Text(
                            '$att Operatör',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activeGame!.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Tarih
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          fmtDT(activeGame!.gameDate),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    // Konum (Eğer girilmişse)
                    if (activeGame!.location.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              activeGame!.location,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Senaryo (Eğer girilmişse)
                    if (activeGame!.scenario.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Senaryo: ${activeGame!.scenario}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Anket Katılım Alanı
                    if (activeGame!.isSurveyOpen) ...[
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white12, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.lock_clock,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Anket Kapanmasına',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            fmtDur(
                              activeGame!.surveyDeadline
                                      .difference(DateTime.now())
                                      .isNegative
                                  ? Duration.zero
                                  : activeGame!.surveyDeadline.difference(
                                      DateTime.now(),
                                    ),
                            ),
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _sr('Geliyorum', att, tot, Colors.green),
                      const SizedBox(height: 6),
                      _sr('Gelmiyorum', no, tot, Colors.red),
                      const SizedBox(height: 6),
                      _sr('Belirsiz', un, tot, Colors.orange),
                      const SizedBox(height: 12),

                      // Katılım Butonu ve Kısıtlama Kontrolü
                      if (!canJoinGame)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.block, color: Colors.red, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Bu oyuna katılım yetkiniz bulunmamaktadır.',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (!canJoinSurvey)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lock,
                                color: Colors.orange,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Bu ankete katılma yetkiniz yok. (${restrictionLabel(activeGame!.surveyRestriction)})',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.how_to_vote, size: 20),
                            label: Text(
                              myStatus == 'Belirsiz'
                                  ? 'ANKETE KATIL'
                                  : 'DURUMUM: $myStatus (DEĞİŞTİR)',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                c,
                                MaterialPageRoute(
                                  builder: (_) => SurveyFlowScreen(
                                    user: widget.user,
                                    game: activeGame!,
                                  ),
                                ),
                              );
                              widget.refresh();
                              setState(() {});
                            },
                          ),
                        ),
                      const SizedBox(height: 10),
                      _pl('GELİYOR', 'Geliyorum', Colors.green),
                      _pl('GELMİYOR', 'Gelmiyorum', Colors.red),
                      _pl('BELİRSİZ', 'Belirsiz', Colors.orange),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ============================================================
            // AKTİF ANKETLER BÖLÜMÜ
            // ============================================================
            if (activeS.isNotEmpty) ...[
              const Text(
                'AKTİF ANKETLER',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              ...activeS.map((s) {
                final left = s.endDate.difference(DateTime.now());
                return InkWell(
                  onTap: () => Navigator.push(
                    c,
                    MaterialPageRoute(
                      builder: (_) => SurveysScreen(user: widget.user),
                    ),
                  ).then((_) => widget.refresh()),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.how_to_vote,
                              color: Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                s.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer,
                              color: Colors.red,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              fmtDur(left),
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${s.votes.length} oy',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // ============================================================
            // HIZLI ERİŞİM
            // ============================================================
            if (!isEtkinlikPlayer(widget.user)) ...[
              const Text(
                'HIZLI ERİŞİM',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _qt(
                    Icons.how_to_vote,
                    'Anketler',
                    () => Navigator.push(
                      c,
                      MaterialPageRoute(
                        builder: (_) => SurveysScreen(user: widget.user),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _qt(
                    Icons.inventory_2,
                    'Envanter',
                    () => Navigator.push(
                      c,
                      MaterialPageRoute(
                        builder: (_) => const InventoryScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _qt(
                    Icons.menu_book,
                    'Bilgi',
                    () => Navigator.push(
                      c,
                      MaterialPageRoute(builder: (_) => const InfoScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // İlerleme Çubuğu Widget'ı
  Widget _sr(String l, int cnt, int tot, Color col) {
    final p = tot == 0 ? 0.0 : cnt / tot;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: col, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              l,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const Spacer(),
            Text(
              '$cnt (%${(p * 100).toStringAsFixed(0)})',
              style: TextStyle(
                color: col,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: p,
            minHeight: 5,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(col),
          ),
        ),
      ],
    );
  }

  // Katılımcı Listesi Widget'ı
  Widget _pl(String t, String st, Color col) {
    if (activeGame == null) return const SizedBox.shrink();
    final us = users.where((u) => activeGame!.statuses[u.email] == st).toList();
    if (us.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      iconColor: col,
      collapsedIconColor: col,
      title: Row(
        children: [
          Text(
            t,
            style: TextStyle(
              color: col,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Text('(${us.length})', style: TextStyle(color: col, fontSize: 10)),
        ],
      ),
      children: us
          .map(
            (u) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  userAvatar(u, radius: 10),
                  const SizedBox(width: 6),
                  Text(
                    '[${u.code}] ${u.name}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      u.membershipType,
                      style: const TextStyle(color: Colors.cyan, fontSize: 8),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // Hızlı Erişim Butonu Widget'ı
  Widget _qt(IconData ic, String l, VoidCallback fn) => Expanded(
        child: InkWell(
          onTap: fn,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Icon(ic, color: Colors.amber, size: 28),
                const SizedBox(height: 6),
                Text(
                  l,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
