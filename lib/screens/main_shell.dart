import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/app_data.dart';
import '../services/helpers.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';
import 'team_screen.dart';
import 'games_screen.dart';
import 'profile_screen.dart';
import 'admin_screen.dart';
import 'rules_screen.dart';
import 'messages_screen.dart';
import 'auth_screen.dart';

class Shell extends StatefulWidget {
  final UserModel user;
  const Shell({super.key, required this.user});
  @override
  State<Shell> createState() => _ShellS();
}

class _ShellS extends State<Shell> {
  int _i = 0;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    if (!widget.user.isApproved) return _pendingScreen(c);
    if (isEtkinlikPlayer(widget.user)) return _etkinlikShell(c);

    final adm = widget.user.isAdmin;
    final un = unreadMsg(widget.user.email);
    final pages = <Widget>[
      HomeScreen(user: widget.user, refresh: () => setState(() {})),
      TeamScreen(user: widget.user, refresh: () => setState(() {})),
      GamesScreen(user: widget.user, refresh: () => setState(() {})),
      ProfileScreen(user: widget.user, refresh: () => setState(() {})),
      if (adm) AdminScreen(user: widget.user, refresh: () => setState(() {})),
      RulesScreen(user: widget.user, refresh: () => setState(() {})),
    ];
    if (_i >= pages.length) _i = 0;

    return Scaffold(
      body: pages[_i],
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.amber.withValues(alpha: 0.85),
        onPressed: () => _showMessagePicker(c),
        child: Stack(
          children: [
            const Icon(Icons.message, color: Colors.black, size: 22),
            if (un > 0)
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$un',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _nv(Icons.home, 'Anasayfa', 0, null),
                _nv(Icons.group, 'Takım', 1, null),
                _nv(Icons.gps_fixed, 'Oyunlar', 2, null),
                _nv(Icons.person, 'Profil', 3, null),
                if (adm) _nv(Icons.admin_panel_settings, 'Yönetim', 4, null),
                _nv(Icons.menu_book, 'Kurallar', adm ? 5 : 4, null),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _etkinlikShell(BuildContext c) {
    final pages = <Widget>[
      HomeScreen(user: widget.user, refresh: () => setState(() {})),
      RulesScreen(user: widget.user, refresh: () => setState(() {})),
    ];
    if (_i >= pages.length) _i = 0;
    return Scaffold(
      body: pages[_i],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _nv(Icons.home, 'Anasayfa', 0, null),
                _nv(Icons.menu_book, 'Kurallar', 1, null),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _nv(IconData ic, String l, int i, int? b) {
    final act = _i == i;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _i = i),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Icon(ic, color: act ? Colors.amber : Colors.grey, size: 20),
                  if (b != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$b',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                l,
                style: TextStyle(
                  color: act ? Colors.amber : Colors.grey,
                  fontSize: 9,
                  fontWeight: act ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessagePicker(BuildContext c) {
    final others = users.where((u) => u.email != widget.user.email).toList();

    showModalBottomSheet(
      context: c,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (ctx2, scrollCtrl) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.message, color: Colors.amber, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Kime Mesaj Gönderelim?',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        c,
                        MaterialPageRoute(
                          builder: (_) => MessagesScreen(user: widget.user),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    icon: const Icon(
                      Icons.list,
                      color: Colors.white54,
                      size: 16,
                    ),
                    label: const Text(
                      'Tüm Sohbetler',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(12),
                itemCount: others.length,
                itemBuilder: (c2, i) {
                  final u = others[i];
                  final lastMsg = messages
                      .where(
                        (m) =>
                            (m.fromEmail == widget.user.email &&
                                m.toEmail == u.email) ||
                            (m.fromEmail == u.email &&
                                m.toEmail == widget.user.email),
                      )
                      .toList();
                  final unread = messages
                      .where(
                        (m) =>
                            m.fromEmail == u.email &&
                            m.toEmail == widget.user.email &&
                            !m.isRead,
                      )
                      .length;
                  final hasChat = lastMsg.isNotEmpty;

                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        c,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChatScreen(user: widget.user, other: u),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: unread > 0
                            ? Colors.amber.withValues(alpha: 0.08)
                            : const Color(0xFF0E0E0E),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: unread > 0
                              ? Colors.amber.withValues(alpha: 0.5)
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        children: [
                          userAvatar(u, radius: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '[${u.code}] ',
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        u.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (u.isAdmin)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 4),
                                        child: Icon(
                                          Icons.shield,
                                          color: Colors.amber,
                                          size: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  hasChat ? 'Sohbeti başlat' : 'Yeni sohbet',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (unread > 0)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white38,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pendingScreen(BuildContext c) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: const Text(
          'ONAY BEKLENİYOR',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.amber),
            onPressed: () => Navigator.pushReplacement(
              c,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_top, color: Colors.amber, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Onay Bekleniyor',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hoş geldin, ${widget.user.name}!\n\nKaydın alındı. Bir yönetici hesabını onaylayana kadar uygulamayı kullanamazsın.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.amber, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          '${widget.user.name} (${widget.user.code})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.email,
                          color: Colors.white54,
                          size: 16,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.user.email,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
