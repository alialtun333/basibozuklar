class GameSummaryModel {
  String id, gameTitle;
  DateTime gameDate;
  int attendance;
  Map<String, int> weaponCounts;

  GameSummaryModel({
    required this.id,
    required this.gameTitle,
    required this.gameDate,
    required this.attendance,
    Map<String, int>? weaponCounts,
  }) : weaponCounts = weaponCounts ?? {};

  Map<String, dynamic> toMap() => {
    'id': id,
    'gameTitle': gameTitle,
    'gameDate': gameDate.toIso8601String(),
    'attendance': attendance,
    'weaponCounts': weaponCounts,
  };

  static GameSummaryModel fromMap(Map<String, dynamic> m) => GameSummaryModel(
    id: m['id'] ?? '',
    gameTitle: m['gameTitle'] ?? '',
    gameDate: m['gameDate'] != null
        ? DateTime.parse(m['gameDate'])
        : DateTime.now(),
    attendance: m['attendance'] ?? 0,
    weaponCounts: Map<String, int>.from(m['weaponCounts'] ?? {}),
  );
}
