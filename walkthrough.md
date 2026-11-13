# Başıbozuklar Airsoft — Proje Arşivi (v3.0)

> **Son güncelleme:** 12.11.2026  
> **Bu dosya, projeyi başka bir AI'ya veya geliştiriciye devrederken tek başına yeterli olacak şekilde hazırlanmıştır.**

---

## 1. Proje Tanımı

Eskişehir merkezli **Başıbozuklar Airsoft** takımı için geliştirilen Flutter mobil uygulamasıdır. Amaç: WhatsApp gruplarındaki dağınık iletişimi ortadan kaldırıp oyuncu verileri, oyun takvimi, anketler, envanter/zimmet, mesajlaşma, rozetler ve bilgi bankasını tek merkezde toplamak.

- **Roller:** Admin (Takım Lideri), Sekban, Acemi, Etkinlik Oyuncusu
- **Platform:** Windows geliştirme + Android hedef (Pixel 7 emülatör, API 37)
- **Backend:** Firebase (Firestore + Cloud Functions + FCM)
- **İmza:** "By Ali ALTUN" giriş ekranında silik yazı

---

## 2. Teknoloji Yığını

| Katman | Teknoloji | Sürüm / Not |
|--------|-----------|-------------|
| Framework | Flutter | 3.47.9 |
| Dil | Dart | 3.13.7 |
| Veritabanı | Firebase Firestore | Canlı kullanımda |
| Sunucu Fonksiyonları | Firebase Cloud Functions | Node.js, Blaze planı |
| Bildirimler | Firebase Cloud Messaging (FCM) | Arka planda/kapalıyken çalışır |
| Kimlik Doğrulama | 🔴 **YOK** | Şifreler Firestore'da düz metin |
| Yerel Depolama | shared_preferences | Beni Hatırla + KVKK onayı |
| Güncelleme Kontrolü | upgrader | Uygulama açılışında Play Store kontrolü |

### Kullanılan Paketler (pubspec.yaml)

**dependencies:**

| Paket | Sürüm | Amaç |
|-------|-------|------|
| `flutter` | SDK | Framework |
| `cupertino_icons` | ^1.0.8 | iOS tarzı ikonlar |
| `shared_preferences` | ^2.2.2 | Yerel anahtar-değer depolama (Beni Hatırla, KVKK) |
| `firebase_core` | ^5.1.0 | Firebase başlatma |
| `firebase_messaging` | ^17.0.1 | FCM push bildirimleri |
| `url_launcher` | ^6.3.3 | Harici URL açma (harita, link) |
| `upgrader` | ^13.8.0 | Uygulama güncelleme kontrolü |
| `cloud_firestore` | ^7.1.0 | Firestore veritabanı |
| `firebase_auth` | ^7.0.1 | (Henüz aktif değil, ileride kullanılacak) |
| `connectivity_plus` | ^7.3.2 | İnternet bağlantı kontrolü |
| `flutter_localizations` | SDK | Türkçe lokalizasyon |
| `intl` | ^0.20.3 | Tarih/sayı formatı |

**dev_dependencies:**

| Paket | Sürüm | Amaç |
|-------|-------|------|
| `flutter_test` | SDK | Test framework |
| `flutter_lints` | ^6.0.0 | Lint kuralları |
| `flutter_launcher_icons` | ^0.14.4 | Uygulama ikonu oluşturma |
| `flutter_native_splash` | ^2.4.1 | Native splash ekranı |
| `mocktail` | ^1.0.5 | Mock test nesneleri |
| `build_runner` | ^2.17.1 | Kod üreteci |

### 🔴 Kaldırılan Paketler

| Paket | Neden Kaldırıldı |
|-------|-----------------|
| `flutter_local_notifications` | Android SDK 37 (API 37) ile derleme uyumsuzluğu. Sürekli `compileSdk` hatası veriyordu. Uygulama açıkken gelen FCM bildirimleri şu an sadece konsola yazdırılıyor, görsel bildirim yok. Gelecekte `awesome_notifications` ile değiştirilecek. |

---

## 3. Klasör Yapısı (Detaylı Ağaç)

