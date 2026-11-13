import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  // Senin Firebase'den aldığın VAPID Key
  static const String vapidKey =
      "BIh-VWFZNnh1EoUZn3YR-A0hoKPvbl8tqoK6GdhRl9FyLYWXEYrYWABg4Dm4YMMycp-pJjbh2M31TaUqJQXMDHA";

  static Future<void> initialize() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // 1. İzin İste
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Kullanıcı bildirim izni verdi.');

        // 2. Token Al
        String? token;
        if (kIsWeb) {
          token = await messaging.getToken(vapidKey: vapidKey);
        } else {
          token = await messaging.getToken();
        }
        debugPrint('🔑 FCM Token: $token');

        // 3. Uygulama açıkken gelen bildirimleri dinle
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint(
              '🔔 Uygulama açıkken bildirim geldi: ${message.notification?.title}');
        });
      } else {
        debugPrint('❌ Kullanıcı bildirim iznini reddetti.');
      }
    } catch (e) {
      debugPrint('FCM Başlatma Hatası: $e');
    }
  }

  // Token'ı Firestore'daki kullanıcıya kaydet
  static Future<void> saveTokenToFirestore(String userEmail) async {
    try {
      String? token;
      if (kIsWeb) {
        token = await FirebaseMessaging.instance.getToken(vapidKey: vapidKey);
      } else {
        token = await FirebaseMessaging.instance.getToken();
      }

      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userEmail)
            .update({
          'fcmToken': token,
        });
        debugPrint("💾 Token Firestore'a kaydedildi: $userEmail");
      }
    } catch (e) {
      debugPrint("Token kaydedilirken hata: $e");
    }
  }
}
