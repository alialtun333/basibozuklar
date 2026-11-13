import 'package:flutter_test/flutter_test.dart';
import 'package:basibozuklar_v1/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('toMap ve fromMap round-trip testi', () {
      final user = UserModel(
        code: 'BB99',
        name: 'Test Kullanıcı',
        email: 'test@bb.com',
        pass: '123456',
        role: 'Rifleman',
        status: 'Geliyorum',
        squad: 'Sekban Takımı',
        isAdmin: true,
        isApproved: true,
        membershipType: 'Sekban',
        bloodType: 'A+',
        birthDate: DateTime(1995, 5, 15),
        emergencyName: 'Ali Veli',
        emergencyPhone: '05001112233',
        allergies: 'Yok',
        photoUrl: 'https://example.com/photo.jpg',
        squadRole: 'Kaptan',
        kvkkOnay: true,
      );

      final map = user.toMap();
      final restored = UserModel.fromMap(map);

      expect(restored.code, 'BB99');
      expect(restored.name, 'Test Kullanıcı');
      expect(restored.email, 'test@bb.com');
      expect(restored.isAdmin, true);
      expect(restored.bloodType, 'A+');
      expect(restored.birthDate?.year, 1995);
      expect(restored.squadRole, 'Kaptan');
      expect(restored.kvkkOnay, true);
    });

    test('age getter doğru hesaplıyor', () {
      final user = UserModel(
        code: 'BB01',
        name: 'Test',
        email: 'test@test.com',
        pass: '123',
        role: 'Test',
        birthDate: DateTime(2000, 1, 1),
      );
      final expectedAge = DateTime.now().year - 2000;
      final isBirthdayPassed = DateTime.now().month > 1 ||
          (DateTime.now().month == 1 && DateTime.now().day >= 1);
      expect(user.age, isBirthdayPassed ? expectedAge : expectedAge - 1);
    });

    test('birthDate null ise age null döner', () {
      final user = UserModel(
        code: 'BB01',
        name: 'Test',
        email: 'test@test.com',
        pass: '123',
        role: 'Test',
      );
      expect(user.age, isNull);
    });

    test('Boş map ile fromMap çalışıyor', () {
      final user = UserModel.fromMap({});
      expect(user.code, '');
      expect(user.name, '');
      expect(user.isAdmin, false);
      expect(user.isApproved, true);
      expect(user.squadRole, 'Yok');
    });
  });
}
