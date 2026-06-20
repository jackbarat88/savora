import '/models/transaction_type.dart';
import '/utils/id_generator.dart';

class CategoryModel {
  final String id;
  final String? userId;
  final String name;
  final TransactionType type;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.createdAt,
  });

  factory CategoryModel.create({
    String? userId,
    required String name,
    required TransactionType type,
  }) {
    return CategoryModel(
      id: IdGenerator.generate(),
      userId: userId,
      name: name,
      type: type,
      createdAt: DateTime.now(),
    );
  }

  bool get isDefault => userId == null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromMap(Map<dynamic, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      userId: map['userId'] as String?,
      name: map['name'] as String,
      type: TransactionTypeX.fromString(map['type'] as String?),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
