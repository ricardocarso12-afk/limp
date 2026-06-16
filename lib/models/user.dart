class User {
  final int id;
  final String name;
  final String email;
  final String role;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      name: '${json['name'] ?? ''}',
      email: '${json['email'] ?? ''}',
      role: '${json['role'] ?? json['role_slug'] ?? ''}',
    );
  }
}
