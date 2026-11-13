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

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // KULLANICILAR
  // ============================================================
  Stream<List<UserModel>> usersStream() {
    return _db
        .collection('users')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => UserModel.fromMap(d.data())).toList(),
        );
  }

  Future<List<UserModel>> getUsers() async {
    final snap = await _db.collection('users').get();
    return snap.docs.map((d) => UserModel.fromMap(d.data())).toList();
  }

  Future<void> setUser(UserModel user) =>
      _db.collection('users').doc(user.email).set(user.toMap());

  Future<void> deleteUser(String email) =>
      _db.collection('users').doc(email).delete();

  // ============================================================
  // OYUNLAR (Aktif + Geçmiş)
  // ============================================================
  Stream<List<GameModel>> gamesStream() {
    return _db
        .collection('games')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => GameModel.fromMap(d.data())).toList(),
        );
  }

  Future<List<GameModel>> getGames() async {
    final snap = await _db.collection('games').get();
    return snap.docs.map((d) => GameModel.fromMap(d.data())).toList();
  }

  Future<void> setGame(GameModel game) =>
      _db.collection('games').doc(game.id).set(game.toMap());

  Future<void> deleteGame(String id) =>
      _db.collection('games').doc(id).delete();

  // ============================================================
  // ANKETLER (Özel anketler)
  // ============================================================
  Future<List<SurveyModel>> getSurveys() async {
    final snap = await _db.collection('surveys').get();
    return snap.docs.map((d) => SurveyModel.fromMap(d.data())).toList();
  }

  Future<void> setSurvey(SurveyModel s) =>
      _db.collection('surveys').doc(s.id).set(s.toMap());

  Future<void> deleteSurvey(String id) =>
      _db.collection('surveys').doc(id).delete();

  // ============================================================
  // MESAJLAR
  // ============================================================
  Future<List<MessageModel>> getMessages() async {
    final snap = await _db.collection('messages').get();
    return snap.docs.map((d) => MessageModel.fromMap(d.data())).toList();
  }

  Future<void> setMessage(MessageModel m) =>
      _db.collection('messages').doc(m.id).set(m.toMap());

  // ============================================================
  // ENVANTER
  // ============================================================
  Future<List<InventoryModel>> getInventory() async {
    final snap = await _db.collection('inventory').get();
    return snap.docs.map((d) => InventoryModel.fromMap(d.data())).toList();
  }

  Future<void> setInventory(InventoryModel i) =>
      _db.collection('inventory').doc(i.id).set(i.toMap());

  // ============================================================
  // BİLDİRİMLER
  // ============================================================
  Future<List<NotifModel>> getNotifs() async {
    final snap = await _db.collection('notifs').get();
    return snap.docs.map((d) => NotifModel.fromMap(d.data())).toList();
  }

  Future<void> setNotif(NotifModel n) =>
      _db.collection('notifs').doc(n.id).set(n.toMap());

  // ============================================================
  // ROZETLER
  // ============================================================
  Future<List<BadgeModel>> getBadges() async {
    final snap = await _db.collection('badges').get();
    return snap.docs.map((d) => BadgeModel.fromMap(d.data())).toList();
  }

  Future<void> setBadge(BadgeModel b) =>
      _db.collection('badges').doc(b.id).set(b.toMap());

  Future<void> deleteBadge(String id) =>
      _db.collection('badges').doc(id).delete();

  // Kullanıcı-Rozet Atamaları
  Future<List<UserBadgeModel>> getUserBadges() async {
    final snap = await _db.collection('userBadges').get();
    return snap.docs.map((d) => UserBadgeModel.fromMap(d.data())).toList();
  }

  Future<void> setUserBadge(UserBadgeModel ub) =>
      _db.collection('userBadges').doc(ub.id).set(ub.toMap());

  Future<void> deleteUserBadge(String id) =>
      _db.collection('userBadges').doc(id).delete();

  // ============================================================
  // ZİMMET LOGLARI
  // ============================================================
  Future<List<ZimmetLogModel>> getZimmetLogs() async {
    final snap = await _db.collection('zimmetLogs').get();
    return snap.docs.map((d) => ZimmetLogModel.fromMap(d.data())).toList();
  }

  Future<void> setZimmetLog(ZimmetLogModel z) =>
      _db.collection('zimmetLogs').doc(z.id).set(z.toMap());

  // ============================================================
  // OYUN ÖZETLERİ
  // ============================================================
  Future<List<GameSummaryModel>> getGameSummaries() async {
    final snap = await _db.collection('gameSummaries').get();
    return snap.docs.map((d) => GameSummaryModel.fromMap(d.data())).toList();
  }

  Future<void> setGameSummary(GameSummaryModel gs) =>
      _db.collection('gameSummaries').doc(gs.id).set(gs.toMap());

  // ============================================================
  // DUYURULAR
  // ============================================================
  Future<List<AnnouncementModel>> getAnnouncements() async {
    final snap = await _db.collection('announcements').get();
    return snap.docs.map((d) => AnnouncementModel.fromMap(d.data())).toList();
  }

  Future<void> setAnnouncement(AnnouncementModel a) =>
      _db.collection('announcements').doc(a.id).set(a.toMap());

  // ============================================================
  // FOTOĞRAFLAR
  // ============================================================
  Future<List<PhotoModel>> getPhotos() async {
    final snap = await _db.collection('photos').get();
    return snap.docs.map((d) => PhotoModel.fromMap(d.data())).toList();
  }

  Future<void> setPhoto(PhotoModel p) =>
      _db.collection('photos').doc(p.id).set(p.toMap());
}
