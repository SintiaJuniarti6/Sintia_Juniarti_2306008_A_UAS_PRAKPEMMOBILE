class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
  });

  // Mengubah JSON dari API jadi objek UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: _parseRole(json['role'] ?? json['roles']),
    );
  }

  // Handle field role, bisa berupa String ("customer") ATAU object nested
  // (misalnya {"id": "...", "name": "customer"} hasil join ke tabel roles)
  static String _parseRole(dynamic value) {
    if (value == null) return 'customer';
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['name']?.toString() ?? 'customer';
    }
    return 'customer';
  }

  // Mengubah objek UserModel jadi JSON (dipakai kalau perlu kirim balik ke API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }

  // Cek apakah user ini admin (dipakai buat Soal 5 Admin Dashboard)
  bool get isAdmin => role == 'admin';
}