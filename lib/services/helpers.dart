import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/notif_model.dart';
import '../models/badge_model.dart';
import '../models/zimmet_log_model.dart';
import '../models/game_summary_model.dart';
import '../models/game_model.dart';
import '../models/announcement_model.dart';
import 'app_data.dart';

// ============================================================
// YARDIMCILAR
// ============================================================

String uid() => DateTime.now().microsecondsSinceEpoch.toString();

String fmtDT(DateTime d) {
  String t(int n) => n.toString().padLeft(2, '0');
  return '${t(d.day)}/${t(d.month)}/${d.year} - ${t(d.hour)}:${t(d.minute)}';
}

String fmtDur(Duration d) {
  String t(int n) => n.toString().padLeft(2, '0');
  if (d.inDays > 0) {
    return '${d.inDays}g ${t(d.inHours.remainder(24))}s ${t(d.inMinutes.remainder(60))}d ${t(d.inSeconds.remainder(60))}sn';
  }
  return '${t(d.inHours)}s ${t(d.inMinutes.remainder(60))}d ${t(d.inSeconds.remainder(60))}sn';
}

void notifyU(String email, String type, String title, String msg) {
  final notif = NotifModel(
    id: uid(),
    userEmail: email,
    type: type,
    title: title,
    message: msg,
    timestamp: DateTime.now(),
  );
  notifs.insert(0, notif);
  // Firestore'a yaz
  firestoreDb.collection('notifs').doc(notif.id).set(notif.toMap());
}

void notifyAll(String type, String title, String msg) {
  for (var u in users) {
    notifyU(u.email, type, title, msg);
  }
}

int unreadN(String email) =>
    notifs.where((n) => n.userEmail == email && !n.isRead).length;

int unreadMsg(String email) =>
    messages.where((m) => m.toEmail == email && !m.isRead).length;

IconData badgeIcon(String name) {
  switch (name) {
    case 'star':
      return Icons.star;
    case 'gps_fixed':
      return Icons.gps_fixed;
    case 'favorite':
      return Icons.favorite;
    case 'person_add':
      return Icons.person_add;
    case 'military_tech':
      return Icons.military_tech;
    case 'shield':
      return Icons.shield;
    case 'bolt':
      return Icons.bolt;
    case 'whatshot':
      return Icons.whatshot;
    case 'emoji_events':
      return Icons.emoji_events;
    default:
      return Icons.workspace_premium;
  }
}

Color badgeColor(String name) {
  switch (name) {
    case 'amber':
      return Colors.amber;
    case 'green':
      return Colors.green;
    case 'blue':
      return Colors.blue;
    case 'red':
      return Colors.red;
    case 'purple':
      return Colors.purple;
    case 'orange':
      return Colors.orange;
    default:
      return Colors.amber;
  }
}

List<BadgeModel> getUserBadges(String email) {
  return userBadges
      .where((ub) => ub.userEmail == email)
      .map(
        (ub) => badges.firstWhere(
          (b) => b.id == ub.badgeId,
          orElse: () => badges[0],
        ),
      )
      .toList();
}

List<AnnouncementModel> getActiveAnnouncements() {
  var list = announcements.where((a) => a.isActive).toList();
  list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return list;
}

void addZimmetLog(
  String itemName,
  String userName,
  String action,
  String adminName,
) {
  final log = ZimmetLogModel(
    id: uid(),
    itemName: itemName,
    userName: userName,
    action: action,
    adminName: adminName,
    timestamp: DateTime.now(),
  );
  zimmetLogs.insert(0, log);
  // Firestore'a yaz
  firestoreDb.collection('zimmetLogs').doc(log.id).set(log.toMap());
}

void assignBadge(String userEmail, String badgeId, {bool isAuto = false}) {
  if (userBadges.any(
    (ub) => ub.userEmail == userEmail && ub.badgeId == badgeId,
  )) {
    return;
  }
  final ub = UserBadgeModel(
    id: uid(),
    userEmail: userEmail,
    badgeId: badgeId,
    assignedAt: DateTime.now(),
  );
  userBadges.add(ub);
  // Firestore'a yaz
  firestoreDb.collection('userBadges').doc(ub.id).set(ub.toMap());
  if (!isAuto) {
    notifyU(
      userEmail,
      'badge',
      'Yeni Rozet Kazandın!',
      'Yönetici tarafından sana bir rozet verildi.',
    );
  } else {
    notifyU(
      userEmail,
      'badge',
      'Otomatik Rozet Kazandın!',
      'Yeni bir başarı rozeti kazandın!',
    );
  }
}

void checkAutoBadges(String userEmail) {
  var userPastGames = pastGames
      .where(
        (g) =>
            g.isAttendanceApproved && g.approvedAttendees.contains(userEmail),
      )
      .toList();
  int totalGames = userPastGames.length;

  for (var b in badges) {
    if (b.autoRule == 'none') continue;

    if (b.autoRule == 'first_game' && totalGames >= 1) {
      assignBadge(userEmail, b.id, isAuto: true);
    } else if (b.autoRule == 'veteran_10' && totalGames >= 10) {
      assignBadge(userEmail, b.id, isAuto: true);
    } else if (b.autoRule == 'loyal') {
      int expected = pastGames
          .where((g) => g.statuses[userEmail] == 'Geliyorum')
          .length;
      int attended = userPastGames.length;
      if (expected > 0 && attended == expected) {
        assignBadge(userEmail, b.id, isAuto: true);
      }
    } else if (b.autoRule == 'sniper_master') {
      int sniperCount = userPastGames
          .where((g) => g.weapons[userEmail] == 'Bolt action')
          .length;
      if (sniperCount >= 10) {
        assignBadge(userEmail, b.id, isAuto: true);
      }
    }
  }
}

void removeBadge(String userEmail, String badgeId) {
  userBadges.removeWhere(
    (ub) => ub.userEmail == userEmail && ub.badgeId == badgeId,
  );
}

void createGameSummary(GameModel game) {
  final attendance = game.approvedAttendees.length;
  final weaponCounts = <String, int>{};
  for (var email in game.approvedAttendees) {
    var w = game.weapons[email];
    if (w != null && w.isNotEmpty) {
      weaponCounts[w] = (weaponCounts[w] ?? 0) + 1;
    }
  }
  final summary = GameSummaryModel(
    id: uid(),
    gameTitle: game.title,
    gameDate: game.gameDate,
    attendance: attendance,
    weaponCounts: weaponCounts,
  );
  gameSummaries.insert(0, summary);
  // Firestore'a yaz
  firestoreDb.collection('gameSummaries').doc(summary.id).set(summary.toMap());
}

bool userCanJoin(UserModel u, String restriction) {
  switch (restriction) {
    case 'all':
      return true;
    case 'team':
      return u.membershipType != 'Etkinlik';
    case 'acemi':
      return u.membershipType == 'Acemi' ||
          u.membershipType == 'Sekban' ||
          u.isAdmin;
    case 'sekban':
      return u.membershipType == 'Sekban' || u.isAdmin;
    case 'etkinlik':
      return true;
    default:
      return true;
  }
}

String restrictionLabel(String r) {
  switch (r) {
    case 'all':
      return 'Herkes';
    case 'team':
      return 'Takım Üyeleri';
    case 'acemi':
      return 'Acemi + Sekban';
    case 'sekban':
      return 'Sadece Sekban';
    case 'etkinlik':
      return 'Sadece Etkinlik';
    default:
      return 'Herkes';
  }
}

bool isEtkinlikPlayer(UserModel u) =>
    u.membershipType == 'Etkinlik' && !u.isAdmin;
