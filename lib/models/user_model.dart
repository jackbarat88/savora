import '/utils/id_generator.dart';

class UserModel {
  final String id;
  final String fullName;
  final String username;
  final String passwordHash;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.passwordHash,
    required this.createdAt,
  });

  factory UserModel.create({
    required String fullName,
    required String username,
    required String passwordHash,
  }) {
    return UserModel(
      id: IdGenerator.generate(),
      fullName: fullName,
      username: username,
      passwordHash: passwordHash,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      username: map['username'] as String,
      passwordHash: map['passwordHash'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
