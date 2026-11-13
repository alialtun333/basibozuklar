import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/announcement_model.dart';
import '../services/app_data.dart';
import '../services/helpers.dart';

class AnnouncementsScreen extends StatefulWidget {
  final UserModel user;
  const AnnouncementsScreen({super.key, required this.user});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  @override
  Widget build(BuildContext context) {
    // Tüm duyuruları al ve en yeniden eskiye sırala
    final allAnns = List<AnnouncementModel>.from(announcements);
    allAnns.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: const Text(
          'TÜM DUYURULAR',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5),
        ),
      ),
      body: allAnns.isEmpty
          ? const Center(
              child: Text('Henüz duyuru yok.',
                  style: TextStyle(color: Colors.white54)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allAnns.length,
              itemBuilder: (c, i) {
                final ann = allAnns[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ann.isActive
                          ? Colors.amber.withValues(alpha: 0.5)
                          : Colors.white12,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Aktif/Pasif Etiketi
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: ann.isActive
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ann.isActive ? 'AKTİF' : 'GEÇMİŞ',
                              style: TextStyle(
                                color:
                                    ann.isActive ? Colors.green : Colors.grey,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ann.title,
                              style: TextStyle(
                                color: ann.isActive
                                    ? Colors.white
                                    : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          // Sadece Adminler Görebilir (Silme Butonu)
                          if (widget.user.isAdmin)
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 20),
                              onPressed: () => _deleteAnnouncement(ann),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ann.content,
                        style: TextStyle(
                          color: ann.isActive ? Colors.white70 : Colors.white38,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        fmtDT(ann.createdAt),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _deleteAnnouncement(AnnouncementModel ann) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Duyuruyu Sil',
            style: TextStyle(color: Colors.amber, fontSize: 16)),
        content: const Text('Bu duyuruyu silmek istediğinize emin misiniz?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İPTAL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                firestoreDb.collection('announcements').doc(ann.id).delete();
                announcements.removeWhere((a) => a.id == ann.id);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Duyuru silindi.'),
                    backgroundColor: Colors.green),
              );
            },
            child: const Text('SİL'),
          ),
        ],
      ),
    );
  }
}