```text
basibozuklar_v1/
├── lib/
│   ├── main.dart                          # Uygulama giriş noktası, App State, Stream yönetimi, tema
│   ├── firebase_options.dart              # Firebase yapılandırması (FlutterFire CLI tarafından üretildi)
│   ├── models/
│   │   ├── announcement_model.dart        # Duyuru veri modeli (id, title, content, adminEmail, createdAt, isActive)
│   │   ├── badge_model.dart               # Rozet ve kullanıcı-rozet veri modelleri (BadgeModel + UserBadgeModel)
│   │   ├── game_model.dart                # Oyun veri modeli (takım atamaları, silahlar, durumlar, konum)
│   │   ├── game_summary_model.dart        # Oyun özet istatistikleri (katılım, silah dağılımı)
│   │   ├── inventory_model.dart           # Envanter/malzeme veri modeli (id, name, category, owner)
│   │   ├── message_model.dart             # Kullanıcılar arası mesaj modeli (from, to, text, timestamp)
│   │   ├── notif_model.dart               # Uygulama içi bildirim modeli (type, title, message, isRead)
│   │   ├── photo_model.dart               # Fotoğraf galeri modeli (url, title, gameId, uploaderEmail)
│   │   ├── survey_model.dart              # Anket modeli (seçenekler, oylar) + SurveyOption alt modeli
│   │   ├── user_model.dart                # Kullanıcı modeli (profil, sağlık, acil durum, üyelik tipi)
│   │   └── zimmet_log_model.dart          # Zimmet işlem geçmişi modeli (teslim/iade logları)
│   ├── screens/
│   │   ├── admin_screen.dart              # Yönetim paneli (7 accordion: oyun, anket, envanter, rozet, duyuru, üye, fotoğraf)
│   │   ├── auth_screen.dart               # Giriş ekranı (SplashScreen + LoginScreen + kayıt dialog)
│   │   ├── games_screen.dart              # Aktif oyun detayları, geri sayım, katılım, harita, geçmiş oyunlar
│   │   ├── game_summary_screen.dart       # Oyun sonrası özet istatistikleri
│   │   ├── home_screen.dart               # Ana sayfa (oyun kartı, duyurular, anketler, envanter, bilgi bankası)
│   │   ├── info_screen.dart               # Bilgi bankası (Airsoft kuralları, takım bilgileri)
│   │   ├── inventory_screen.dart          # Envanter listesi ve zimmet log ekranı
│   │   ├── main_shell.dart                # Alt navigasyon çubuğu (Ana Sayfa, Kadro, Oyunlar, Profil + Admin)
│   │   ├── messages_screen.dart           # Kullanıcılar arası mesajlaşma ekranı
│   │   ├── notif_screen.dart              # Bildirim geçmişi ekranı (okundu/okunmadı)
│   │   ├── profile_screen.dart            # Kullanıcı profili düzenleme (fotoğraf, sağlık, acil durum)
│   │   ├── rules_screen.dart              # Takım kuralları ekranı
│   │   ├── survey_screen.dart             # Anket akışı, liste ve oluşturma ekranları (3 sınıf)
│   │   ├── team_assignment_screen.dart    # Takım atama ekranı (silah puanı bazlı otomatik dağıtım)
│   │   └── team_screen.dart               # Kadro listesi (üye kartları, filtreler)
│   ├── services/
│   │   ├── app_data.dart                  # Global değişkenler, mock veriler, Firestore'dan ilk yükleme fonksiyonu
│   │   ├── fcm_service.dart               # FCM token alma, kaydetme, arka plan bildirim işleme
│   │   ├── firestore_service.dart         # Firestore CRUD stream sınıfı (her koleksiyon için metotlar)
│   │   └── helpers.dart                   # Yardımcı fonksiyonlar (tarih formatlama, rozet atama, bildirim, takım dağıtımı)
│   └── widgets/
│       └── common_widgets.dart            # Ortak widget'lar (kullanıcı avatarı, bildirim çanı)
├── functions/
│   ├── index.js                           # Cloud Functions (4 tetikleyici)
│   ├── package.json                       # Node.js bağımlılıkları
│   └── .eslintrc.js                       # ESLint yapılandırması
├── test/
│   ├── models/
│   │   ├── user_model_test.dart           # UserModel birim testleri (4 test)
│   │   └── game_model_test.dart           # GameModel birim testleri (3 test)
│   └── services/
│       ├── helpers_test.dart              # Helpers fonksiyon testleri (13 test)
│       └── survey_logic_test.dart         # SurveyModel mantık testleri (3 test)
├── assets/images/
│   ├── orman.jpg                          # Giriş ekranı arka plan görseli
│   ├── logo.png                           # Takım logosu
│   ├── ana_ekran.png                      # Splash ekranı görseli
│   └── Uygulama_logo.png                 # Uygulama ikonu
├── firestore.rules                        # Firestore güvenlik kuralları
├── firebase.json                          # Firebase yapılandırması (functions + firestore)
├── .firebaserc                            # Firebase proje bağlantısı (basibozuklar26)
├── pubspec.yaml                           # Flutter proje yapılandırması ve bağımlılıklar
└── analysis_options.yaml                  # Dart/Flutter lint kuralları
```

---

## 4. Aktif Özellikler (Checklist)

