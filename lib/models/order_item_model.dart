class OrderItemModel {
  const OrderItemModel({
    this.id,
    required this.orderId,
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });

  final int? id;
  final int orderId;
  final int menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String image;

  double get subtotal => price * quantity;

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'orderId': orderId,
      'menuItemId': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }
}
