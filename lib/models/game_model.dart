class GameModel {
  String id, title, scenario, location;
  double? latitude;
  double? longitude;
  DateTime gameDate, surveyDeadline;
  bool isSurveyOpen, teamsAssigned;
  String participationRestriction, surveyRestriction;
  Map<String, String> assignments, weapons, statuses;
  List<String> noShows;
  bool isAttendanceApproved;
  List<String> approvedAttendees;

  GameModel({
    required this.id,
    required this.title,
    required this.gameDate,
    required this.surveyDeadline,
    this.isSurveyOpen = true,
    this.teamsAssigned = false,
    this.participationRestriction = 'all',
    this.surveyRestriction = 'all',
    Map<String, String>? assignments,
    Map<String, String>? weapons,
    Map<String, String>? statuses,
    List<String>? noShows,
    this.scenario = '',
    this.location = '',
    this.latitude,
    this.longitude,
    this.isAttendanceApproved = false,
    List<String>? approvedAttendees,
  }) : assignments = assignments ?? {},
       weapons = weapons ?? {},
       statuses = statuses ?? {},
       noShows = noShows ?? [],
       approvedAttendees = approvedAttendees ?? [];

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'scenario': scenario,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'gameDate': gameDate.toIso8601String(),
    'surveyDeadline': surveyDeadline.toIso8601String(),
    'isSurveyOpen': isSurveyOpen,
    'teamsAssigned': teamsAssigned,
    'participationRestriction': participationRestriction,
    'surveyRestriction': surveyRestriction,
    'assignments': assignments,
    'weapons': weapons,
    'statuses': statuses,
    'noShows': noShows,
    'isAttendanceApproved': isAttendanceApproved,
    'approvedAttendees': approvedAttendees,
  };

  static GameModel fromMap(Map<String, dynamic> m) => GameModel(
    id: m['id'] ?? '',
    title: m['title'] ?? '',
    gameDate: m['gameDate'] != null
        ? DateTime.parse(m['gameDate'])
        : DateTime.now(),
    surveyDeadline: m['surveyDeadline'] != null
        ? DateTime.parse(m['surveyDeadline'])
        : DateTime.now(),
    isSurveyOpen: m['isSurveyOpen'] ?? true,
    teamsAssigned: m['teamsAssigned'] ?? false,
    participationRestriction: m['participationRestriction'] ?? 'all',
    surveyRestriction: m['surveyRestriction'] ?? 'all',
    assignments: Map<String, String>.from(m['assignments'] ?? {}),
    weapons: Map<String, String>.from(m['weapons'] ?? {}),
    statuses: Map<String, String>.from(m['statuses'] ?? {}),
    noShows: List<String>.from(m['noShows'] ?? []),
    scenario: m['scenario'] ?? '',
    location: m['location'] ?? '',
    latitude: (m['latitude'] as num?)?.toDouble(),
    longitude: (m['longitude'] as num?)?.toDouble(),
    isAttendanceApproved: m['isAttendanceApproved'] ?? false,
    approvedAttendees: List<String>.from(m['approvedAttendees'] ?? []),
  );
}
