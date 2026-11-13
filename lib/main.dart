import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'models/user_model.dart';
import 'models/game_model.dart';
import 'models/announcement_model.dart';
import 'models/survey_model.dart';
import 'models/inventory_model.dart'; // YENİ EKLENDİ
import 'services/fcm_service.dart';
import 'services/app_data.dart';
import 'screens/auth_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // iOS Safari (WebKit) takılmalarını önlemek için 10 saniyelik zaman aşımı
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
  } catch (e) {
    debugPrint('Firebase başlatma hatası: $e');
  }

  // FCM Başlatmayı güvene alalım, hata verse bile uygulama açılsın
  try {
    await FcmService.initialize().timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('FCM başlatma hatası: $e');
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    savedEmail = prefs.getString('savedEmail');
    savedPass = prefs.getString('savedPass');
    rememberGlobal = prefs.getBool('rememberMe') ?? false;
    kvkkOnaylandi = prefs.getBool('kvkkOnaylandi') ?? false;
  } catch (e) {
    debugPrint('SharedPreferences hatası: $e');
  }

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isOnline = true;
  bool _splashDone = false;
  UserModel? _autoLoginUser;

  StreamSubscription? _usersSub;
  StreamSubscription? _gameSub;
  StreamSubscription? _annSub;
  StreamSubscription? _surveySub;
  StreamSubscription? _inventorySub; // YENİ EKLENDİ
  StreamSubscription? _connectivitySub;
  Timer? _fallbackTimer; // ACİL ÇIKIŞ ZAMANLAYICISI

  @override
  void initState() {
    super.initState();
    _initializeApp();

    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      if (mounted) {
        setState(() {
          _isOnline = !result.contains(ConnectivityResult.none);
        });
      }
    });

    // EĞER 12 SANİYE İÇİNDE VERİLER YÜKLENEMEZSE ZORLA GİRİŞ EKRANINA AT
    _fallbackTimer = Timer(const Duration(seconds: 12), () {
      if (mounted && _isLoading) {
        debugPrint(
            ">>> ACİL ÇIKIŞ: Veriler yüklenemedi, giriş ekranına geçiliyor.");
        setState(() {
          _isLoading = false;
          _splashDone = true;
          // Eğer hata verdiysek hata ekranı gösterme, direkt girişe at.
          _hasError = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _usersSub?.cancel();
    _gameSub?.cancel();
    _annSub?.cancel();
    _surveySub?.cancel();
    _inventorySub?.cancel(); // YENİ EKLENDİ
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        setState(() {
          _isLoading = false;
          _splashDone = true;
          _hasError = true;
          _errorMessage =
              'İnternet bağlantısı bulunamadı. Lütfen bağlantınızı kontrol edin.';
        });
        return;
      }

      try {
        await loadAllDataFromFirestore().timeout(const Duration(seconds: 10));
        _setupStreams();

        if (savedEmail != null &&
            savedEmail!.isNotEmpty &&
            savedPass != null &&
            savedPass!.isNotEmpty) {
          final f = users.firstWhere(
            (u) => u.email == savedEmail && u.pass == savedPass,
            orElse: () =>
                UserModel(code: '', name: '', email: '', pass: '', role: ''),
          );
          if (f.email.isNotEmpty) {
            _autoLoginUser = f;
            // FCM token kaydetmeyi arka planda yap, hata verse bile devam et
            FcmService.saveTokenToFirestore(f.email)
                .timeout(const Duration(seconds: 5))
                .catchError((_) => null);
          }
        }

        if (mounted) {
          _fallbackTimer?.cancel(); // Başarılı olduysa zamanlayıcıyı iptal et
          setState(() => _isLoading = false);

          await Future.delayed(const Duration(seconds: 2));
          if (mounted) setState(() => _splashDone = true);
        }
      } catch (e) {
        debugPrint('Başlangıç hatası: $e');
        if (mounted) {
          _fallbackTimer?.cancel();
          setState(() {
            _isLoading = false;
            _splashDone = true;
            _hasError = true;
            _errorMessage =
                'Veriler yüklenirken bir hata oluştu. Lütfen tekrar deneyin.';
          });
        }
      }
    } catch (e) {
      // Genel bir hata olursa uygulama kilitlenmesin
      debugPrint('Kritik Başlangıç hatası: $e');
      if (mounted) {
        _fallbackTimer?.cancel();
        setState(() {
          _isLoading = false;
          _splashDone = true;
        });
      }
    }
  }

  void _setupStreams() {
    _usersSub = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((snap) {
      users = snap.docs.map((d) => UserModel.fromMap(d.data())).toList();
      if (mounted) setState(() {});
    });
    _gameSub = FirebaseFirestore.instance
        .collection('games')
        .where('teamsAssigned', isEqualTo: false)
        .limit(1)
        .snapshots()
        .listen((snap) {
      activeGame =
          snap.docs.isEmpty ? null : GameModel.fromMap(snap.docs.first.data());
      if (mounted) setState(() {});
    });
    _annSub = FirebaseFirestore.instance
        .collection('announcements')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snap) {
      announcements =
          snap.docs.map((d) => AnnouncementModel.fromMap(d.data())).toList();
      if (mounted) setState(() {});
    });
    _surveySub = FirebaseFirestore.instance
        .collection('surveys')
        .snapshots()
        .listen((snap) {
      surveys = snap.docs.map((d) => SurveyModel.fromMap(d.data())).toList();
      if (mounted) setState(() {});
    });
    // YENİ EKLENDİ: Envanter (Demirbaş) Canlı Dinleyicisi
    _inventorySub = FirebaseFirestore.instance
        .collection('inventory')
        .snapshots()
        .listen((snap) {
      inventoryList =
          snap.docs.map((d) => InventoryModel.fromMap(d.data())).toList();
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext c) {
    Widget home;
    if (_isLoading || !_splashDone) {
      home = const SplashScreen();
    } else if (_hasError) {
      home = _ErrorScreen(message: _errorMessage, onRetry: _initializeApp);
    } else if (_autoLoginUser != null) {
      home = Shell(user: _autoLoginUser!);
    } else {
      home = const LoginScreen();
    }

    return UpgradeAlert(
      child: MaterialApp(
        title: 'Başıbozuklar',
        debugShowCheckedModeBanner: false,
        locale: const Locale('tr', 'TR'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('tr', 'TR')],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.amber,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        builder: (context, child) {
          return Column(
            children: [
              if (!_isOnline)
                Container(
                  color: Colors.red,
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 40, bottom: 8),
                  child: const Text(
                    'İnternet Bağlantısı Yok',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(child: child ?? const SizedBox()),
            ],
          );
        },
        home: home,
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorScreen({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Bağlantı Sorunu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SPLASH SCREEN (Kendi dosyan ayrıysa burayı silebilirsin)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.amber,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 20),
            Text(
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
}
