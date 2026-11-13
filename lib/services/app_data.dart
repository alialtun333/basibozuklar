import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/game_model.dart';
import '../models/survey_model.dart';
import '../models/message_model.dart';
import '../models/inventory_model.dart';
import '../models/notif_model.dart';
import '../models/badge_model.dart';
import '../models/zimmet_log_model.dart';
import '../models/game_summary_model.dart';
import '../models/announcement_model.dart';
import '../models/photo_model.dart';

// ============================================================
// OTURUM
// ============================================================
String? savedEmail;
String? savedPass;
bool rememberGlobal = false;
bool kvkkOnaylandi = false;

// ============================================================
// FIRESTORE INSTANCE
// ============================================================
final FirebaseFirestore firestoreDb = FirebaseFirestore.instance;

// ============================================================
// MOCK VERİLER (İlk kurulumda kullanılır)
// ============================================================
List<UserModel> users = [
  UserModel(
    code: 'BB01',
    name: 'Kurt',
    email: 'kurt@bb.com',
    pass: '123',
    role: 'Takım Lideri',
    status: 'Geliyorum',
    squad: 'Sekban Takımı',
    isAdmin: true,
    isApproved: true,
    membershipType: 'Sekban',
    bloodType: 'A+',
    birthDate: DateTime(1990, 5, 12),
    emergencyName: 'Ayşe Kurt',
    emergencyPhone: '05321112233',
    allergies: 'Penisilin',
    squadRole: 'Kaptan',
  ),
  UserModel(
    code: 'BB02',
    name: 'Atmaca',
    email: 'atmaca@bb.com',
    pass: '123',
    role: 'Keskin Nişancı',
    status: 'Geliyorum',
    squad: 'Acemi Ocağı',
    membershipType: 'Acemi',
    bloodType: '0+',
    birthDate: DateTime(1995, 8, 22),
  ),
  UserModel(
    code: 'BB03',
    name: 'Şahin',
    email: 'sahin@bb.com',
    pass: '123',
    role: 'Rifleman',
    status: 'Geliyorum',
    squad: 'Sekban Takımı',
    membershipType: 'Sekban',
    bloodType: 'B-',
    birthDate: DateTime(1988, 3, 5),
    squadRole: 'Kaptan Yardımcısı',
  ),
  UserModel(
    code: 'BB04',
    name: 'Bozkurt',
    email: 'bozkurt@bb.com',
    pass: '123',
    role: 'Destek',
    status: 'Belirsiz',
    membershipType: 'Acemi',
    bloodType: 'AB+',
    birthDate: DateTime(1992, 11, 30),
  ),
  UserModel(
    code: 'BB05',
    name: 'Yılan',
    email: 'yilan@bb.com',
    pass: '123',
    role: 'Rifleman',
    status: 'Gelmiyorum',
    membershipType: 'Etkinlik',
  ),
  UserModel(
    code: 'BB06',
    name: 'Poyraz',
    email: 'poyraz@bb.com',
    pass: '123',
    role: 'Rifleman',
    status: 'Geliyorum',
    squad: 'Acemi Ocağı',
    membershipType: 'Acemi',
    bloodType: 'A-',
    birthDate: DateTime(2000, 7, 18),
  ),
];

const List<String> weaponList = [
  'CQB',
  'Assault',
  'DMR',
  'Bolt action',
  'LMG',
  'SMG',
  'GBB',
];
const List<String> bloodTypes = [
  'A+',
  'A-',
  'B+',
  'B-',
  'AB+',
  'AB-',
  '0+',
  '0-',
];
const List<String> squadOptions = ['Atanmadı', 'Sekban Takımı', 'Acemi Ocağı'];
const List<String> membershipTypes = ['Sekban', 'Acemi', 'Etkinlik'];
const List<String> restrictionOptions = [
  'all',
  'team',
  'acemi',
  'sekban',
  'etkinlik',
];
const List<String> squadRoleOptions = ['Yok', 'Kaptan', 'Kaptan Yardımcısı'];

List<GameModel> pastGames = [];
GameModel? activeGame;

