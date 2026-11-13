import 'package:flutter_test/flutter_test.dart';
import 'package:basibozuklar_v1/models/game_model.dart';

void main() {
  group('GameModel', () {
    test('toMap ve fromMap round-trip testi', () {
      final game = GameModel(
        id: 'g1',
        title: 'Test Oyunu',
        scenario: 'Test senaryo',
        location: 'Test Konum',
        latitude: 39.766,
        longitude: 30.525,
        gameDate: DateTime(2025, 12, 25, 14, 0),
        surveyDeadline: DateTime(2025, 12, 20, 20, 0),
        isSurveyOpen: true,
        teamsAssigned: false,
        participationRestriction: 'all',
        surveyRestriction: 'team',
        assignments: {'a@b.com': 'Sarı'},
        weapons: {'a@b.com': 'Assault'},
        statuses: {'a@b.com': 'Geliyorum'},
        noShows: ['c@d.com'],
      );

      final map = game.toMap();
      final restored = GameModel.fromMap(map);

      expect(restored.id, 'g1');
      expect(restored.title, 'Test Oyunu');
      expect(restored.latitude, 39.766);
      expect(restored.longitude, 30.525);
      expect(restored.teamsAssigned, false);
      expect(restored.assignments['a@b.com'], 'Sarı');
      expect(restored.weapons['a@b.com'], 'Assault');
    });

    test('Varsayılan değerler doğru', () {
      final game = GameModel(
        id: 'g2',
        title: 'Test',
        gameDate: DateTime.now(),
        surveyDeadline: DateTime.now().add(const Duration(days: 7)),
      );
      expect(game.isSurveyOpen, true);
      expect(game.teamsAssigned, false);
      expect(game.participationRestriction, 'all');
      expect(game.surveyRestriction, 'all');
      expect(game.scenario, '');
      expect(game.location, '');
      expect(game.assignments.isEmpty, true);
      expect(game.weapons.isEmpty, true);
      expect(game.statuses.isEmpty, true);
      expect(game.noShows.isEmpty, true);
      expect(game.isAttendanceApproved, false);
      expect(game.approvedAttendees.isEmpty, true);
    });

    test('Boş map ile fromMap çalışıyor (null güvenliği)', () {
      final now = DateTime.now();
      final map = {
        'gameDate': now.toIso8601String(),
        'surveyDeadline': now.toIso8601String(),
      };
      final game = GameModel.fromMap(map);
      expect(game.id, '');
      expect(game.title, '');
      expect(game.latitude, isNull);
      expect(game.longitude, isNull);
    });
  });
}
