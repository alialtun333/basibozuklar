class SurveyOption {
  String id, text;
  SurveyOption({required this.id, required this.text});

  Map<String, dynamic> toMap() => {'id': id, 'text': text};
  static SurveyOption fromMap(Map<String, dynamic> m) =>
      SurveyOption(id: m['id'] ?? '', text: m['text'] ?? '');
}

class SurveyModel {
  String id, title, description, type;
  DateTime endDate;
  List<SurveyOption> options;
  Map<String, String> votes;

  SurveyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.endDate,
    required this.options,
    Map<String, String>? votes,
  }) : votes = votes ?? {};

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type,
    'endDate': endDate.toIso8601String(),
    'options': options.map((o) => o.toMap()).toList(),
    'votes': votes,
  };

  static SurveyModel fromMap(Map<String, dynamic> m) => SurveyModel(
    id: m['id'] ?? '',
    title: m['title'] ?? '',
    description: m['description'] ?? '',
    type: m['type'] ?? 'Karar',
    endDate: m['endDate'] != null
        ? DateTime.parse(m['endDate'])
        : DateTime.now(),
    options: (m['options'] as List? ?? [])
        .map((o) => SurveyOption.fromMap(Map<String, dynamic>.from(o)))
        .toList(),
    votes: Map<String, String>.from(m['votes'] ?? {}),
  );
}
