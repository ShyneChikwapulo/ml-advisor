class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] ?? '',
        email: json['email'] ?? '',
        displayName: json['displayName'] ?? json['display_name'] ?? '',
        role: json['role'] ?? 'student',
      );
}