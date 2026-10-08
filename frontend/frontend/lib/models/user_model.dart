enum UserType { student, teacher }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserType type;
  final bool isFacialRegistered;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    this.isFacialRegistered = false,
  });
}
