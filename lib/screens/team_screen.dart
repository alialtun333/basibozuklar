import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/app_data.dart';
import '../services/helpers.dart';
import '../widgets/common_widgets.dart';
import 'messages_screen.dart';

class TeamScreen extends StatefulWidget {
  final UserModel user;
  final VoidCallback refresh;
  const TeamScreen({super.key, required this.user, required this.refresh});
  @override
  State<TeamScreen> createState() => _TeamS();
}

class _TeamS extends State<TeamScreen> {
  @override
  Widget build(BuildContext c) {
    // YÜKLEME KONTROLÜ
    if (users.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    final sekbanC = users.where((u) => u.membershipType == 'Sekban').length;
    final acemiC = users.where((u) => u.membershipType == 'Acemi').length;
    final etkinlikC = users.where((u) => u.membershipType == 'Etkinlik').length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: const Text(
          'TAKIM',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          notifBtn(c, widget.user, () {
            widget.refresh();
            setState(() {});
          }),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _stat(
                    'Sekban',
                    '$sekbanC',
                    Icons.shield,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _stat('Acemi', '$acemiC', Icons.school, Colors.green),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _stat(
                    'Etkinlik',
                    '$etkinlikC',
                    Icons.event,
                    Colors.cyan,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: users.length,
              itemBuilder: (c, i) {
                final u = users[i];
                final status = activeGame?.statuses[u.email] ?? 'Belirsiz';
                final dc = status == 'Geliyorum'
                    ? Colors.green
                    : status == 'Gelmiyorum'
                    ? Colors.red
                    : Colors.orange;
                final mc = u.membershipType == 'Sekban'
                    ? Colors.amber
                    : u.membershipType == 'Acemi'
                    ? Colors.green
                    : Colors.cyan;
                return InkWell(
                  onTap: widget.user.isAdmin
                      ? () => Navigator.push(
                          c,
                          MaterialPageRoute(
                            builder: (_) => UserProfileViewScreen(
                              target: u,
                              viewer: widget.user,
                            ),
                          ),
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        userAvatar(u, radius: 20),
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
                                        size: 14,
                                      ),
                                    ),
                                  if (!u.isApproved)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Icon(
                                        Icons.pending,
                                        color: Colors.orange,
                                        size: 14,
                                      ),
                                    ),
                                  if (u.squadRole != 'Yok')
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Icon(
                                        u.squadRole == 'Kaptan'
                                            ? Icons.star
                                            : Icons.star_half,
                                        color: Colors.amberAccent,
                                        size: 14,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: mc.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      u.membershipType,
                                      style: TextStyle(
                                        color: mc,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${u.role} • ${u.squadRole != 'Yok' ? u.squadRole : (activeGame?.assignments[u.email] ?? u.squad)}',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (u.email != widget.user.email)
                          IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Colors.amber,
                              size: 18,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32),
                            onPressed: () => Navigator.push(
                              c,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ChatScreen(user: widget.user, other: u),
                              ),
                            ),
                          ),
                        if (activeGame != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: dc.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: dc.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: dc,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
    );
  }

  Widget _stat(String l, String v, IconData ic, Color col) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF121212),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: col.withValues(alpha: 0.4)),
    ),
    child: Column(
      children: [
        Icon(ic, color: col, size: 20),
        const SizedBox(height: 4),
        Text(
          v,
          style: TextStyle(
            color: col,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(l, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    ),
  );
}

// UserProfileViewScreen (Admin için) kısmı da aynen aşağıdadır, silmeyin.
class UserProfileViewScreen extends StatelessWidget {
  final UserModel target;
  final UserModel viewer;
  const UserProfileViewScreen({
    super.key,
    required this.target,
    required this.viewer,
  });

  @override
  Widget build(BuildContext c) {
    final myItems = inventoryList
        .where((i) => i.owner == target.email)
        .toList();
    final myBadges = getUserBadges(target.email);
    final mc = target.membershipType == 'Sekban'
        ? Colors.amber
        : target.membershipType == 'Acemi'
        ? Colors.green
        : Colors.cyan;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: Text(
          target.name,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            userAvatar(target, radius: 50),
            const SizedBox(height: 12),
            Text(
              target.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '[${target.code}] • ${target.role}',
              style: const TextStyle(color: Colors.amber, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: mc.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: mc),
                  ),
                  child: Text(
                    target.membershipType,
                    style: TextStyle(
                      color: mc,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (target.squadRole != 'Yok') ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amberAccent),
                    ),
                    child: Text(
                      target.squadRole,
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (target.isAdmin)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield, color: Colors.amber, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'YÖNETİCİ',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            if (!target.isApproved)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pending, color: Colors.orange, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'ONAY BEKLİYOR',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            if (myBadges.isNotEmpty) ...[
              _st('ROZETLER'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: myBadges.map((b) {
                  final col = badgeColor(b.color);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: col.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: col),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon(b.iconName), color: col, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          b.name,
                          style: TextStyle(
                            color: col,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            _st('KİŞİSEL BİLGİLER'),
            _tile(Icons.email, 'E-posta', target.email),
            _tile(Icons.badge, 'Takım Kodu', target.code),
            _tile(Icons.shield, 'Birlik', target.squad),
            const SizedBox(height: 16),
            _st('SAĞLIK BİLGİLERİ'),
            _tile(
              Icons.bloodtype,
              'Kan Grubu',
              target.bloodType.isEmpty ? 'Belirtilmedi' : target.bloodType,
            ),
            _tile(
              Icons.cake,
              'Yaş',
              target.age == null ? 'Belirtilmedi' : '${target.age} yaş',
            ),
            _tile(
              Icons.emergency,
              'Acil Durumda Ara',
              target.emergencyName.isEmpty
                  ? 'Belirtilmedi'
                  : '${target.emergencyName} - ${target.emergencyPhone}',
            ),
            _tile(
              Icons.medical_services,
              'Alerji / İlaç',
              target.allergies.isEmpty ? 'Yok' : target.allergies,
            ),
            const SizedBox(height: 16),
            _st('ZİMMETLİ EŞYALAR'),
            if (myItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Center(
                  child: Text(
                    'Zimmetli eşya yok.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              )
            else
              ...myItems.map(
                (i) => _tile(Icons.inventory_2, i.name, i.category),
              ),
          ],
        ),
      ),
    );
  }

  Widget _st(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        t,
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    ),
  );
  Widget _tile(IconData ic, String l, String v) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF121212),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(
      children: [
        Icon(ic, color: Colors.amber, size: 20),
        const SizedBox(width: 12),
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
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
