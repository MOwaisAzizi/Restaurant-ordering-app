class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.rating,
  });

  final int id;
  final String name;
  final String image;
  final String description;
  final double rating;

  factory Restaurant.fromMap(Map<String, Object?> map) {
    return Restaurant(
      id: map['id'] as int,
      name: map['name'] as String,
      image: map['image'] as String,
      description: map['description'] as String,
      rating: (map['rating'] as num).toDouble(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'rating': rating,
    };
  }
}
