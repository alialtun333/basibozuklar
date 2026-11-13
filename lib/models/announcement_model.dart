class AnnouncementModel {
  String id, title, content, adminEmail;
  DateTime createdAt;
  bool isActive;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.adminEmail,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'adminEmail': adminEmail,
    'createdAt': createdAt.toIso8601String(),
    'isActive': isActive,
  };

  static AnnouncementModel fromMap(Map<String, dynamic> m) => AnnouncementModel(
    id: m['id'] ?? '',
    title: m['title'] ?? '',
    content: m['content'] ?? '',
    adminEmail: m['adminEmail'] ?? '',
    createdAt: m['createdAt'] != null
        ? DateTime.parse(m['createdAt'])
        : DateTime.now(),
    isActive: m['isActive'] ?? true,
  );
}
