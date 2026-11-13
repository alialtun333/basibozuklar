class PhotoModel {
  String id, url, title, gameId, uploaderEmail;
  DateTime uploadedAt;

  PhotoModel({
    required this.id,
    required this.url,
    required this.title,
    this.gameId = '',
    required this.uploaderEmail,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'url': url,
    'title': title,
    'gameId': gameId,
    'uploaderEmail': uploaderEmail,
    'uploadedAt': uploadedAt.toIso8601String(),
  };

  static PhotoModel fromMap(Map<String, dynamic> m) => PhotoModel(
    id: m['id'] ?? '',
    url: m['url'] ?? '',
    title: m['title'] ?? '',
    gameId: m['gameId'] ?? '',
    uploaderEmail: m['uploaderEmail'] ?? '',
    uploadedAt: m['uploadedAt'] != null
        ? DateTime.parse(m['uploadedAt'])
        : DateTime.now(),
  );
}
