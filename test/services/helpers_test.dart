import 'package:flutter_test/flutter_test.dart';
import 'package:basibozuklar_v1/models/user_model.dart';
import 'package:basibozuklar_v1/services/helpers.dart';

void main() {
  group('userCanJoin', () {
    UserModel makeUser(String membership, {bool isAdmin = false}) => UserModel(
          code: 'BB01',
          name: 'Test',
          email: 'test@test.com',
          pass: '123',
          role: 'Test',
          membershipType: membership,
          isAdmin: isAdmin,
        );

    test("'all' kısıtlaması herkesi kabul eder", () {
      expect(userCanJoin(makeUser('Sekban'), 'all'), true);
      expect(userCanJoin(makeUser('Acemi'), 'all'), true);
      expect(userCanJoin(makeUser('Etkinlik'), 'all'), true);
    });

    test("'team' kısıtlaması Etkinlik oyuncusunu reddeder", () {
      expect(userCanJoin(makeUser('Sekban'), 'team'), true);
      expect(userCanJoin(makeUser('Acemi'), 'team'), true);
      expect(userCanJoin(makeUser('Etkinlik'), 'team'), false);
    });

    test("'acemi' kısıtlaması Etkinlik oyuncusunu reddeder", () {
      expect(userCanJoin(makeUser('Sekban'), 'acemi'), true);
      expect(userCanJoin(makeUser('Acemi'), 'acemi'), true);
      expect(userCanJoin(makeUser('Etkinlik'), 'acemi'), false);
      expect(userCanJoin(makeUser('Etkinlik', isAdmin: true), 'acemi'), true);
    });

    test("'sekban' kısıtlaması sadece Sekban'ı kabul eder", () {
      expect(userCanJoin(makeUser('Sekban'), 'sekban'), true);
      expect(userCanJoin(makeUser('Acemi'), 'sekban'), false);
      expect(userCanJoin(makeUser('Acemi', isAdmin: true), 'sekban'), true);
    });

    test("'etkinlik' kısıtlaması herkesi kabul eder", () {
      expect(userCanJoin(makeUser('Sekban'), 'etkinlik'), true);
      expect(userCanJoin(makeUser('Etkinlik'), 'etkinlik'), true);
    });
  });

  group('restrictionLabel', () {
    test('Tüm değerler için Türkçe etiket döner', () {
      expect(restrictionLabel('all'), 'Herkes');
      expect(restrictionLabel('team'), 'Takım Üyeleri');
      expect(restrictionLabel('acemi'), 'Acemi + Sekban');
      expect(restrictionLabel('sekban'), 'Sadece Sekban');
      expect(restrictionLabel('etkinlik'), 'Sadece Etkinlik');
      expect(restrictionLabel('bilinmeyen'), 'Herkes');
    });
  });

  group('isEtkinlikPlayer', () {
    test('Etkinlik oyuncusu true döner', () {
      final user = UserModel(
        code: 'BB01',
        name: 'Test',
        email: 'test@test.com',
        pass: '123',
        role: 'Test',
        membershipType: 'Etkinlik',
      );
      expect(isEtkinlikPlayer(user), true);
    });

    test('Admin Etkinlik olsa bile false döner', () {
      final user = UserModel(
        code: 'BB01',
        name: 'Test',
        email: 'test@test.com',
        pass: '123',
        role: 'Test',
        membershipType: 'Etkinlik',
        isAdmin: true,
      );
      expect(isEtkinlikPlayer(user), false);
    });

    test('Sekban false döner', () {
      final user = UserModel(
        code: 'BB01',
        name: 'Test',
        email: 'test@test.com',
        pass: '123',
        role: 'Test',
        membershipType: 'Sekban',
      );
      expect(isEtkinlikPlayer(user), false);
    });
  });

  group('fmtDT', () {
    test('Tarih-saat formatı doğru', () {
      final d = DateTime(2025, 3, 15, 14, 30);
      expect(fmtDT(d), '15/03/2025 - 14:30');
    });

    test('Tek haneli gün/ay/saat sıfırla doldurulur', () {
      final d = DateTime(2025, 1, 5, 9, 5);
      expect(fmtDT(d), '05/01/2025 - 09:05');
    });
  });

  group('fmtDur', () {
    test('Saat bazlı süre formatı', () {
      expect(fmtDur(const Duration(hours: 2, minutes: 30, seconds: 15)), '02s 30d 15sn');
    });

    test('Gün bazlı süre formatı', () {
      expect(fmtDur(const Duration(days: 2, hours: 5, minutes: 30, seconds: 15)), '2g 05s 30d 15sn');
    });
  });
}
