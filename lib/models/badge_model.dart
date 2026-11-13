class BadgeModel {
  String id, name, description, iconName, color;
  String autoRule;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.color = 'amber',
    this.autoRule = 'none',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'iconName': iconName,
    'color': color,
    'autoRule': autoRule,
  };

  static BadgeModel fromMap(Map<String, dynamic> m) => BadgeModel(
    id: m['id'] ?? '',
    name: m['name'] ?? '',
    description: m['description'] ?? '',
    iconName: m['iconName'] ?? 'star',
    color: m['color'] ?? 'amber',
    autoRule: m['autoRule'] ?? 'none',
  );
}

class UserBadgeModel {
  String id, userEmail, badgeId;
  DateTime assignedAt;

  UserBadgeModel({
    required this.id,
    required this.userEmail,
    required this.badgeId,
    required this.assignedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userEmail': userEmail,
    'badgeId': badgeId,
    'assignedAt': assignedAt.toIso8601String(),
  };

  static UserBadgeModel fromMap(Map<String, dynamic> m) => UserBadgeModel(
    id: m['id'] ?? '',
    userEmail: m['userEmail'] ?? '',
    badgeId: m['badgeId'] ?? '',
    assignedAt: m['assignedAt'] != null
        ? DateTime.parse(m['assignedAt'])
        : DateTime.now(),
  );
}
