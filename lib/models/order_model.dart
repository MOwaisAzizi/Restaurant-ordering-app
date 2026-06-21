class OrderModel {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.total,
    required this.itemCount,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final double total;
  final int itemCount;
  final DateTime createdAt;

  factory OrderModel.fromMap(Map<String, Object?> map) {
    return OrderModel(
      id: map['id'] as int,
      userId: map['userId'] as int,
      total: (map['total'] as num).toDouble(),
      itemCount: map['itemCount'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
