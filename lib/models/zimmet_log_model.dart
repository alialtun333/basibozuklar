class ZimmetLogModel {
  String id, itemName, userName, action, adminName;
  DateTime timestamp;

  ZimmetLogModel({
    required this.id,
    required this.itemName,
    required this.userName,
    required this.action,
    required this.adminName,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'itemName': itemName,
    'userName': userName,
    'action': action,
    'adminName': adminName,
    'timestamp': timestamp.toIso8601String(),
  };

  static ZimmetLogModel fromMap(Map<String, dynamic> m) => ZimmetLogModel(
    id: m['id'] ?? '',
    itemName: m['itemName'] ?? '',
    userName: m['userName'] ?? '',
    action: m['action'] ?? '',
    adminName: m['adminName'] ?? '',
    timestamp: m['timestamp'] != null
        ? DateTime.parse(m['timestamp'])
        : DateTime.now(),
  );
}