List<InventoryModel> inventoryList = [
  InventoryModel(id: 'i1', name: 'M4A1 AEG', category: 'Silah'),
  InventoryModel(id: 'i2', name: 'AK-47 AEG', category: 'Silah'),
  InventoryModel(id: 'i3', name: 'Koruyucu Gözlük', category: 'Koruma'),
  InventoryModel(id: 'i4', name: 'Yüz Maskesi', category: 'Koruma'),
  InventoryModel(id: 'i5', name: 'Baofeng Telsiz', category: 'Komünikasyon'),
];

List<SurveyModel> surveys = [];
List<MessageModel> messages = [];
List<NotifModel> notifs = [];

List<BadgeModel> badges = [
  BadgeModel(
    id: 'b1',
    name: 'İlk Oyun',
    description: 'İlk oyununa katıldın!',
    iconName: 'star',
    color: 'amber',
    autoRule: 'first_game',
  ),
  BadgeModel(
    id: 'b2',
    name: 'Keskin Nişancı',
    description: '10 oyunda Bolt action kullandın',
    iconName: 'gps_fixed',
    color: 'green',
    autoRule: 'sniper_master',
  ),
  BadgeModel(
    id: 'b3',
    name: 'Veteran',
    description: '10+ oyuna katıldın',
    iconName: 'military_tech',
    color: 'purple',
    autoRule: 'veteran_10',
  ),
  BadgeModel(
    id: 'b4',
    name: 'Yeni Yüz',
    description: 'Takıma yeni katıldın',
    iconName: 'person_add',
    color: 'blue',
    autoRule: 'none',
  ),
  BadgeModel(
    id: 'b5',
    name: 'Sadık Üye',
    description: 'Hiç oyun kaçırmadın',
    iconName: 'favorite',
    color: 'red',
    autoRule: 'loyal',
  ),
];

List<UserBadgeModel> userBadges = [];
List<ZimmetLogModel> zimmetLogs = [];
List<GameSummaryModel> gameSummaries = [];
List<AnnouncementModel> announcements = [];
List<PhotoModel> photos = [];