- [x] **Firestore canlı veri dinleme** — `main.dart` içinde `_setupStreams()` ile `users`, `games`, `announcements`, `surveys` koleksiyonları anlık dinleniyor
- [x] **KVKK onayı** — İlk girişte bir kez sorulur, `shared_preferences` ile saklanır, tekrar sorulmaz
- [x] **Otomatik giriş (Beni Hatırla)** — E-posta ve şifre `shared_preferences`'a kaydedilir, uygulama açılışında otomatik giriş yapılır
- [x] **Türkçe tarih formatı** — `fmtDT()` fonksiyonu ile `dd/MM/yyyy - HH:mm` formatında, Türkçe locale aktif
- [x] **Harita + koordinat entegrasyonu** — `url_launcher` ile Google Maps / Apple Maps açılır, oyun konumu `latitude/longitude` ile saklanır
- [x] **Otomatik takım dağıtımı** — Silah puanlarına göre dengeli iki takım oluşturma (`team_assignment_screen.dart`)
- [x] **İnternet kontrolü** — `connectivity_plus` ile sürekli dinleme, bağlantı kesilince kırmızı uyarı barı gösterilir
- [x] **Loading ekranları** — SplashScreen (2 sn), Firestore veri yüklenirken `CircularProgressIndicator`
- [x] **Cloud Functions (4 tetikleyici)** — Duyuru, mesaj, yeni oyun ve takım atama bildirimleri
- [x] **FCM push bildirimleri** — Uygulama kapalıyken çalışır, arka plan handler aktif
- [x] **Firestore güvenlik kuralları** — Koleksiyon bazlı okuma/yazma izinleri, admin kontrolü
- [x] **Rozet sistemi** — Otomatik (ilk oyun, veteran, sadık üye vb.) ve manuel rozet atama
- [x] **Zimmet yönetimi** — Envanter teslim/iade logları, admin panelinden yönetim
- [x] **Mesajlaşma** — Kullanıcılar arası doğrudan mesaj, okundu bilgisi
- [x] **Bilgi bankası** — Airsoft kuralları ve takım bilgileri
- [x] **Kurallar ekranı** — Takım iç kuralları
- [x] **Yönetim paneli** — 7 adet accordion bölümü (oyun oluşturma, anket, envanter, rozet, duyuru, üye yönetimi, fotoğraf)
- [x] **Duyuru sistemi** — Admin tarafından oluşturulur, tüm kullanıcılara bildirim gider
- [x] **Anket sistemi** — Çoklu seçenek, oy verme, süre sınırlı, kısıtlama bazlı
- [x] **Profil düzenleme** — Fotoğraf URL, kan grubu, doğum tarihi, acil durum bilgileri, alerji
- [x] **Üye onaylama** — Admin panelinden yeni üyelerin onaylanması

---

## 5. Bu Aşamada Yapılan Düzeltmeler (Antigravity Tarafından)

### 5.1 Statik Analiz Temizliği
- **Başlangıç:** `flutter analyze` → 34 uyarı (tamamı `info` seviyesinde)
- **Bitiş:** `flutter analyze` → **0 uyarı** ✅

### 5.2 Detaylı Düzeltme Listesi

| # | Dosya | Düzeltme | Kategori |
|---|-------|----------|----------|
| 1 | `auth_screen.dart:121` | Async gap sonrası `if (!mounted) return;` eklendi | `use_build_context_synchronously` |
| 2 | `fcm_service.dart:34` | `getToken()` için `// ignore: deprecated_member_use` eklendi | `deprecated_member_use` |
| 3 | `fcm_service.dart:45` | `onTokenRefresh` için `// ignore: deprecated_member_use` eklendi | `deprecated_member_use` |
| 4 | `main.dart` | 2 adet `print()` → `debugPrint()` | `avoid_print` |
| 5 | `app_data.dart` | 19 adet `print()` → `debugPrint()`, `foundation.dart` import eklendi | `avoid_print` |
| 6 | `fcm_service.dart` | 6 adet `print()` → `debugPrint()`, `foundation.dart` import eklendi | `avoid_print` |
| 7 | `user_model.dart:40` | `if` bloğuna süslü parantez eklendi | `curly_braces_in_flow_control_structures` |
| 8 | `games_screen.dart:699` | `if (c.mounted)` bloğuna süslü parantez eklendi | `curly_braces_in_flow_control_structures` |
| 9 | `helpers.dart:142` | `if` bloğuna süslü parantez eklendi | `curly_braces_in_flow_control_structures` |
| 10 | `common_widgets.dart:57` | `(_, __)` → `(_, _)` düzeltildi | `unnecessary_underscores` |

### 5.3 Test Yazımı
4 dosyada toplam **23 test** yazıldı, tamamı başarılı:

| Test Dosyası | Test Sayısı | Kapsam |
|-------------|-------------|--------|
| `test/models/user_model_test.dart` | 4 | toMap/fromMap round-trip, age getter, null safety |
| `test/models/game_model_test.dart` | 3 | toMap/fromMap round-trip, varsayılan değerler, null safety |
| `test/services/helpers_test.dart` | 13 | userCanJoin, restrictionLabel, isEtkinlikPlayer, fmtDT, fmtDur |
| `test/services/survey_logic_test.dart` | 3 | Oy verme mantığı, toMap/fromMap round-trip, seçenek sayısı |

---

## 6. Karşılaşılan Sorunlar ve Çözümleri (Kronolojik)

### 6.1 Firebase Parse Hataları
- **Sorun:** Firestore'dan okunan veriler `null` geldiğinde `type 'Null' is not a subtype of type 'String'` hatası
- **Çözüm:** Tüm `fromMap()` fonksiyonlarına `m['key'] ?? defaultValue` kontrolleri eklendi. `DateTime.parse()` kullanımları `try-catch` ile sarmalandı.

### 6.2 flutter_local_notifications Uyumsuzluğu
- **Sorun:** SDK 37 ile `compileSdk` çakışması, sürekli derleme hatası
- **Çözüm:** Paket tamamen kaldırıldı. Uygulama açıkken bildirimler sadece konsola yazdırılıyor.

### 6.3 AndroidManifest İzin Hataları
- **Sorun:** Android 13+ (API 33) için `POST_NOTIFICATIONS` izni eksik
- **Çözüm:** `AndroidManifest.xml` dosyasına `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` eklendi.

### 6.4 Gradle / compileSdk Çakışmaları
- **Sorun:** Firebase eklentileri farklı `compileSdk` sürümleri gerektiriyordu
- **Çözüm:** `android/app/build.gradle` dosyasında `compileSdk` ve `targetSdk` değerleri uyumlu hale getirildi.

