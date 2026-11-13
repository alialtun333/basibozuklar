class NotifModel {
  String id, userEmail, type, title, message;
  DateTime timestamp;
  bool isRead;

  NotifModel({
    required this.id,
    required this.userEmail,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userEmail': userEmail,
    'type': type,
    'title': title,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  static NotifModel fromMap(Map<String, dynamic> m) => NotifModel(
    id: m['id'] ?? '',
    userEmail: m['userEmail'] ?? '',
    type: m['type'] ?? 'game',
    title: m['title'] ?? '',
    message: m['message'] ?? '',
    timestamp: m['timestamp'] != null
        ? DateTime.parse(m['timestamp'])
        : DateTime.now(),
    isRead: m['isRead'] ?? false,
  );
}
