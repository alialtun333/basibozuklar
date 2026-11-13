class MessageModel {
  String id, fromEmail, toEmail, text;
  DateTime timestamp;
  bool isRead;

  MessageModel({
    required this.id,
    required this.fromEmail,
    required this.toEmail,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'fromEmail': fromEmail,
    'toEmail': toEmail,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  static MessageModel fromMap(Map<String, dynamic> m) => MessageModel(
    id: m['id'] ?? '',
    fromEmail: m['fromEmail'] ?? '',
    toEmail: m['toEmail'] ?? '',
    text: m['text'] ?? '',
    timestamp: m['timestamp'] != null
        ? DateTime.parse(m['timestamp'])
        : DateTime.now(),
    isRead: m['isRead'] ?? false,
  );
}