### 6.5 Firestore Güvenlik Kuralı Reddi
- **Sorun:** Admin işlemleri `PERMISSION_DENIED` hatası veriyordu
- **Çözüm:** `isAdminEmail()` fonksiyonu `request.resource.data` üzerinden admin e-posta ve admin isim kontrolü yapacak şekilde güncellendi.

### 6.6 Monolitik main.dart Parçalanması
- **Sorun:** Yaklaşık 5000 satırlık tek dosya
- **Çözüm:** Modüler mimariye geçildi. Models, services, screens, widgets klasörlerine bölündü. `main.dart` ~280 satıra düşürüldü.

### 6.7 Android 12+ Splash Ekranı Yuvarlak Logo
- **Sorun:** Android 12+ otomatik olarak uygulama ikonunu splash'te gösteriyordu
- **Çözüm:** `values-v31/styles.xml` oluşturularak splash ikon transparant yapıldı.

### 6.8 Deprecated FCM API'leri
- **Sorun:** `getToken()` ve `onTokenRefresh` uyarıları
- **Çözüm:** `// ignore: deprecated_member_use` ile susturuldu. Fonksiyonel sorun yok, Firebase ekibi güncelleyince kaldırılacak.

---

## 7. Firestore Koleksiyon Yapısı

### `users/{email}`
Kullanıcı profil verileri. Doküman ID'si kullanıcının e-posta adresidir.

```dart
{
  'code': String,           // Takım kodu (BB01, BB02 vb.)
  'name': String,           // Çağrı adı / kod adı
  'email': String,          // E-posta adresi (giriş + doküman ID)
  'pass': String,           // 🔴 Düz metin şifre (güvenlik açığı!)
  'role': String,           // Oyun rolü (Rifleman, Keskin Nişancı, Destek vb.)
  'status': String,         // Katılım durumu (Geliyorum, Gelmiyorum, Belirsiz)
  'squad': String,          // Manga (Sekban Takımı, Acemi Ocağı, Atanmadı)
  'isAdmin': bool,          // Yönetici yetkisi
  'isApproved': bool,       // Üyelik onayı (admin tarafından)
  'membershipType': String, // Üyelik tipi (Sekban, Acemi, Etkinlik)
  'bloodType': String,      // Kan grubu
  'birthDate': String?,     // ISO 8601 doğum tarihi
  'emergencyName': String,  // Acil durum kişisi adı
  'emergencyPhone': String, // Acil durum telefonu
  'allergies': String,      // Alerji bilgisi
  'photoUrl': String,       // Profil fotoğrafı URL
  'squadRole': String,      // Manga rolü (Yok, Kaptan, Kaptan Yardımcısı)
  'kvkkOnay': bool,         // KVKK onayı verildi mi
  'fcmToken': String?,      // FCM push bildirim tokeni (FCM tarafından eklenir)
}
```

### `games/{gameId}`
Oyun verileri. Aktif oyun: `teamsAssigned == false`, geçmiş oyun: `teamsAssigned == true`.

```dart
{
  'id': String,                        // Benzersiz oyun ID (timestamp bazlı)
  'title': String,                     // Oyun başlığı
  'scenario': String,                  // Senaryo açıklaması
  'location': String,                  // Konum adı
  'latitude': double?,                 // Enlem (harita için)
  'longitude': double?,                // Boylam (harita için)
  'gameDate': String,                  // ISO 8601 oyun tarihi
  'surveyDeadline': String,            // ISO 8601 anket son tarihi
  'isSurveyOpen': bool,                // Anket hala açık mı
  'teamsAssigned': bool,               // Takımlar atandı mı (false=aktif, true=geçmiş)
  'participationRestriction': String,  // Katılım kısıtlaması (all, team, acemi, sekban, etkinlik)
  'surveyRestriction': String,         // Anket kısıtlaması
  'assignments': Map<String, String>,  // {email: takımAdı} atamaları
  'weapons': Map<String, String>,      // {email: silahTipi} seçimleri
  'statuses': Map<String, String>,     // {email: katılımDurumu} bilgisi
  'noShows': List<String>,             // Gelmeyenlerin e-postaları
  'isAttendanceApproved': bool,        // Yoklama onaylandı mı
  'approvedAttendees': List<String>,   // Onaylanan katılımcılar
}
```

### `surveys/{surveyId}`
Anket verileri (karar anketleri, oylama).

```dart
{
  'id': String,                     // Benzersiz anket ID
  'title': String,                  // Anket başlığı
  'description': String,            // Açıklama
  'type': String,                   // Anket tipi (Karar vb.)
  'endDate': String,                // ISO 8601 bitiş tarihi
  'options': List<Map>,             // [{id: '0', text: 'Evet'}, ...] seçenekler
  'votes': Map<String, String>,     // {email: seçenekId} oyları
}
```

### `messages/{messageId}`
Kullanıcılar arası özel mesajlar.

```dart
{
  'id': String,          // Benzersiz mesaj ID
  'fromEmail': String,   // Gönderenin e-postası
  'toEmail': String,     // Alıcının e-postası
  'text': String,        // Mesaj metni
  'timestamp': String,   // ISO 8601 zaman damgası
  'isRead': bool,        // Okundu mu
}
```

### `badges/{badgeId}`
Rozet tanımları (sistemdeki tüm rozetler).

