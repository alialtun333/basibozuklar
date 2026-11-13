class UserModel {
  String code, name, email, pass, role, status, squad;
  bool isAdmin;
  bool isApproved;
  String membershipType;
  String bloodType;
  DateTime? birthDate;
  String emergencyName, emergencyPhone, allergies;
  String photoUrl;
  String squadRole;
  bool kvkkOnay;

  UserModel({
    required this.code,
    required this.name,
    required this.email,
    required this.pass,
    required this.role,
    this.status = 'Belirsiz',
    this.squad = 'Atanmadı',
    this.isAdmin = false,
    this.isApproved = true,
    this.membershipType = 'Acemi',
    this.bloodType = '',
    this.birthDate,
    this.emergencyName = '',
    this.emergencyPhone = '',
    this.allergies = '',
    this.photoUrl = '',
    this.squadRole = 'Yok',
    this.kvkkOnay = false,
  });

  int? get age {
    if (birthDate == null) return null;
    final n = DateTime.now();
    int y = n.year - birthDate!.year;
    if (n.month < birthDate!.month ||
        (n.month == birthDate!.month && n.day < birthDate!.day)) {
      y--;
    }
    return y;
  }

  Map<String, dynamic> toMap() => {
    'code': code,
    'name': name,
    'email': email,
    'pass': pass,
    'role': role,
    'status': status,
    'squad': squad,
    'isAdmin': isAdmin,
    'isApproved': isApproved,
    'membershipType': membershipType,
    'bloodType': bloodType,
    'birthDate': birthDate?.toIso8601String(),
    'emergencyName': emergencyName,
    'emergencyPhone': emergencyPhone,
    'allergies': allergies,
    'photoUrl': photoUrl,
    'squadRole': squadRole,
    'kvkkOnay': kvkkOnay,
  };

  static UserModel fromMap(Map<String, dynamic> m) => UserModel(
    code: m['code'] ?? '',
    name: m['name'] ?? '',
    email: m['email'] ?? '',
    pass: m['pass'] ?? '',
    role: m['role'] ?? '',
    status: m['status'] ?? 'Belirsiz',
    squad: m['squad'] ?? 'Atanmadı',
    isAdmin: m['isAdmin'] ?? false,
    isApproved: m['isApproved'] ?? true,
    membershipType: m['membershipType'] ?? 'Acemi',
    bloodType: m['bloodType'] ?? '',
    birthDate: m['birthDate'] != null ? DateTime.parse(m['birthDate']) : null,
    emergencyName: m['emergencyName'] ?? '',
    emergencyPhone: m['emergencyPhone'] ?? '',
    allergies: m['allergies'] ?? '',
    photoUrl: m['photoUrl'] ?? '',
    squadRole: m['squadRole'] ?? 'Yok',
    kvkkOnay: m['kvkkOnay'] ?? false,
  );
}
