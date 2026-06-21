import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';

class CartService {
  CartService({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<CartItemModel>> getCartItems(int userId) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        c.id AS cartId,
        c.userId,
        c.menuItemId,
        c.quantity,
        m.restaurantId,
        m.name,
        m.description,
        m.price,
        m.image
      FROM cart_items c
      INNER JOIN menu_items m ON m.id = c.menuItemId
      WHERE c.userId = ?
      ORDER BY c.id DESC
      ''',
      [userId],
    );

    return rows.map(CartItemModel.fromJoinedMap).toList();
  }

  Future<void> addItem({
    required int userId,
    required MenuItemModel item,
  }) async {
    final db = await _database.database;

    await db.transaction((txn) async {
      final existing = await txn.query(
        'cart_items',
        where: 'userId = ? AND menuItemId = ?',
        whereArgs: [userId, item.id],
        limit: 1,
      );

      if (existing.isEmpty) {
        await txn.insert('cart_items', {
          'userId': userId,
          'menuItemId': item.id,
          'quantity': 1,
          'createdAt': DateTime.now().toIso8601String(),
        });
        return;
      }

      final cartId = existing.first['id'] as int;
      final quantity = existing.first['quantity'] as int;
      await txn.update(
        'cart_items',
        {'quantity': quantity + 1},
        where: 'id = ?',
        whereArgs: [cartId],
      );
    });
  }

  Future<void> setQuantity({required int cartId, required int quantity}) async {
    final db = await _database.database;

    if (quantity <= 0) {
      await db.delete('cart_items', where: 'id = ?', whereArgs: [cartId]);
      return;
    }

    await db.update(
      'cart_items',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [cartId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeItem(int cartId) async {
    final db = await _database.database;
    await db.delete('cart_items', where: 'id = ?', whereArgs: [cartId]);
  }

  Future<void> clearCart(int userId) async {
    final db = await _database.database;
    await db.delete('cart_items', where: 'userId = ?', whereArgs: [userId]);
  }
}
