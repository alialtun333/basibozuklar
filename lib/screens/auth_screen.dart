import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/app_data.dart';
import '../services/helpers.dart';
import '../services/fcm_service.dart';
import 'main_shell.dart';

// ============================================================
// AÇILIŞ EKRANI (Sadece loading animasyonu)
// ============================================================
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: Colors.black,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: Colors.amber,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Yükleniyor...',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}

// ============================================================
// LOGIN EKRANI
// ============================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LS();
}

class _LS extends State<LoginScreen> {
  late final TextEditingController _em, _pw;
  bool _hide = true, _remember = false;
  late bool _kvkkOnay;

  @override
  void initState() {
    super.initState();
    _em = TextEditingController(text: savedEmail ?? '');
    _pw = TextEditingController(text: savedPass ?? '');
    _remember = rememberGlobal;
    _kvkkOnay = kvkkOnaylandi;
  }

  Future<void> _login() async {
    if (!_kvkkOnay) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen KVKK aydınlatma metnini onaylayın!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!kvkkOnaylandi) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('kvkkOnaylandi', true);
      kvkkOnaylandi = true;
    }

    final f = users.firstWhere(
      (u) => u.email == _em.text.trim() && u.pass == _pw.text,
      orElse: () =>
          UserModel(code: '', name: '', email: '', pass: '', role: ''),
    );

    if (f.email.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      if (_remember) {
        savedEmail = _em.text.trim();
        savedPass = _pw.text;
        rememberGlobal = true;
        await prefs.setString('savedEmail', savedEmail!);
        await prefs.setString('savedPass', savedPass!);
        await prefs.setBool('rememberMe', true);
      } else {
        savedEmail = null;
        savedPass = null;
        rememberGlobal = false;
        await prefs.remove('savedEmail');
        await prefs.remove('savedPass');
        await prefs.setBool('rememberMe', false);
      }

      FcmService.saveTokenToFirestore(f.email)
          .timeout(const Duration(seconds: 3))
          .catchError((_) => null);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Shell(user: f)),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-posta veya şifre hatalı!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRegisterDialog() {
    final regName = TextEditingController();
    final regCode = TextEditingController();
    final regEmail = TextEditingController();
    final regPass = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          'Takıma Kayıt Ol',
          style: TextStyle(color: Colors.amber, fontSize: 16),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _regField(regName, 'Ad Soyad / Çağrı Adı'),
                const SizedBox(height: 8),
                _regField(
                  regCode,
                  'Takım Kodu (örn: BB07)',
                  inputFormatters: [_UpperCaseTextFormatter()],
                ),
                const SizedBox(height: 8),
                _regField(
                  regEmail,
                  'E-posta',
                  keyboard: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                _regField(regPass, 'Şifre', obscure: true),
              ],
            ),
          ),
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
            onPressed: () async {
              if (regName.text.trim().isEmpty ||
                  regCode.text.trim().isEmpty ||
                  regEmail.text.trim().isEmpty ||
                  regPass.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tüm alanları doldurmak zorunludur!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              final codeUpper = regCode.text.trim().toUpperCase();
              if (!RegExp(r'^BB\d{2,}$').hasMatch(codeUpper)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Takım kodu "BB" ile başlamalı ve en az 2 rakam içermeli (örn: BB07)!',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (users.any((u) => u.email == regEmail.text.trim())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bu e-posta zaten kayıtlı!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (users.any((u) => u.code == codeUpper)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bu takım kodu zaten kullanılıyor!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final formattedName = _formatName(regName.text);
              final newUser = UserModel(
                code: codeUpper,
                name: formattedName,
                email: regEmail.text.trim(),
                pass: regPass.text,
                role: 'Rifleman',
                status: 'Belirsiz',
                squad: 'Atanmadı',
                isAdmin: false,
                isApproved: false,
                membershipType: 'Acemi',
                kvkkOnay: true,
              );
              users.add(newUser);
              await firestoreDb
                  .collection('users')
                  .doc(newUser.email)
                  .set(newUser.toMap());
              notifyU(
                newUser.email,
                'game',
                'Kaydın Alındı',
                'Yönetici onayı bekleniyor.',
              );
              for (var admin in users.where((u) => u.isAdmin)) {
                notifyU(
                  admin.email,
                  'game',
                  'Yeni Kayıt Onayı Bekliyor',
                  '${newUser.name} (${newUser.code}) takıma katılmak istiyor.',
                );
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                FcmService.saveTokenToFirestore(newUser.email)
                    .timeout(const Duration(seconds: 3))
                    .catchError((_) => null);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => Shell(user: newUser)),
                );
              }
            },
            child: const Text('KAYIT OL'),
          ),
        ],
      ),
    );
  }

  Widget _regField(
    TextEditingController ctrl,
    String label, {
    TextInputType? keyboard,
    bool obscure = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      obscureText: obscure,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
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
      ),
    );
  }

  InputDecoration _i(String l, IconData ic) => InputDecoration(
    labelText: l,
    labelStyle: const TextStyle(color: Colors.amber),
    prefixIcon: Icon(ic, color: Colors.amber),
    filled: true,
    fillColor: Colors.black.withValues(alpha: 0.8),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.amber, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.amber, width: 2),
    ),
  );

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/orman.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.75)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/ana_ekran.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'BAŞIBOZUKLAR',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: Colors.amber,
                      ),
                    ),
                    const Text(
                      'AIRSOFT',
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 6,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _em,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: _i('E-posta Adresi', Icons.email),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _pw,
                      obscureText: _hide,
                      style: const TextStyle(color: Colors.white),
                      decoration: _i('Şifre', Icons.lock).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _hide ? Icons.visibility_off : Icons.visibility,
                            color: Colors.amber,
                          ),
                          onPressed: () => setState(() => _hide = !_hide),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: _remember,
                                activeColor: Colors.amber,
                                checkColor: Colors.black,
                                side: const BorderSide(
                                  color: Colors.amber,
                                  width: 2,
                                ),
                                onChanged: (v) =>
                                    setState(() => _remember = v ?? false),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Beni Hatırla',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Şifremi Unuttum',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (!kvkkOnaylandi)
                      Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: _kvkkOnay,
                              activeColor: Colors.amber,
                              checkColor: Colors.black,
                              side: const BorderSide(
                                color: Colors.amber,
                                width: 2,
                              ),
                              onChanged: (v) =>
                                  setState(() => _kvkkOnay = v ?? false),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Wrap(
                              children: [
                                const Text(
                                  'Verilerimin KVKK kapsamında işlenmesini onaylıyorum. ',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => Navigator.push(
                                    c,
                                    MaterialPageRoute(
                                      builder: (_) => const KvkkScreen(),
                                    ),
                                  ),
                                  child: const Text(
                                    'Aydınlatma Metni',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 11,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    TextButton(
                      onPressed: _showRegisterDialog,
                      child: const Text(
                        'Henüz hesabın yok mu? Kayıt Ol',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _login,
                        child: const Text(
                          'GİRİŞ YAP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Eskişehir 2024',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'By Ali ALTUN',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// YARDIMCI SINIFLAR
// ============================================================
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

String _upperTr(String s) => s.replaceAll('i', 'İ').toUpperCase();
String _lowerTr(String s) =>
    s.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

String _formatName(String input) {
  final parts = input
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return input.trim();
  if (parts.length == 1) {
    final p = parts[0];
    return '${_upperTr(p[0])}${p.length > 1 ? _lowerTr(p.substring(1)) : ''}';
  }
  final result = <String>[];
  for (int i = 0; i < parts.length; i++) {
    final p = parts[i];
    if (i == parts.length - 1) {
      result.add(_upperTr(p));
    } else {
      result.add(
        '${_upperTr(p[0])}${p.length > 1 ? _lowerTr(p.substring(1)) : ''}',
      );
    }
  }
  return result.join(' ');
}

// ============================================================
// KVKK AYDINLATMA METNİ
// ============================================================
class KvkkScreen extends StatelessWidget {
  const KvkkScreen({super.key});

  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.amber,
      title: const Text(
        'KVKK AYDINLATMA METNİ',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    ),
    body: const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Text(
        'BAŞIBOZUKLAR AIRSOFT KULÜBÜ\nKİŞİSEL VERİLERİN KORUNMASI KANUNU (KVKK) AYDINLATMA METNİ\n\n'
        '1. VERİ SORUMLUSU\n'
        'Başıbozuklar Airsoft Kulübü olarak, 6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") uyarınca kişisel verilerinizin güvenliğine önem veriyoruz.\n\n'
        '2. İŞLENEN KİŞİSEL VERİLER\n'
        'Adınız, soyadınız, e-posta adresiniz, takım kodunuz, kan grubunuz, doğum tarihiniz, acil durum iletişim bilgileriniz, alerji bilgileriniz ve oyun katılım durumlarınız işlenmektedir.\n\n'
        '3. İŞLEME AMACI\n'
        'Verileriniz; takım organizasyonu, oyun planlaması, acil durum yönetimi, sağlık güvenliğiniz ve kulüp içi iletişimin sağlanması amacıyla işlenmektedir.\n\n'
        '4. VERİLERİN AKTARILMASI\n'
        'Kişisel verileriniz, yasal zorunluluklar dışında üçüncü şahıslarla paylaşılmaz. Verileriniz Firebase güvenli sunucularında saklanmaktadır.\n\n'
        '5. HAKLARINIZ\n'
        'KVKK\'nın 11. maddesi uyarınca; verilerinizin işlenip işlenmediğini öğrenme, düzeltilmesini veya silinmesini talep etme hakkına sahipsiniz.\n\n'
        '6. ONAY\n'
        'Uygulamaya kayıt olarak ve giriş yaparak, yukarıda belirtilen verilerinizin işlenmesine onay vermiş sayılırsınız.',
        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
      ),
    ),
  );
}
