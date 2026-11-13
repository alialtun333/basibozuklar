import 'package:flutter_test/flutter_test.dart';
import 'package:basibozuklar_v1/models/survey_model.dart';

void main() {
  group('SurveyModel', () {
    test('Oy verme mantığı: votes map güncelleniyor', () {
      final survey = SurveyModel(
        id: 's1',
        title: 'Test Anket',
        description: 'Test',
        type: 'Karar',
        endDate: DateTime.now().add(const Duration(days: 1)),
        options: [
          SurveyOption(id: '0', text: 'Evet'),
          SurveyOption(id: '1', text: 'Hayır'),
        ],
      );

      survey.votes['a@b.com'] = '0';
      survey.votes['c@d.com'] = '1';
      survey.votes['e@f.com'] = '0';

      expect(survey.votes.length, 3);
      expect(survey.votes['a@b.com'], '0');
      expect(survey.votes['c@d.com'], '1');
    });

    test('toMap ve fromMap round-trip', () {
      final survey = SurveyModel(
        id: 's1',
        title: 'Test',
        description: 'Açıklama',
        type: 'Karar',
        endDate: DateTime(2025, 12, 31),
        options: [
          SurveyOption(id: '0', text: 'Evet'),
          SurveyOption(id: '1', text: 'Hayır'),
        ],
        votes: {'a@b.com': '0'},
      );

      final map = survey.toMap();
      final restored = SurveyModel.fromMap(map);

      expect(restored.id, 's1');
      expect(restored.title, 'Test');
      expect(restored.options.length, 2);
      expect(restored.options[0].text, 'Evet');
      expect(restored.votes['a@b.com'], '0');
    });

    test('Seçenekler doğru sayılıyor', () {
      final survey = SurveyModel(
        id: 's1',
        title: 'Test',
        description: '',
        type: 'Karar',
        endDate: DateTime.now(),
        options: [
          SurveyOption(id: '0', text: 'Seçenek A'),
          SurveyOption(id: '1', text: 'Seçenek B'),
          SurveyOption(id: '2', text: 'Seçenek C'),
        ],
      );
      expect(survey.options.length, 3);
    });
  });
}
