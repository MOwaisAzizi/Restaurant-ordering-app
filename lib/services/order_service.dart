import '../database/app_database.dart';
import '../models/cart_item_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

class OrderException implements Exception {
  const OrderException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OrderService {
  OrderService({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<OrderModel> placeOrder({
    required int userId,
    required List<CartItemModel> cartItems,
  }) async {
    if (cartItems.isEmpty) {
      throw const OrderException('Your cart is empty.');
    }

    final total = cartItems.fold<double>(0, (sum, item) => sum + item.subtotal);
    final itemCount = cartItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final createdAt = DateTime.now();
    final db = await _database.database;

    return db.transaction((txn) async {
      final orderId = await txn.insert('orders', {
        'userId': userId,
        'total': total,
        'itemCount': itemCount,
        'createdAt': createdAt.toIso8601String(),
      });

      for (final item in cartItems) {
        final orderItem = OrderItemModel(
          orderId: orderId,
          menuItemId: item.menuItemId,
          name: item.name,
          price: item.price,
          quantity: item.quantity,
          image: item.image,
        );
        await txn.insert('order_items', orderItem.toMap());
      }

      await txn.delete('cart_items', where: 'userId = ?', whereArgs: [userId]);

      return OrderModel(
        id: orderId,
        userId: userId,
        total: total,
        itemCount: itemCount,
        createdAt: createdAt,
      );
    });
  }
}
