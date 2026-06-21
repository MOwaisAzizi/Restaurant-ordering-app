import '../database/app_database.dart';
import '../models/menu_item_model.dart';
import '../models/restaurant.dart';

class RestaurantService {
  RestaurantService({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Restaurant>> getRestaurants() async {
    final db = await _database.database;
    final rows = await db.query(
      'restaurants',
      orderBy: 'rating DESC, name ASC',
    );
    return rows.map(Restaurant.fromMap).toList();
  }

  Future<List<MenuItemModel>> getMenuItems(int restaurantId) async {
    final db = await _database.database;
    final rows = await db.query(
      'menu_items',
      where: 'restaurantId = ?',
      whereArgs: [restaurantId],
      orderBy: 'name ASC',
    );
    return rows.map(MenuItemModel.fromMap).toList();
  }
}