```dart
{
  'id': String,          // Rozet ID (b1, b2 vb.)
  'name': String,        // Rozet adı (İlk Oyun, Veteran vb.)
  'description': String, // Açıklama
  'iconName': String,    // Material ikon adı (star, military_tech vb.)
  'color': String,       // Renk adı (amber, green, purple vb.)
  'autoRule': String,    // Otomatik atama kuralı (first_game, veteran_10, loyal, none)
}
```

### `userBadges/{id}`
Kullanıcılara atanmış rozetler (çoktan-çoğa ilişki).

```dart
{
  'id': String,          // Benzersiz kayıt ID
  'userEmail': String,   // Kullanıcı e-postası
  'badgeId': String,     // Rozet ID (badges koleksiyonuna referans)
  'assignedAt': String,  // ISO 8601 atanma tarihi
}
```

### `inventory/{itemId}`
Takım envanteri (silahlar, korumalar, iletişim ekipmanları).

```dart
{
  'id': String,        // Envanter ID
  'name': String,      // Malzeme adı (M4A1 AEG, Koruyucu Gözlük vb.)
  'category': String,  // Kategori (Silah, Koruma, Komünikasyon)
  'owner': String,     // Zimmetli kişi ('-' = boşta)
}
```

### `zimmetLogs/{id}`
Envanter teslim/iade geçmişi.

```dart
{
  'id': String,         // Log ID
  'itemName': String,   // Malzeme adı
  'userName': String,   // Teslim alan/iade eden kişi
  'action': String,     // İşlem tipi (Teslim, İade vb.)
  'adminName': String,  // İşlemi yapan admin
  'timestamp': String,  // ISO 8601 zaman damgası
}
```

### `gameSummaries/{id}`
Oyun sonrası özet istatistikleri.

```dart
{
  'id': String,                     // Özet ID
  'gameTitle': String,              // Oyun başlığı
  'gameDate': String,               // ISO 8601 oyun tarihi
  'attendance': int,                // Katılımcı sayısı
  'weaponCounts': Map<String, int>, // {silahTipi: kullanımSayısı}
}
```

### `announcements/{id}`
Admin duyuruları.

```dart
{
  'id': String,          // Duyuru ID
  'title': String,       // Başlık
  'content': String,     // İçerik
  'adminEmail': String,  // Oluşturan admin
  'createdAt': String,   // ISO 8601 oluşturma tarihi
  'isActive': bool,      // Aktif mi (gizleme için)
}
```

### `notifs/{id}`
Uygulama içi bildirimler (in-app, FCM değil).

```dart
{
  'id': String,          // Bildirim ID
  'userEmail': String,   // Hedef kullanıcı
  'type': String,        // Tip (game, badge, message vb.)
  'title': String,       // Başlık
  'message': String,     // Mesaj metni
  'timestamp': String,   // ISO 8601 zaman damgası
  'isRead': bool,        // Okundu mu
}
```

### `photos/{id}`
Fotoğraf galerisi.

```dart
{
  'id': String,             // Fotoğraf ID
  'url': String,            // Fotoğraf URL
  'title': String,          // Başlık
  'gameId': String,         // İlişkili oyun (opsiyonel)
  'uploaderEmail': String,  // Yükleyen kişi
  'uploadedAt': String,     // ISO 8601 yükleme tarihi
}
```

---

## 8. Cloud Functions Detayları

Dosya: `functions/index.js` — Node.js, Firebase Admin SDK

### Ortak Yardımcı: `sendNotification(tokens, title, body)`
Verilen FCM token listesine `sendEachForMulticast` ile toplu bildirim gönderir.

### 8.1 `sendAnnouncementNotification`
- **Tetikleyici:** `onDocumentCreated("announcements/{announcementId}")`
- **Ne yapar:** Yeni bir duyuru oluşturulduğunda `users` koleksiyonundaki tüm `fcmToken`'ları toplar ve duyuru başlığı + içeriğiyle toplu bildirim gönderir.

### 8.2 `sendMessageNotification`
- **Tetikleyici:** `onDocumentCreated("messages/{messageId}")`
- **Ne yapar:** Yeni mesaj oluşturulduğunda alıcının (`toEmail`) `fcmToken`'ını bulur, gönderenin adını çeker ve kısa mesaj metniyle (max 40 karakter) bildirim gönderir.

### 8.3 `sendNewGameNotification`
- **Tetikleyici:** `onDocumentCreated("games/{gameId}")`
- **Ne yapar:** Yeni oyun oluşturulduğunda (sadece `teamsAssigned == false` olan aktif oyunlar için) tüm kullanıcılara oyun başlığı, tarihi ve anket açıldığı bilgisiyle bildirim gönderir.

### 8.4 `sendTeamAssignedNotification`
- **Tetikleyici:** `onDocumentUpdated("games/{gameId}")`
- **Ne yapar:** Bir oyun dokümanında `teamsAssigned` alanı `false` → `true` olarak değiştiğinde her oyuncuya kendi atandığı takımı bildiren kişiselleştirilmiş bildirim gönderir.

### Cloud Functions Kodu (Tam):

