class SellerModel {
  final String id;
  final String userId;
  final String storeName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SellerModel({
    required this.id,
    required this.userId,
    required this.storeName,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'storeName': storeName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory SellerModel.fromMap(Map<String, dynamic> map) {
    return SellerModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      storeName: map['storeName'] ?? '',
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}
