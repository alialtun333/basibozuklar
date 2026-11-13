import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';

class OtaService {
  // FIREBASE'DEN ALDIĞIN VERSION.JSON LİNKİ BURAYA EKLENDİ
  static const String versionCheckUrl =
      'https://firebasestorage.googleapis.com/v0/b/basibozuklar26.firebasestorage.app/o/version.json.txt?alt=media&token=b600bd79-e243-4336-bc49-46a3be554cc5';

  // Eski sürümde olduğun için 1.0.0 kalmalı ki güncellemeyi yakalayabilsin
  static const String currentVersion = '1.0.0';

  static Future<void> checkForUpdates(BuildContext context) async {
    debugPrint('--- OTA KONTROLÜ BAŞLADI ---');
    debugPrint('OTA URL: $versionCheckUrl');

    try {
      // Zaman aşımını 10 saniyeye çıkardık
      final response = await http
          .get(Uri.parse(versionCheckUrl))
          .timeout(const Duration(seconds: 10));

      debugPrint('OTA HTTP DURUM KODU: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('OTA HATA MESAJI: ${response.body}');
        _showMessage(context, 'Sunucu hatası: ${response.statusCode}');
        return;
      }

      // Yanıt içeriğini kontrol et (Bazen HTML hata sayfası dönebilir)
      final String body = response.body;
      debugPrint('OTA YANIT İÇERİĞİ: $body');

      if (!body.startsWith('{')) {
        _showMessage(
            context, 'Sunucudan geçersiz yanıt alındı. (JSON bekleniyordu)');
        return;
      }

      final data = jsonDecode(body);
      final String latestVersion = data['latest_version'] ?? '';
      final String downloadUrl = data['download_url'] ?? '';

      if (latestVersion.isEmpty || downloadUrl.isEmpty) {
        _showMessage(context, 'Güncelleme bilgisi eksik veya bozuk.');
        return;
      }

      if (latestVersion == currentVersion) {
        _showMessage(context, 'Uygulama güncel (v$currentVersion).');
        return;
      }

      if (!context.mounted) return;
      final shouldUpdate = await _showUpdateDialog(context, latestVersion);
      if (shouldUpdate != true) return;

      _downloadAndInstall(context, downloadUrl);
    } on TimeoutException {
      debugPrint('OTA ZAMAN AŞIMI HATASI');
      _showMessage(context,
          'Bağlantı zaman aşımına uğradı. İnternetinizi kontrol edin.');
    } catch (e) {
      debugPrint('OTA GENEL HATA: $e');
      _showMessage(context, 'Bağlantı hatası: $e');
    }
  }

  static void _showMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors
            .redAccent, // Hata olduğunu belli etmek için kırmızımsı yaptık
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static Future<bool?> _showUpdateDialog(
    BuildContext context,
    String newVersion,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          '🎉 Yeni Güncelleme Mevcut',
          style: TextStyle(color: Colors.amber, fontSize: 16),
        ),
        content: Text(
          'Yeni sürüm: v$newVersion\n\n'
          'Uygulamayı güncellemek ister misiniz?\n\n'
          'Güncelleme sırasında uygulama kapanacak ve kurulum ekranı açılacak.',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('SONRA', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('GÜNCELLE'),
          ),
        ],
      ),
    );
  }

  static void _downloadAndInstall(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DownloadProgressDialog(url: url),
    );
  }
}

class _DownloadProgressDialog extends StatefulWidget {
  final String url;
  const _DownloadProgressDialog({required this.url});

  @override
  State<_DownloadProgressDialog> createState() =>
      _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  String _status = 'İndirme başlatılıyor...';
  int _progress = 0;
  StreamSubscription<OtaEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = OtaUpdate().execute(widget.url).listen(
      (event) {
        if (!mounted) return;
        setState(() {
          if (event.status == OtaStatus.DOWNLOADING) {
            _progress = int.tryParse(event.value ?? '0') ?? 0;
            _status = 'İndiriliyor: %$_progress';
          } else if (event.status == OtaStatus.INSTALLING) {
            _status = 'Kurulum başlatılıyor...';
          } else if (event.status == OtaStatus.PERMISSION_NOT_GRANTED_ERROR) {
            _status = 'Yükleme izni verilmedi! Lütfen ayarlardan izin verin.';
          } else if (event.status == OtaStatus.INTERNAL_ERROR) {
            _status = 'İç hata oluştu!';
          }
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() => _status = 'İndirme hatası: $e');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF121212),
      title: const Text(
        'Güncelleme İndiriliyor',
        style: TextStyle(color: Colors.amber, fontSize: 15),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: _progress / 100,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(Colors.amber),
            minHeight: 6,
          ),
          const SizedBox(height: 12),
          Text(
            _status,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
