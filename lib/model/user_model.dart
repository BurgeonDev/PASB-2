class UserModel {
  int? id;
  String username;
  String phone;
  String? email;
  String password;
  String role;
  String rank;
  String? dateEntry;
  String? province;
  String? dasb;
  String? district;
  String? directorate;
  String? nationWideValue;

  // New fields
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;

  UserModel({
    this.id,
    required this.username,
    required this.phone,
    this.email,
    required this.password,
    required this.role,
    required this.rank,
    this.dateEntry,
    this.province,
    this.dasb,
    this.district,
    this.directorate,
    this.nationWideValue,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  // ✅ Add copyWith method
  UserModel copyWith({
    int? id,
    String? username,
    String? phone,
    String? email,
    String? password,
    String? role,
    String? rank,
    String? dateEntry,
    String? province,
    String? dasb,
    String? district,
    String? directorate,
    String? nationWideValue,
    String? createdBy,
    String? createdAt,
    String? updatedBy,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      rank: rank ?? this.rank,
      dateEntry: dateEntry ?? this.dateEntry,
      province: province ?? this.province,
      dasb: dasb ?? this.dasb,
      district: district ?? this.district,
      directorate: directorate ?? this.directorate,
      nationWideValue: nationWideValue ?? this.nationWideValue,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'phone': phone,
      'email': email,
      'password': password,
      'role': role,
      'rank': rank,
      'date_entry': dateEntry,
      'province': province,
      'dasb': dasb ?? '',
      'district': district ?? '',
      'directorate': directorate ?? '',
      'nation_wide_value': nationWideValue ?? '',
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      phone: map['phone'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      rank: map['rank'],
      dateEntry: map['date_entry'],
      province: map['province'],
      dasb: map['dasb'],
      district: map['district'],
      directorate: map['directorate'],
      nationWideValue: map['nation_wide_value'],
      createdBy: map['created_by'],
      createdAt: map['created_at'],
      updatedBy: map['updated_by'],
      updatedAt: map['updated_at'],
    );
  }

  @override
  String toString() {
    return 'UserModel(username: $username, phone: $phone, email: $email, password: $password, role: $role, rank: $rank, '
        'dateEntry: $dateEntry, province: $province, dasb: $dasb, district: $district, directorate: $directorate, '
        'nationWideValue: $nationWideValue, createdBy: $createdBy, createdAt: $createdAt, '
        'updatedBy: $updatedBy, updatedAt: $updatedAt)';
  }
}
