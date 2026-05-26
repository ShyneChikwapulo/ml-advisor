class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role;

  UserModel({
    //named paraaters, this variable is accesess by you calling it explicitly
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> jsonData) {
    return UserModel(
      uid: jsonData['uid'],
      email: jsonData['email'],
      displayName: jsonData['displayName'],
      role: jsonData['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
    };
  }

  bool get isAdmin =>
      role ==
      'admin'; //using 'get' allows us to to call isAdmin like a variable(user.isAdmin) isntead fo like a function: user.isAdmin()
}
