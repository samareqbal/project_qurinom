class UserModel {
  final String id;
  final String email;
  final String role;
  final String? token;

  UserModel({required this.id, required this.email, required this.role, this.token});

  factory UserModel.fromJson(Map<String, dynamic> j) {
    final data = j['data'] ?? j;
    return UserModel(
      id: (data['_id'] ?? data['id'] ?? '') as String,
      email: (data['email'] ?? j['email'] ?? '') as String,
      role: (j['role'] ?? data['role'] ?? '') as String,
      token: (j['token'] ?? data['token']) as String?,
    );
  }
}
