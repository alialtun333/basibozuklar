import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/app_data.dart';
import '../services/helpers.dart';

class NotifScreen extends StatefulWidget {
  final UserModel user;
  const NotifScreen({super.key, required this.user});
  @override
  State<NotifScreen> createState() => _NS();
}

class _NS extends State<NotifScreen> {
  Color _tc(String t) {
    switch (t) {
      case 'game':
        return Colors.amber;
      case 'survey':
        return Colors.blue;
      case 'team':
        return Colors.green;
      case 'inventory':
        return Colors.orange;
      case 'message':
        return Colors.purple;
      case 'badge':
        return Colors.yellow;
      default:
        return Colors.amber;
    }
  }

  IconData _ti(String t) {
    switch (t) {
      case 'game':
        return Icons.gps_fixed;
      case 'survey':
        return Icons.how_to_vote;
      case 'team':
        return Icons.groups;
      case 'inventory':
        return Icons.inventory_2;
      case 'message':
        return Icons.message;
      case 'badge':
        return Icons.workspace_premium;
      default:
        return Icons.notifications;
    }
  }

  String _ta(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'Az önce';
    if (d.inHours < 1) return '${d.inMinutes} dk önce';
    if (d.inDays < 1) return '${d.inHours} sa önce';
    if (d.inDays < 7) return '${d.inDays} gün önce';
    return fmtDT(dt);
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

    // Kullanıcının bildirimlerini al
    final my = notifs.where((n) => n.userEmail == widget.user.email).toList();

    // DÜZELTME: Bildirimleri en yeniden en eskiye doğru sırala
    my.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: const Text(
          'BİLDİRİMLER',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          if (my.any((n) => !n.isRead))
            TextButton.icon(
              onPressed: () async {
                setState(() {
                  for (var n in my) {
                    n.isRead = true;
                  }
                });
                // Tümünü okundu yaparken Firestore'u güncelle
                for (var n in my) {
                  await firestoreDb
                      .collection('notifs')
                      .doc(n.id)
                      .set(n.toMap());
                }
              },
              icon: const Icon(Icons.done_all, color: Colors.amber, size: 16),
              label: const Text(
                'Tümünü Oku',
                style: TextStyle(color: Colors.amber, fontSize: 11),
              ),
            ),
        ],
      ),
      body: my.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    color: Colors.white38,
                    size: 64,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Henüz bildirim yok.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: my.length,
              itemBuilder: (c, i) {
                final n = my[i];
                final col = _tc(n.type);
                return InkWell(
                  onTap: () {
                    if (!n.isRead) {
                      setState(() => n.isRead = true);
                      firestoreDb.collection('notifs').doc(n.id).set(n.toMap());
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: n.isRead
                          ? const Color(0xFF0E0E0E)
                          : col.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: n.isRead
                            ? Colors.white12
                            : col.withValues(alpha: 0.5),
                        width: n.isRead ? 1 : 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: col.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(_ti(n.type), color: col, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      n.title,
                                      style: TextStyle(
                                        color: n.isRead
                                            ? Colors.white70
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  if (!n.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n.message,
                                style: TextStyle(
                                  color: n.isRead
                                      ? Colors.white38
                                      : Colors.white60,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _ta(n.timestamp),
                                style: TextStyle(
                                  color: col.withValues(alpha: 0.7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