```javascript
const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();
const db = getFirestore();

async function sendNotification(tokens, title, body) {
    if (!tokens || tokens.length === 0) {
        console.log("Gönderilecek token yok.");
        return;
    }
    const message = {
        notification: { title: title, body: body },
        tokens: tokens,
    };
    try {
        const response = await getMessaging().sendEachForMulticast(message);
        console.log(`✅ ${response.successCount} başarılı, ${response.failureCount} başarısız.`);
    } catch (error) {
        console.error("❌ Bildirim gönderme hatası:", error);
    }
}

exports.sendAnnouncementNotification = onDocumentCreated("announcements/{announcementId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return null;
    const announcement = snapshot.data();
    const usersSnapshot = await db.collection("users").get();
    const tokens = [];
    usersSnapshot.forEach(doc => {
        const userData = doc.data();
        if (userData.fcmToken) tokens.push(userData.fcmToken);
    });
    await sendNotification(tokens, `📢 Yeni Duyuru: ${announcement.title}`, announcement.content);
    return null;
});

exports.sendMessageNotification = onDocumentCreated("messages/{messageId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return null;
    const msg = snapshot.data();
    const receiverDoc = await db.collection("users").doc(msg.toEmail).get();
    if (!receiverDoc.exists) return null;
    const receiverData = receiverDoc.data();
    if (!receiverData.fcmToken) return null;
    const senderDoc = await db.collection("users").doc(msg.fromEmail).get();
    const senderName = senderDoc.exists ? senderDoc.data().name : "Bir kullanıcı";
    const shortText = msg.text.length > 40 ? msg.text.substring(0, 40) + "..." : msg.text;
    await sendNotification([receiverData.fcmToken], `💬 ${senderName}`, shortText);
    return null;
});

exports.sendNewGameNotification = onDocumentCreated("games/{gameId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return null;
    const game = snapshot.data();
    if (game.teamsAssigned) return null;
    const usersSnapshot = await db.collection("users").get();
    const tokens = [];
    usersSnapshot.forEach(doc => {
        const userData = doc.data();
        if (userData.fcmToken) tokens.push(userData.fcmToken);
    });
    const dateStr = new Date(game.gameDate).toLocaleDateString('tr-TR');
    await sendNotification(tokens, `🎯 Yeni Oyun: ${game.title}`, `Tarih: ${dateStr}. Anket şimdi açıldı, katılmayı unutma!`);
    return null;
});

exports.sendTeamAssignedNotification = onDocumentUpdated("games/{gameId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (!before.teamsAssigned && after.teamsAssigned) {
        const usersSnapshot = await db.collection("users").get();
        const userMap = {};
        usersSnapshot.forEach(doc => { userMap[doc.id] = doc.data(); });
        for (const [email, team] of Object.entries(after.assignments)) {
            const userData = userMap[email];
            if (userData && userData.fcmToken && team !== '-') {
                const title = `🛡️ Takımın Belli Oldu: ${team}`;
                const body = `${after.title} oyunu için takımın ${team} olarak atandı. İyi oyunlar!`;
                await sendNotification([userData.fcmToken], title, body);
            }
        }
    }
    return null;
});
```

---

