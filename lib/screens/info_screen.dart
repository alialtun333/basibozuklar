import 'package:flutter/material.dart';

// ============================================================
// BİLGİ BANKASI EKRANI
// ============================================================
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      'title': 'Takım Kuralları',
      'icon': Icons.rule,
      'color': Colors.red,
      'desc': 'Genel davranış, güvenlik ve oyun kuralları',
      'articles': [
        {
          'title': 'Genel Davranış Kuralları',
          'content': '1. Her oyuncu takım içinde saygılı olmak zorundadır.\n2. Oyun alanında alkol ve madde kullanımı kesinlikle yasaktır.\n3. Takım lideri ve yöneticilerin verdiği komutlara anında uyulmalıdır.\n4. Oyun dışı kalan oyuncu, oyun alanından derhal ayrılmalıdır.\n5. Kaza ve yaralanma durumları vakit kaybetmeden takım liderine bildirilmelidir.',
        },
        {
          'title': 'Oyun İçi Kurallar',
          'content': '1. Vurulduğunuzda elinizi kaldırıp yüksek sesle "VURULDUM" demelisiniz.\n2. Ölü oyuncularla iletişim kurmak yasaktır.\n3. Ölü oyuncu, canlı oyuncuların önünden geçemez, siper olamaz.\n4. 5 metre ve altındaki mesafede vurmak yasaktır.\n5. Gözlük ve maske olmadan oyun alanına girmek kesinlikle yasaktır.',
        },
      ],
    },
    {
      'title': 'Ekipman Rehberi',
      'icon': Icons.backpack,
      'color': Colors.blue,
      'desc': 'Silah, koruma ve bakım tavsiyeleri',
      'articles': [
        {
          'title': 'Yeni Başlayanlar İçin Minimum Ekipman',
          'content': '• Onaylı koruyucu gözlük (ANSI Z87.1 veya EN 166 onaylı)\n• Tam yüz maskesi (diş koruması için)\n• Uzun kollu giysi ve uzun pantolon\n• Rahat ayakkabı veya askeri bot\n• Su matarası (2L minimum)\n• Dizlik ve dirseklik (şiddetle önerilir)\n\nUnutmayın: Ekipmandan önce güvenlik gelir.',
        },
        {
          'title': 'AEG Tüfek Bakımı',
          'content': '• Her oyun sonrası namluyu temizleyin.\n• Hop-up lastiğini 10-15 oyunda bir kontrol edin.\n• Pilleri tamamen bitirmeden şarj edin (LiPo için %20-80 arası ideal).\n• Yağlama için sadece silikon bazlı yağ kullanın.',
        },
      ],
    },
    {
      'title': 'Güvenlik',
      'icon': Icons.health_and_safety,
      'color': Colors.green,
      'desc': 'Güvenlik kontrolü ve acil durum prosedürleri',
      'articles': [
        {
          'title': 'Oyun Öncesi Güvenlik Kontrolü',
          'content': '1. Tüm oyuncular gözlük ve maske takıyor mu?\n2. Chrono ölçümü yapıldı mı?\n3. Oyun alanı sınırları belirlendi mi?\n4. İlk yardım çantası hazır mı?\n5. Telsiz frekansları ayarlandı mı?\n6. Oyun senaryosu tüm oyunculara anlatıldı mı?',
        },
      ],
    },
    {
      'title': 'Taktikler',
      'icon': Icons.track_changes,
      'color': Colors.orange,
      'desc': 'Hareket taktikleri, iletişim ve strateji',
      'articles': [
        {
          'title': 'Temel Hareket Taktikleri',
          'content': '• Sürünerek ilerleme: Sessiz ve düşük profil.\n• Çiftler halinde hareket: Biri kapak ateşi, diğeri ilerler.\n• Siperden sipere geçiş: Kısa mesafe, hızlı koşu.\n• Ateş ve hareket prensibi: Bir kişi ateş ederken diğeri ilerler.',
        },
        {
          'title': 'Telsiz İletişimi',
          'content': '1. Konuşma öncesi "Telsiz" deyin ve bekleyin.\n2. Kısa ve net konuşun.\n3. Önemli bilgiyi önce söyleyin.\n4. Kod adları kullanın (Kurt, Atmaca, Şahin gibi).\n5. Düşman konumu için saat yönü sistemi: "Saat 2 yönünde 50 metre".',
        },
      ],
    },
    {
      'title': 'Airsoft 101',
      'icon': Icons.school,
      'color': Colors.purple,
      'desc': 'Yeni başlayanlar için temel bilgiler',
      'articles': [
        {
          'title': 'Airsoft Nedir?',
          'content': 'Airsoft, 6mm plastik BB mermileri kullanan bir taktik sporudur.\n\nTemel özellikler:\n• Gerçekçi silah replikaları kullanılır.\n• BB mermileri 0.20-0.40 gram ağırlığındadır.\n• Hız limitleri güvenlik için katı kurallarla belirlenir.\n• Onur sistemi (honor system) esastır.\n• Hem eğlence hem de spor amaçlıdır.',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.amber,
      title: const Text(
        'BİLGİ BANKASI',
        style: TextStyle(
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'AIRSOFT KÜTÜPHANESİ',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Kategorilere tıklayarak detaylı bilgiye ulaşın.',
          style: TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 16),
        ...categories.map(
          (cat) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (cat['color'] as Color).withValues(alpha: 0.4),
              ),
            ),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (cat['color'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(cat['icon'], color: cat['color'], size: 24),
              ),
              title: Text(
                cat['title'],
                style: TextStyle(
                  color: cat['color'],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                cat['desc'],
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              iconColor: cat['color'],
              collapsedIconColor: Colors.grey,
              childrenPadding: const EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: 12,
              ),
              children: (cat['articles'] as List)
                  .map(
                    (a) => InkWell(
                      onTap: () => Navigator.push(
                        c,
                        MaterialPageRoute(
                          builder: (_) => InfoDetailScreen(
                            title: a['title'],
                            content: a['content'],
                            color: cat['color'],
                          ),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (cat['color'] as Color).withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.article_outlined,
                              color: cat['color'],
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                a['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white38,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// BİLGİ DETAY EKRANI
// ============================================================
class InfoDetailScreen extends StatelessWidget {
  final String title, content;
  final Color color;
  const InfoDetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: color,
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      iconTheme: IconThemeData(color: color),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            width: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ],
      ),
    ),
  );
}
