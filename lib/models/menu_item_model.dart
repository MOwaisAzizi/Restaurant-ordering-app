class MenuItemModel {
  const MenuItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  final int id;
  final int restaurantId;
  final String name;
  final String description;
  final double price;
  final String image;

  factory MenuItemModel.fromMap(Map<String, Object?> map) {
    return MenuItemModel(
      id: map['id'] as int,
      restaurantId: map['restaurantId'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      image: map['image'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
    };
  }
}