## 9. Firestore Güvenlik Kuralları

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAdminEmail() {
      return request.resource.data.adminEmail == 'alialtun333@gmail.com' ||
             request.resource.data.email == 'alialtun333@gmail.com' ||
             request.resource.data.adminName == 'Kurt';
    }

    match /users/{userId} {
      allow read: if true;                                          // Herkes okuyabilir
      allow update: if request.resource.data.email == resource.data.email; // Sadece kendi profilini güncelleyebilir
      allow delete: if isAdminEmail();                              // Sadece admin silebilir
      allow create: if true;                                        // Herkes kayıt olabilir
    }

    match /games/{gameId} {
      allow read: if true;                                          // Herkes okuyabilir
      allow write: if isAdminEmail();                               // Sadece admin yazabilir
    }

    match /announcements/{announcementId} {
      allow read: if true;
      allow write: if isAdminEmail();
    }

    match /surveys/{surveyId} {
      allow read: if true;
      allow update: if true;                                        // Herkes oy verebilir
      allow create, delete: if isAdminEmail();
    }

    match /messages/{messageId} {
      allow read: if true;
      allow create: if true;                                        // Herkes mesaj gönderebilir
      allow update, delete: if false;                               // Mesajlar silinemez/düzenlenemez
    }

    match /notifs/{notifId} {
      allow read: if true;
      allow update: if true;                                        // Okundu işaretlemek için
      allow create, delete: if isAdminEmail();
    }

    match /inventory/{itemId} {
      allow read: if true;
      allow write: if isAdminEmail();
    }

    match /badges/{badgeId} {
      allow read: if true;
      allow write: if isAdminEmail();
    }

    match /zimmetLogs/{logId} {
      allow read: if true;
      allow write: if isAdminEmail();
    }

    match /gameSummaries/{summaryId} {
      allow read: if true;
      allow write: if isAdminEmail();
    }

    match /userBadges/{userBadgeId} {
      allow read: if true;
      allow write: if isAdminEmail();
    }

    match /{document=**} {
      allow read, write: if false;                                  // Diğer her şey kapalı
    }
  }
}
```

### Kural Açıklamaları

- **`isAdminEmail()`:** Yazma işlemlerinde admin kontrolü yapar. `request.resource.data` içinde `adminEmail`, `email` veya `adminName` alanlarına bakarak admin yetkisini doğrular.
- 🔴 **Güvenlik notu:** Bu kurallar Firebase Authentication kullanmadığı için istemci tarafından manipüle edilebilir. `request.resource.data` içindeki alanlar istemcinin gönderdiği veridir, sunucu tarafı doğrulama DEĞİLDİR. Firebase Auth'a geçildiğinde `request.auth.uid` bazlı kurallara geçilmelidir.

---

## 10. Bilinen Sorunlar ve Uyarılar

> 🔴 **Bu bölüm kritiktir. Yeni geliştirici veya AI bu maddeleri mutlaka okumalıdır.**

1. 🔴 **Firebase Authentication YOK** — Şifreler Firestore'da düz metin olarak saklanıyor. Bu ciddi bir güvenlik açığıdır. Herhangi bir Firestore okuma yetkisi olan kişi tüm şifreleri görebilir. Firebase Auth'a geçiş en yüksek önceliktir.

2. 🔴 **flutter_local_notifications kaldırıldı** — SDK 37 ile uyumsuzluk nedeniyle paket kaldırıldı. Uygulama **açıkken** gelen FCM bildirimleri sadece konsola yazdırılıyor, kullanıcıya görsel bildirim gösterilmiyor. Uygulama **kapalıyken** veya arka plandayken FCM bildirimleri düzgün çalışıyor.

3. 🔴 **Paket adı `com.example.basibozuklar_v1`** — Google Play Store `com.example.*` paket adlarını reddeder. Yayın öncesi `com.basibozuklar.app` veya benzeri bir isme değiştirilmeli. **DİKKAT:** Paket adı değişikliği Firebase yapılandırmasını, `google-services.json` dosyasını ve `AndroidManifest.xml` dosyasını etkiler.

4. 🔴 **Release key YOK** — Sadece debug APK çıkarılabiliyor. Google Play yayını için release keystore oluşturulmalı ve `build.gradle` dosyasında imzalama yapılandırılmalı.

5. 🔴 **Firestore kuralları e-posta bazlı** — Firebase Auth olmadığı için güvenlik kuralları `request.resource.data` içindeki alanlara bakıyor. Bu, istemci tarafından kolayca atlatılabilir.

6. 🔴 **iOS test edilmedi** — Geliştirme tamamen Windows + Android emülatör üzerinde yapıldı. iOS'ta test edilmedi, `Podfile` ve iOS-specific yapılandırmalar doğrulanmadı.

7. 🔴 **Türkçe karakter değişken adlarında kullanılmamalı** — `ı`, `ş`, `ğ`, `ü`, `ö`, `ç` karakterleri değişken/fonksiyon adlarında derleme sorunlarına yol açabilir. String değerlerde kullanılabilir.

8. ⚠️ **firebase_core KGP Uyarısı** — Flutter gelecekte "Built-in Kotlin"e geçiyor, Firebase eklentileri henüz uyumlu değil. Bilinen uyarı, görmezden gelin. Firebase ekibi güncelleme yayınlayınca kaybolacak.

---

## 11. Test Hesapları

### Admin Hesabı
| E-posta | Şifre | Çağrı Adı | Rol |
|---------|-------|-----------|-----|
| `kurt@bb.com` | `123` | Kurt | Takım Lideri (Admin) |

### Firestore Rules Admin E-postası
`alialtun333@gmail.com` — Güvenlik kurallarında hardcoded admin e-postası.

### Üye Hesapları (Tümünün şifresi: `123`)

| Kod | Çağrı Adı | E-posta | Üyelik | Manga |
|-----|-----------|---------|--------|-------|
| BB01 | Kurt | kurt@bb.com | Sekban | Sekban Takımı |
| BB02 | Atmaca | atmaca@bb.com | Acemi | Acemi Ocağı |
| BB03 | Şahin | sahin@bb.com | Sekban | Sekban Takımı |
| BB04 | Bozkurt | bozkurt@bb.com | Acemi | Atanmadı |
| BB05 | Yılan | yilan@bb.com | Etkinlik | Atanmadı |
| BB06 | Poyraz | poyraz@bb.com | Acemi | Acemi Ocağı |

---

## 12. Sıradaki Adımlar (Öncelik Sırasıyla)

- [ ] Firebase Authentication'a geçiş (şifreleri düz metinden kurtarma)
- [ ] Paket adı değişikliği (`com.example.basibozuklar_v1` → `com.basibozuklar.app`)
- [ ] Release key oluşturma ve APK imzalama
- [ ] `awesome_notifications` eklenmesi (uygulama açıkken görsel bildirim)
- [ ] Fotoğraf galerisi ekranı (Firebase Storage entegrasyonu)
- [ ] Zimmet Excel export
- [ ] Anket sonuçlarında pasta grafik
- [ ] iOS testi ve yayını
- [ ] PWA yayını (Firebase Hosting veya GitHub Pages)
- [ ] Google Play Store yayını

---

## 13. Başka Bir AI'ya Devir Notu

> **Bu proje modüler mimaridir.** `main.dart` ~280 satır olup sadece uygulama başlangıcı, Stream yönetimi ve tema içerir. Modeller `lib/models/`, servisler `lib/services/`, ekranlar `lib/screens/`, ortak widget'lar `lib/widgets/` altındadır.
>
> **Firebase Firestore + Cloud Functions + FCM aktif.** Tüm veriler Firestore'da tutulur, Cloud Functions bildirim tetikleyicisi olarak çalışır.
>
> **Türkçe karakter değişken adlarında kullanılmamalı** (`ı`, `ş`, `ğ`, `ü`, `ö`, `ç`).
>
> **Firebase Auth YOK** — şifreler düz metin. Bu projenin en kritik güvenlik eksikliğidir.
>
> **`flutter_local_notifications` kaldırıldı** — SDK 37 uyumsuzluğu. Geri ekleme denenmemeli, yerine `awesome_notifications` kullanılmalı.
>
> **Her yeni özellik eklemeden önce mevcut testleri çalıştır:** `flutter test` (23 test mevcut).
>
> **Her değişiklikten sonra:** `flutter analyze` çalıştır ve 0 uyarı olduğunu doğrula.
>
> **Paket adına (applicationId, namespace, `com.example.*`) dokunma** — bu değişiklik Firebase yapılandırmasını bozar, planlı yapılmalı.

---

## 14. Geliştirme Ortamı

| Bileşen | Yol / Değer |
|---------|------------|
| Flutter SDK | `C:\src\flutter` (3.47.9 stable) |
| Dart SDK | `C:\src\flutter\bin\cache\dart-sdk` (3.13.7) |
| Java (JDK 21) | `C:\Program Files\Microsoft\jdk-21.0.13.21-hotspot` |
| Android SDK | Android Studio SDK Manager tarafından yönetilir |
| NDK | 28.2.13676358 |
| Proje Dizini | `C:\Users\P26JBR\Desktop\mobil proje BB\basibozuklar_v1` |
| Firebase Proje ID | `basibozuklar26` |
| Emülatör | Pixel 7 (API 37, android-x64, `emulator-5554`) |
| IDE | VS Code + Flutter eklentisi |
| Git | 2.56.0 |
| OS | Windows 10 Pro 64-bit (22H2) |

---

## 15. Dosya Satır Sayıları

### Kaynak Dosyaları (`lib/`)

| Dosya | Satır Sayısı | Açıklama |
|-------|-------------|----------|
| `main.dart` | 279 | Uygulama giriş noktası, streams, tema |
| `firebase_options.dart` | 95 | Firebase yapılandırması (otomatik üretildi) |
| **models/** | | |
| `user_model.dart` | 86 | Kullanıcı modeli |
| `game_model.dart` | 83 | Oyun modeli |
| `survey_model.dart` | 49 | Anket modeli |
| `badge_model.dart` | 59 | Rozet + Kullanıcı-Rozet modeli |
| `notif_model.dart` | 37 | Bildirim modeli |
| `announcement_model.dart` | 34 | Duyuru modeli |
| `message_model.dart` | 34 | Mesaj modeli |
| `photo_model.dart` | 33 | Fotoğraf modeli |
| `zimmet_log_model.dart` | 33 | Zimmet log modeli |
| `game_summary_model.dart` | 32 | Oyun özet modeli |
| `inventory_model.dart` | 24 | Envanter modeli |
| **screens/** | | |
| `admin_screen.dart` | 1612 | Yönetim paneli (7 accordion) |
| `games_screen.dart` | 1248 | Oyun detayları ve geçmiş |
| `survey_screen.dart` | 929 | Anket akışı, liste, oluşturma |
| `home_screen.dart` | 782 | Ana sayfa |
| `profile_screen.dart` | 742 | Profil düzenleme |
| `auth_screen.dart` | 621 | Giriş/kayıt ekranı |
| `team_screen.dart` | 592 | Kadro listesi |
| `main_shell.dart` | 516 | Alt navigasyon çubuğu |
| `game_summary_screen.dart` | 475 | Oyun özet istatistikleri |
| `team_assignment_screen.dart` | 440 | Takım atama |
| `inventory_screen.dart` | 307 | Envanter ve zimmet |
| `rules_screen.dart` | 279 | Takım kuralları |
| `info_screen.dart` | 276 | Bilgi bankası |
| `messages_screen.dart` | 269 | Mesajlaşma |
| `notif_screen.dart` | 227 | Bildirimler |
| **services/** | | |
| `app_data.dart` | 442 | Global veriler, Firestore ilk yükleme |
| `helpers.dart` | 269 | Yardımcı fonksiyonlar |
| `firestore_service.dart` | 180 | Firestore CRUD stream sınıfı |
| `fcm_service.dart` | 58 | FCM token yönetimi |
| **widgets/** | | |
| `common_widgets.dart` | 72 | Avatar ve bildirim çanı |
| **TOPLAM** | **10,482** | |

### Diğer Dosyalar

| Dosya | Satır Sayısı |
|-------|-------------|
| `functions/index.js` | 127 |
| `firestore.rules` | 71 |
| `firebase.json` | 19 |
| `pubspec.yaml` | 56 |
| `analysis_options.yaml` | 38 |

### Test Dosyaları

| Dosya | Satır Sayısı | Test Sayısı |
|-------|-------------|-------------|
| `test/models/user_model_test.dart` | 82 | 4 |
| `test/models/game_model_test.dart` | 75 | 3 |
| `test/services/helpers_test.dart` | 122 | 13 |
| `test/services/survey_logic_test.dart` | 74 | 3 |
| **TOPLAM** | **353** | **23** |

---

*Bu arşiv dosyası Antigravity tarafından 12.11.2026 tarihinde oluşturulmuştur.*
