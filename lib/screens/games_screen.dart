import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/user_model.dart';
import '../models/game_model.dart';
import '../models/survey_model.dart';
import '../services/app_data.dart';
import '../services/helpers.dart';
import '../widgets/common_widgets.dart';
import 'survey_screen.dart';
import 'team_assignment_screen.dart';
import 'game_summary_screen.dart';

class GamesScreen extends StatelessWidget {
  final UserModel user;
  final VoidCallback refresh;
  const GamesScreen({super.key, required this.user, required this.refresh});

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
          'OYUNLAR & ANKETLER',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [notifBtn(c, user, refresh), const SizedBox(width: 4)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.amber.withValues(alpha: 0.4),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const SizedBox(height: 10),
            if (activeGame == null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Center(
                  child: Text(
                    'Şu anda aktif oyun yok.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            activeGame!.title,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: activeGame!.isSurveyOpen
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: activeGame!.isSurveyOpen
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          child: Text(
                            activeGame!.isSurveyOpen
                                ? 'ANKET AÇIK'
                                : (activeGame!.teamsAssigned
                                    ? 'TAMAMLANDI'
                                    : 'ANKET KAPALI'),
                            style: TextStyle(
                              color: activeGame!.isSurveyOpen
                                  ? Colors.green
                                  : (activeGame!.teamsAssigned
                                      ? Colors.green
                                      : Colors.orange),
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
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.white54,
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _countBadge(
                          'Geliyor',
                          activeGame!.statuses.values
                              .where((s) => s == 'Geliyorum')
                              .length,
                          Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _countBadge(
                          'Gelmiyor',
                          activeGame!.statuses.values
                              .where((s) => s == 'Gelmiyorum')
                              .length,
                          Colors.red,
                        ),
                        const SizedBox(width: 8),
                        _countBadge(
                          'Belirsiz',
                          activeGame!.statuses.values
                              .where((s) => s == 'Belirsiz')
                              .length,
                          Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ankete katılmak için Anasayfa\'ya gidin.',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => Navigator.push(
                        c,
                        MaterialPageRoute(
                          builder: (_) => GameDetailScreen(
                            user: user,
                            game: activeGame!,
                            refresh: refresh,
                          ),
                        ),
                      ).then((_) => refresh()),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.visibility,
                              color: Colors.amber,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Detayları Gör',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
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
            if (surveys
                .where((s) => DateTime.now().isBefore(s.endDate))
                .isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Center(
                  child: Text(
                    'Şu anda aktif anket yok.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else
              ...surveys
                  .where((s) => DateTime.now().isBefore(s.endDate))
                  .map((s) => _surveyStatusCard(c, s)),
            const SizedBox(height: 24),
            const Text(
              'GEÇMİŞ OYUNLAR',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            if (pastGames.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Center(
                  child: Text(
                    'Henüz geçmiş oyun yok.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else
              ...pastGames.map((g) {
                final summary =
                    gameSummaries.where((s) => s.gameTitle == g.title).toList();
                return InkWell(
                  onTap: () => Navigator.push(
                    c,
                    MaterialPageRoute(
                      builder: (_) => GameSummaryDetailScreen(
                        game: g,
                        summary: summary.isNotEmpty ? summary.first : null,
                      ),
                    ),
                  ).then((_) => refresh()),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
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
                          children: [
                            const Icon(
                              Icons.history,
                              color: Colors.white54,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    g.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    fmtDT(g.gameDate),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white38,
                            ),
                          ],
                        ),
                        if (summary.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.people,
                                  color: Colors.amber,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${summary.first.attendance} katılım',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.gps_fixed,
                                  color: Colors.amber,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${summary.first.weaponCounts.length} silah türü',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 24),
            const Text(
              'KAPANMIŞ ANKETLER',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            if (surveys
                .where((s) => !DateTime.now().isBefore(s.endDate))
                .isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Center(
                  child: Text(
                    'Henüz kapanmış anket yok.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else
              ...surveys
                  .where((s) => !DateTime.now().isBefore(s.endDate))
                  .map((s) => _surveyStatusCard(c, s)),
          ],
        ),
      ),
    );
  }

  Widget _countBadge(String l, int cnt, Color col) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: col.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: col.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Text(
                '$cnt',
                style: TextStyle(
                  color: col,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(l, style: TextStyle(color: col, fontSize: 9)),
            ],
          ),
        ),
      );

  Widget _surveyStatusCard(BuildContext c, SurveyModel s) {
    final isActive = DateTime.now().isBefore(s.endDate);
    final left = s.endDate.difference(DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? Colors.blue.withValues(alpha: 0.5) : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isActive ? Icons.how_to_vote : Icons.lock,
                color: isActive ? Colors.blue : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 8),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.blue.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isActive ? 'AKTİF' : 'KAPALI',
                  style: TextStyle(
                    color: isActive ? Colors.blue : Colors.grey,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.white54, size: 12),
              const SizedBox(width: 4),
              Text(
                isActive
                    ? 'Kalan: ${fmtDur(left)}'
                    : 'Bitiş: ${fmtDT(s.endDate)}',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
              const Spacer(),
              Text(
                '${s.votes.length} oy',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => Navigator.push(
              c,
              MaterialPageRoute(builder: (_) => SurveysScreen(user: user)),
            ).then((_) => refresh()),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.4)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility, color: Colors.blue, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Anket Detayı',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// OYUN DETAY EKRANI (Koordinat destekli)
// ============================================================
class GameDetailScreen extends StatefulWidget {
  final UserModel user;
  final GameModel game;
  final VoidCallback refresh;
  final bool isPast;
  const GameDetailScreen({
    super.key,
    required this.user,
    required this.game,
    required this.refresh,
    this.isPast = false,
  });
  @override
  State<GameDetailScreen> createState() => _GDS();
}

class _GDS extends State<GameDetailScreen> {
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

  // YENİ EKLENEN: Maç Sonu Onay Diyaloğu
  void _showAttendanceApprovalDialog(BuildContext context) {
    final votedYes = widget.game.statuses.entries
        .where((e) => e.value == 'Geliyorum')
        .map((e) => e.key)
        .toList();

    final List<String> selected = List.from(widget.game.approvedAttendees);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF121212),
            title: const Text("Kimler Gerçekten Geldi?",
                style: TextStyle(color: Colors.amber)),
            content: SizedBox(
              width: double.maxFinite,
              child: votedYes.isEmpty
                  ? const Text("Geliyorum diyen kimse yok.",
                      style: TextStyle(color: Colors.white54))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: votedYes.length,
                      itemBuilder: (c, i) {
                        final email = votedYes[i];
                        final u = users.firstWhere(
                            (user) => user.email == email,
                            orElse: () => users[0]);
                        return CheckboxListTile(
                          title: Text(u.name,
                              style: const TextStyle(color: Colors.white)),
                          value: selected.contains(email),
                          activeColor: Colors.amber,
                          onChanged: (val) {
                            setDialogState(() {
                              if (val == true)
                                selected.add(email);
                              else
                                selected.remove(email);
                            });
                          },
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("İptal",
                    style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () {
                  setState(() {
                    widget.game.approvedAttendees = selected;
                    widget.game.isAttendanceApproved = true;

                    // Seçilenlere otomatik rozet kontrolü yap
                    for (var email in selected) {
                      checkAutoBadges(email);
                    }
                    // Oyun özetini (istatistikleri) oluştur
                    createGameSummary(widget.game);

                    // Firebase'e kaydet
                    firestoreDb.collection('games').doc(widget.game.id).update({
                      'approvedAttendees': selected,
                      'isAttendanceApproved': true,
                    });
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Katılımcılar onaylandı ve rozetler kontrol edildi.")),
                  );
                },
                child:
                    const Text("Onayla", style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext c) {
    final g = widget.game;
    final attending =
        users.where((u) => g.statuses[u.email] == 'Geliyorum').toList();
    final notAttending =
        users.where((u) => g.statuses[u.email] == 'Gelmiyorum').toList();
    final unsure = users
        .where(
          (u) =>
              g.statuses[u.email] == 'Belirsiz' || g.statuses[u.email] == null,
        )
        .toList();
    final total = users.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: Text(
          g.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  _row(Icons.calendar_today, 'Tarih', fmtDT(g.gameDate)),
                  const Divider(color: Colors.white12),
                  if (g.location.isNotEmpty || g.latitude != null) ...[
                    InkWell(
                      onTap: () async {
                        Uri? url;
                        if (g.latitude != null && g.longitude != null) {
                          url = Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=${g.latitude},${g.longitude}',
                          );
                        } else if (g.location.isNotEmpty) {
                          final query = Uri.encodeComponent(g.location);
                          url = Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=$query',
                          );
                        }

                        if (url != null) {
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            // İlk deneme başarısızsa tarayıcıda açmayı dene
                            try {
                              await launchUrl(
                                url,
                                mode: LaunchMode.platformDefault,
                              );
                            } catch (e) {
                              if (c.mounted) {
                                ScaffoldMessenger.of(c).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Harita açılamadı. Tarayıcıda deneyin: $url',
                                    ),
                                    backgroundColor: Colors.orange,
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              }
                            }
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              flex: 2,
                              child: Text(
                                'Konum',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: Text(
                                g.latitude != null && g.longitude != null
                                    ? '${g.latitude}, ${g.longitude}'
                                    : g.location,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.map, color: Colors.blue, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white12),
                  ],
                  _row(
                    Icons.people,
                    'Toplam Katılım',
                    '${attending.length} / $total',
                  ),
                  const Divider(color: Colors.white12),
                  _row(
                    Icons.lock_clock,
                    'Anket Bitiş',
                    fmtDT(g.surveyDeadline),
                  ),
                  const Divider(color: Colors.white12),
                  _row(Icons.info, 'Durum', g.isSurveyOpen ? 'Açık' : 'Kapalı'),
                  const Divider(color: Colors.white12),
                  _row(
                    Icons.group_add,
                    'Katılım',
                    restrictionLabel(g.participationRestriction),
                  ),
                  const Divider(color: Colors.white12),
                  _row(
                    Icons.how_to_vote,
                    'Anket',
                    restrictionLabel(g.surveyRestriction),
                  ),
                ],
              ),
            ),
            if (g.scenario.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.description, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'OYUN SENARYOSU',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      g.scenario,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (g.isSurveyOpen) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    const Text(
                      'Anket kapanmasına',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    const Spacer(),
                    Text(
                      fmtDur(
                        g.surveyDeadline.difference(DateTime.now()).isNegative
                            ? Duration.zero
                            : g.surveyDeadline.difference(DateTime.now()),
                      ),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'KATILIM ORANLARI',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _sr('Geliyorum', attending.length, total, Colors.green),
                  const SizedBox(height: 8),
                  _sr('Gelmiyorum', notAttending.length, total, Colors.red),
                  const SizedBox(height: 8),
                  _sr('Belirsiz', unsure.length, total, Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _pe('GELİYOR', attending, Colors.green),
            const SizedBox(height: 6),
            _pe('GELMİYOR', notAttending, Colors.red),
            const SizedBox(height: 6),
            _pe('BELİRSİZ', unsure, Colors.orange),
            const SizedBox(height: 16),

            // YENİ EKLENEN: Maç Sonu Onay Butonu
            if (widget.isPast && widget.user.isAdmin && !g.isAttendanceApproved)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.fact_check),
                  label: const Text(
                    'MAÇ SONU KATILIMCILARI ONAYLA',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _showAttendanceApprovalDialog(c),
                ),
              ),

            if (g.isAttendanceApproved)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.green.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Katılımcılar onaylandı, rozetler dağıtıldı.',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),
            if (!g.teamsAssigned)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.5),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Takım atamaları henüz yapılmadı.',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              const Text(
                'TAKIMLAR',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              _ts('SARI TAKIM', Colors.amber, 'Sarı', attending, g),
              const SizedBox(height: 12),
              _ts('MAVİ TAKIM', Colors.blue, 'Mavi', attending, g),
            ],
            if (widget.user.isAdmin &&
                !widget.isPast &&
                !g.isSurveyOpen &&
                !g.teamsAssigned)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    'TAKIM ATAMASINI YAP',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      c,
                      MaterialPageRoute(
                        builder: (_) => TeamAssignmentScreen(game: g),
                      ),
                    );
                    widget.refresh();
                    setState(() {});
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

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

  Widget _pe(String t, List<UserModel> us, Color col) {
    if (us.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: col.withValues(alpha: 0.4)),
      ),
      child: ExpansionTile(
        iconColor: col,
        collapsedIconColor: col,
        title: Row(
          children: [
            Icon(Icons.people, color: col, size: 16),
            const SizedBox(width: 8),
            Text(
              t,
              style: TextStyle(
                color: col,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Text(
              '${us.length}',
              style: TextStyle(
                color: col,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        children: us
            .map(
              (u) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    userAvatar(u, radius: 10),
                    const SizedBox(width: 6),
                    Text(
                      '[${u.code}] ',
                      style: TextStyle(
                        color: col,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        u.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (widget.game.weapons[u.email] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.game.weapons[u.email]!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _ts(
    String t,
    Color col,
    String key,
    List<UserModel> att,
    GameModel g,
  ) {
    final tp = att.where((u) => g.assignments[u.email] == key).toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: col.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: col, size: 20),
              const SizedBox(width: 8),
              Text(
                t,
                style: TextStyle(
                  color: col,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '${tp.length} kişi',
                style: TextStyle(color: col, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (tp.isEmpty)
            const Text(
              'Atama yapılmadı',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            )
          else
            ...tp.map((u) {
              final w = g.weapons[u.email] ?? '-';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    userAvatar(u, radius: 10),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '[${u.code}] ${u.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        w,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    if (widget.user.isAdmin && widget.isPast)
                      IconButton(
                        icon: const Icon(
                          Icons.person_off,
                          color: Colors.red,
                          size: 16,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          // YENİ: noShow işaretini Firebase'e kaydet
                          setState(() => g.noShows.add(u.email));
                          firestoreDb.collection('games').doc(g.id).update({
                            'noShows': g.noShows,
                          });
                        },
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _row(IconData i, String l, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(i, color: Colors.amber, size: 18),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Text(
                l,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Text(
                v,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}
