class CartItemModel {
  const CartItemModel({
    required this.cartId,
    required this.userId,
    required this.menuItemId,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.quantity,
  });

  final int cartId;
  final int userId;
  final int menuItemId;
  final int restaurantId;
  final String name;
  final String description;
  final double price;
  final String image;
  final int quantity;

  double get subtotal => price * quantity;

  factory CartItemModel.fromJoinedMap(Map<String, Object?> map) {
    return CartItemModel(
      cartId: map['cartId'] as int,
      userId: map['userId'] as int,
      menuItemId: map['menuItemId'] as int,
      restaurantId: map['restaurantId'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      image: map['image'] as String,
      quantity: map['quantity'] as int,
    );
  }
}