// ============================================================
// FIRESTORE'DAN TÜM VERİLERİ YÜKLE
// ============================================================
Future<void> loadAllDataFromFirestore() async {
  try {
    final userCheck = await firestoreDb.collection('users').get();

    if (userCheck.docs.isEmpty) {
      debugPrint('🔥 Firestore boş, ilk kurulum yapılıyor...');
      for (var u in users) {
        await firestoreDb.collection('users').doc(u.email).set(u.toMap());
      }
      for (var b in badges) {
        await firestoreDb.collection('badges').doc(b.id).set(b.toMap());
      }
      for (var i in inventoryList) {
        await firestoreDb.collection('inventory').doc(i.id).set(i.toMap());
      }
      debugPrint('✅ İlk kurulum tamamlandı (${users.length} kullanıcı)');
    } else {
      debugPrint('📥 Firestore verileri yükleniyor...');
      users = userCheck.docs.map((d) => UserModel.fromMap(d.data())).toList();
      debugPrint('✅ ${users.length} kullanıcı yüklendi');

      try {
        final badgesSnap = await firestoreDb.collection('badges').get();
        if (badgesSnap.docs.isNotEmpty) {
          badges = badgesSnap.docs
              .map((d) {
                try {
                  return BadgeModel.fromMap(d.data());
                } catch (_) {
                  return null;
                }
              })
              .whereType<BadgeModel>()
              .toList();
        }
      } catch (e) {
        debugPrint('Badges: $e');
      }

      try {
        final invSnap = await firestoreDb.collection('inventory').get();
        if (invSnap.docs.isNotEmpty) {
          inventoryList = invSnap.docs
              .map((d) {
                try {
                  return InventoryModel.fromMap(d.data());
                } catch (_) {
                  return null;
                }
              })
              .whereType<InventoryModel>()
              .toList();
        }
      } catch (e) {
        debugPrint('Inventory: $e');
      }

      try {
        final gamesSnap = await firestoreDb.collection('games').get();
        if (gamesSnap.docs.isNotEmpty) {
          final allGames = <GameModel>[];
          for (var doc in gamesSnap.docs) {
            try {
              allGames.add(GameModel.fromMap(doc.data()));
            } catch (e) {
              debugPrint('⚠️ Bozuk oyun atlandı: ${doc.id} - $e');
            }
          }
          pastGames = allGames.where((g) => g.teamsAssigned).toList();
          activeGame = null;
          for (var g in allGames) {
            if (!g.teamsAssigned) {
              activeGame = g;
              break;
            }
          }
        }
      } catch (e) {
        debugPrint('Games: $e');
      }

      try {
        final surveysSnap = await firestoreDb.collection('surveys').get();
        if (surveysSnap.docs.isNotEmpty) {
          surveys = surveysSnap.docs
              .map((d) {
                try {
                  return SurveyModel.fromMap(d.data());
                } catch (e) {
                  debugPrint('⚠️ Bozuk anket: ${d.id}');
                  return null;
                }
              })
              .whereType<SurveyModel>()
              .toList();
        }
      } catch (e) {
        debugPrint('Surveys: $e');
      }

      try {
        final msgsSnap = await firestoreDb.collection('messages').get();
        if (msgsSnap.docs.isNotEmpty) {
          messages = msgsSnap.docs
              .map((d) {
                try {
                  return MessageModel.fromMap(d.data());
                } catch (_) {
                  return null;
                }
              })
              .whereType<MessageModel>()
              .toList();
        }
      } catch (e) {
        debugPrint('Messages: $e');
      }

      try {
        final notifsSnap = await firestoreDb.collection('notifs').get();
        if (notifsSnap.docs.isNotEmpty) {
          notifs = notifsSnap.docs
              .map((d) {
                try {
                  return NotifModel.fromMap(d.data());
                } catch (_) {
                  return null;
                }
              })
              .whereType<NotifModel>()
              .toList();
        }
      } catch (e) {
        debugPrint('Notifs: $e');
      }

      try {
        final userBadgesSnap = await firestoreDb.collection('userBadges').get();
        if (userBadgesSnap.docs.isNotEmpty) {
          userBadges = userBadgesSnap.docs
              .map((d) {
                try {
                  return UserBadgeModel.fromMap(d.data());
                } catch (_) {
                  return null;
                }
              })
              .whereType<UserBadgeModel>()
              .toList();
        }
      } catch (e) {
        debugPrint('UserBadges: $e');
      }

      try {
        final zimmetSnap = await firestoreDb.collection('zimmetLogs').get();
        if (zimmetSnap.docs.isNotEmpty) {
          zimmetLogs = zimmetSnap.docs
              .map((d) {
                try {
                  return ZimmetLogModel.fromMap(d.data());
                } catch (_) {
                  return null;
                }
              })
              .whereType<ZimmetLogModel>()
              .toList();
        }
      } catch (e) {
        debugPrint('ZimmetLogs: $e');
      }

      try {
        final summariesSnap = await firestoreDb
            .collection('gameSummaries')
            .get();
        if (summariesSnap.docs.isNotEmpty) {
          gameSummaries = summariesSnap.docs
              .map((d) {
                try {
                  return GameSummaryModel.fromMap(d.data());
                } catch (_) {
                  return null;
                }
              })
              .whereType<GameSummaryModel>()
              .toList();
        }
      } catch (e) {
        debugPrint('Summaries: $e');
      }

      try {
        final announcementsSnap = await firestoreDb
            .collection('announcements')
            .get();
        if (announcementsSnap.docs.isNotEmpty) {
          announcements = announcementsSnap.docs
              .map((d) {
                try {
                  return AnnouncementModel.fromMap(d.data());
                } catch (_) {
                  return null;
                }
              })
              .whereType<AnnouncementModel>()
              .toList();
        }
      } catch (e) {
        debugPrint('Announcements: $e');
      }

      try {
        final photosSnap = await firestoreDb.collection('photos').get();
        if (photosSnap.docs.isNotEmpty) {
          photos = photosSnap.docs
              .map((d) {
                try {
                  return PhotoModel.fromMap(d.data());
                } catch (_) {
                  return null;
                }
              })
              .whereType<PhotoModel>()
              .toList();
        }
      } catch (e) {
        debugPrint('Photos: $e');
      }

      debugPrint('✅ Tüm veriler Firestore\'dan yüklendi');
    }
  } catch (e) {
    debugPrint('❌ Firestore yükleme hatası: $e');
  }
}
