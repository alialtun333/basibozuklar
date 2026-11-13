import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/app_data.dart';
import '../services/helpers.dart';
import '../services/ota_service.dart';
import '../widgets/common_widgets.dart';
import 'auth_screen.dart';

// ============================================================
// PROFİL EKRANI
// ============================================================
class ProfileScreen extends StatelessWidget {
  final UserModel user;
  final VoidCallback refresh;
  const ProfileScreen({super.key, required this.user, required this.refresh});

  @override
  Widget build(BuildContext c) {
    // YÜKLEME KONTROLÜ
    if (users.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    final myItems = inventoryList.where((i) => i.owner == user.email).toList();
    final myBadges = getUserBadges(user.email);
    final mc = user.membershipType == 'Sekban'
        ? Colors.amber
        : user.membershipType == 'Acemi'
            ? Colors.green
            : Colors.cyan;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: const Text(
          'PROFİL',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.amber),
            onPressed: () async {
              await Navigator.push(
                c,
                MaterialPageRoute(
                  builder: (_) => ProfileEditScreen(user: user),
                ),
              );
              refresh();
            },
          ),
          notifBtn(c, user, refresh),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _photoDialog(c),
              child: Stack(
                children: [
                  userAvatar(user, radius: 50),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '[${user.code}] • ${user.role}',
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
                    user.membershipType,
                    style: TextStyle(
                      color: mc,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (user.squadRole != 'Yok') ...[
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
                      user.squadRole,
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
            if (user.isAdmin)
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
            const SizedBox(height: 20),

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
              const SizedBox(height: 20),
            ],

            _st('KİŞİSEL BİLGİLER'),
            _tile(Icons.email, 'E-posta', user.email),
            _tile(Icons.badge, 'Takım Kodu', user.code),
            _tile(Icons.shield, 'Birlik', user.squad),
            const SizedBox(height: 20),

            _st('SAĞLIK BİLGİLERİ'),
            _tile(
              Icons.bloodtype,
              'Kan Grubu',
              user.bloodType.isEmpty ? 'Belirtilmedi' : user.bloodType,
            ),
            _tile(
              Icons.cake,
              'Yaş',
              user.age == null ? 'Belirtilmedi' : '${user.age} yaş',
            ),
            _tile(
              Icons.emergency,
              'Acil Durumda Ara',
              user.emergencyName.isEmpty
                  ? 'Belirtilmedi'
                  : '${user.emergencyName} - ${user.emergencyPhone}',
            ),
            _tile(
              Icons.medical_services,
              'Alerji / İlaç',
              user.allergies.isEmpty ? 'Yok' : user.allergies,
            ),
            const SizedBox(height: 20),

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
            const SizedBox(height: 20),

            // UYGULAMA BÖLÜMÜ (OTA Güncelleme)
            _st('UYGULAMA'),
            _actionTile(
              Icons.system_update,
              'Güncellemeyi Kontrol Et',
              () => OtaService.checkForUpdates(c),
            ),
            const SizedBox(height: 20),

            _st('GÜVENLİK'),
            _actionTile(
              Icons.lock,
              'Şifre Değiştir',
              () => _showPasswordDialog(c),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'ÇIKIŞ YAP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (c.mounted) {
                    Navigator.pushAndRemoveUntil(
                      c,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _photoDialog(BuildContext c) {
    final urlCtrl = TextEditingController(text: user.photoUrl);
    showDialog(
      context: c,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          'Profil Fotoğrafı',
          style: TextStyle(color: Colors.amber, fontSize: 15),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Fotoğraf URL\'si girin (örn: imgur.com, Firebase Storage)',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: urlCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Fotoğraf URL',
                labelStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İPTAL', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              user.photoUrl = '';
              firestoreDb.collection('users').doc(user.email).set(user.toMap());
              Navigator.pop(ctx);
            },
            child: const Text('KALDIR', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              user.photoUrl = urlCtrl.text.trim();
              firestoreDb.collection('users').doc(user.email).set(user.toMap());
              Navigator.pop(ctx);
            },
            child: const Text('KAYDET'),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext c) {
    final oldPw = TextEditingController();
    final newPw = TextEditingController();
    showDialog(
      context: c,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          'Şifre Değiştir',
          style: TextStyle(color: Colors.amber, fontSize: 15),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPw,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Mevcut Şifre',
                labelStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPw,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Yeni Şifre',
                labelStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İPTAL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              if (oldPw.text != user.pass) {
                ScaffoldMessenger.of(c).showSnackBar(
                  const SnackBar(
                    content: Text('Mevcut şifre hatalı!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (newPw.text.length < 3) {
                ScaffoldMessenger.of(c).showSnackBar(
                  const SnackBar(
                    content: Text('Yeni şifre en az 3 karakter!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              user.pass = newPw.text;
              firestoreDb.collection('users').doc(user.email).set(user.toMap());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(c).showSnackBar(
                const SnackBar(
                  content: Text('Şifre güncellendi!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('KAYDET'),
          ),
        ],
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

  Widget _actionTile(IconData ic, String l, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
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
                child: Text(
                  l,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      );
}

// ============================================================
// PROFİL DÜZENLE EKRANI
// ============================================================
class ProfileEditScreen extends StatefulWidget {
  final UserModel user;
  const ProfileEditScreen({super.key, required this.user});
  @override
  State<ProfileEditScreen> createState() => _PES();
}

class _PES extends State<ProfileEditScreen> {
  late String _bt;
  late DateTime? _bd;
  late final TextEditingController _en, _ep, _al;

  @override
  void initState() {
    super.initState();
    _bt = widget.user.bloodType;
    _bd = widget.user.birthDate;
    _en = TextEditingController(text: widget.user.emergencyName);
    _ep = TextEditingController(text: widget.user.emergencyPhone);
    _al = TextEditingController(text: widget.user.allergies);
  }

  void _save() {
    widget.user.bloodType = _bt;
    widget.user.birthDate = _bd;
    widget.user.emergencyName = _en.text;
    widget.user.emergencyPhone = _ep.text;
    widget.user.allergies = _al.text;
    firestoreDb
        .collection('users')
        .doc(widget.user.email)
        .set(widget.user.toMap());
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil güncellendi!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  InputDecoration _id(String l, IconData ic) => InputDecoration(
        labelText: l,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        prefixIcon: Icon(ic, color: Colors.amber),
        filled: true,
        fillColor: Colors.black,
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
            'PROFİLİ DÜZENLE',
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
              const Text(
                'KAN GRUBU',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _bt.isEmpty ? null : _bt,
                dropdownColor: const Color(0xFF121212),
                style: const TextStyle(color: Colors.white),
                decoration: _id('Kan Grubu', Icons.bloodtype),
                items: bloodTypes
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) => setState(() => _bt = v ?? ''),
              ),
              const SizedBox(height: 16),
              const Text(
                'DOĞUM TARİHİ',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final p = await showDatePicker(
                    context: c,
                    initialDate: _bd ?? DateTime(2000),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (p != null) setState(() => _bd = p);
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
                        _bd == null
                            ? 'Doğum Tarihi Seç'
                            : '${_bd!.day}/${_bd!.month}/${_bd!.year}',
                        style: TextStyle(
                          color: _bd == null ? Colors.white54 : Colors.white,
                        ),
                      ),
                      const Icon(Icons.cake, color: Colors.amber, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ACİL DURUMDA ARANACAK KİŞİ',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _en,
                style: const TextStyle(color: Colors.white),
                decoration: _id('Kişi Adı Soyadı', Icons.person),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ep,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: _id('Telefon', Icons.phone),
              ),
              const SizedBox(height: 16),
              const Text(
                'ALERJİ / İLAÇLAR',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _al,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _id(
                  'Alerji veya düzenli kullandığın ilaçlar',
                  Icons.medical_services,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _save,
                child: const Text(
                  'KAYDET',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ),
            ],
          ),
        ),
      );
}
