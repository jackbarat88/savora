import '/models/transaction_type.dart';
import '/utils/id_generator.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String categoryId;
  final String categoryName;
  final TransactionType type;
  final double amount;
  final String note;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.type,
    required this.amount,
    required this.note,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.create({
    required String userId,
    required String categoryId,
    required String categoryName,
    required TransactionType type,
    required double amount,
    required String note,
    required DateTime transactionDate,
  }) {
    final now = DateTime.now();
    return TransactionModel(
      id: IdGenerator.generate(),
      userId: userId,
      categoryId: categoryId,
      categoryName: categoryName,
      type: type,
      amount: amount,
      note: note,
      transactionDate: transactionDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  TransactionModel copyWith({
    String? categoryId,
    String? categoryName,
    TransactionType? type,
    double? amount,
    String? note,
    DateTime? transactionDate,
  }) {
    return TransactionModel(
      id: id,
      userId: userId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'type': type.value,
      'amount': amount,
      'note': note,
      'transactionDate': transactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<dynamic, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      categoryId: map['categoryId'] as String,
      categoryName: map['categoryName'] as String,
      type: TransactionTypeX.fromString(map['type'] as String?),
      amount: (map['amount'] as num).toDouble(),
      note: (map['note'] as String?) ?? '',
      transactionDate: DateTime.parse(map['transactionDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
