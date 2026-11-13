import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/message_model.dart';
import '../models/notif_model.dart'; // NotifModel için eklendi
import '../services/app_data.dart';
import '../services/helpers.dart';
import '../widgets/common_widgets.dart';

// ============================================================
// MESAJLAR LİSTESİ (StatefulWidget yapıldı)
// ============================================================
class MessagesScreen extends StatefulWidget {
  final UserModel user;
  const MessagesScreen({super.key, required this.user});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    final user = widget.user; // Kullanım kolaylığı için
    final myMsgs = messages
        .where((m) => m.fromEmail == user.email || m.toEmail == user.email)
        .toList();

    // 1. Kişileri bir Set ile benzersiz olarak topla
    final partnersSet = <String>{};
    for (var m in myMsgs) {
      partnersSet.add(m.fromEmail == user.email ? m.toEmail : m.fromEmail);
    }

    // 2. Set'i Listeye çevir ve son mesaj zamanına göre sırala (En yeniden eskiye)
    final partners = partnersSet.toList();
    partners.sort((a, b) {
      final lastA = myMsgs
          .where((m) => m.fromEmail == a || m.toEmail == a)
          .reduce((x, y) => x.timestamp.isAfter(y.timestamp) ? x : y);
      final lastB = myMsgs
          .where((m) => m.fromEmail == b || m.toEmail == b)
          .reduce((x, y) => x.timestamp.isAfter(y.timestamp) ? x : y);
      return lastB.timestamp.compareTo(lastA.timestamp); // En yeni en üstte
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: const Text(
          'MESAJLAR',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: partners.isEmpty
          ? const Center(
              child: Text(
                'Henüz mesaj yok.',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: partners.length,
              itemBuilder: (c, i) {
                final email = partners[i]; // Sıralanmış listeden alıyoruz
                final u = users.firstWhere(
                  (x) => x.email == email,
                  orElse: () => users[0],
                );

                // Okunmamış mesajları say
                final unread = messages
                    .where(
                      (m) =>
                          m.fromEmail == email &&
                          m.toEmail == user.email &&
                          !m.isRead,
                    )
                    .length;

                // Son mesajı bul
                final last = myMsgs
                    .where((m) => m.fromEmail == email || m.toEmail == email)
                    .reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);

                return ListTile(
                  leading: userAvatar(u, radius: 20),
                  title: Text(
                    '[${u.code}] ${u.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    last.text,
                    style: const TextStyle(color: Colors.white54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: unread > 0
                      ? Container(
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
                      : null,
                  // Tıklanıp sohbetten dönüldüğünde setState ile listeyi yenile
                  onTap: () async {
                    await Navigator.push(
                      c,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(user: user, other: u),
                      ),
                    );
                    setState(() {}); // Okundu sayacını (badge) günceller
                  },
                );
              },
            ),
    );
  }
}

// ============================================================
// SOHBET EKRANI
// ============================================================
class ChatScreen extends StatefulWidget {
  final UserModel user, other;
  const ChatScreen({super.key, required this.user, required this.other});
  @override
  State<ChatScreen> createState() => _ChatS();
}

class _ChatS extends State<ChatScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _markAsRead(); // Okundu işaretleme fonksiyonunu çağır
  }

  void _markAsRead() {
    for (var m in messages) {
      if (m.fromEmail == widget.other.email && m.toEmail == widget.user.email) {
        if (!m.isRead) {
          m.isRead = true;
          // Yerel listeyi güncelledik, şimdi Firebase'e (Firestore) de kaydedelim
          firestoreDb
              .collection('messages')
              .doc(m.id)
              .update({'isRead': true}).catchError(
                  (e) => debugPrint('Firestore okundu hatası: $e'));
        }
      }
    }
  }

  void _send() {
    if (_ctrl.text.trim().isEmpty) return;

    // 1. Mesajı oluştur ve kaydet
    final msg = MessageModel(
      id: uid(),
      fromEmail: widget.user.email,
      toEmail: widget.other.email,
      text: _ctrl.text.trim(),
      timestamp: DateTime.now(),
    );
    setState(() => messages.add(msg));
    firestoreDb.collection('messages').doc(msg.id).set(msg.toMap());

    // 2. BİLDİRİMİ OLUŞTUR VE FIREBASE'E KAYDET (Böylece karşı tarafa düşer)
    final notifId = uid();
    final notif = NotifModel(
      id: notifId,
      userEmail: widget.other.email,
      type: 'message',
      title: 'Yeni Mesaj',
      message:
          '${widget.user.name}: ${_ctrl.text.trim().length > 40 ? '${_ctrl.text.trim().substring(0, 40)}...' : _ctrl.text.trim()}',
      timestamp: DateTime.now(),
    );

    notifs.insert(0, notif); // Yerel listeye ekle
    firestoreDb
        .collection('notifs')
        .doc(notifId)
        .set(notif.toMap()); // Firebase'e kaydet

    _ctrl.clear();
  }

  @override
  Widget build(BuildContext c) {
    final myMsgs = messages
        .where(
          (m) =>
              (m.fromEmail == widget.user.email &&
                  m.toEmail == widget.other.email) ||
              (m.fromEmail == widget.other.email &&
                  m.toEmail == widget.user.email),
        )
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: Text(
          '[${widget.other.code}] ${widget.other.name}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myMsgs.length,
              itemBuilder: (c, i) {
                final m = myMsgs[i];
                final isMe = m.fromEmail == widget.user.email;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.amber.withValues(alpha: 0.8)
                          : const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(10),
                      border: isMe ? null : Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          m.text,
                          style: TextStyle(
                            color: isMe ? Colors.black : Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${m.timestamp.hour.toString().padLeft(2, '0')}:${m.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: isMe ? Colors.black54 : Colors.white38,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF121212),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Mesaj yaz...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.black,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.amber),
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.amber),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
