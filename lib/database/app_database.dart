import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, 'restaurant_ordering_app.db');

    return openDatabase(
      fullPath,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onOpen: _seedIfNeeded,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE restaurants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        image TEXT NOT NULL,
        description TEXT NOT NULL,
        rating REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE menu_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        restaurantId INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        image TEXT NOT NULL,
        FOREIGN KEY (restaurantId) REFERENCES restaurants (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        menuItemId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        UNIQUE(userId, menuItemId),
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (menuItemId) REFERENCES menu_items (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        total REAL NOT NULL,
        itemCount INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER NOT NULL,
        menuItemId INTEGER NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        image TEXT NOT NULL,
        FOREIGN KEY (orderId) REFERENCES orders (id) ON DELETE CASCADE,
        FOREIGN KEY (menuItemId) REFERENCES menu_items (id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_menu_items_restaurant ON menu_items (restaurantId)',
    );
    await db.execute('CREATE INDEX idx_cart_items_user ON cart_items (userId)');
    await db.execute('CREATE INDEX idx_orders_user ON orders (userId)');

    await _seedData(db);
  }

  Future<void> _seedIfNeeded(Database db) async {
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM restaurants'),
        ) ??
        0;

    if (count == 0) {
      await _seedData(db);
    }
  }

  Future<void> _seedData(Database db) async {
    final batch = db.batch();

    final restaurants = [
      {
        'id': 1,
        'name': 'Midnight Grill',
        'image':
            'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=900&q=80',
        'description':
            'Smoky burgers, flame-grilled steaks, and late-night comfort plates.',
        'rating': 4.7,
      },
      {
        'id': 2,
        'name': 'Saffron Table',
        'image':
            'https://images.unsplash.com/photo-1543353071-10c8ba85a904?auto=format&fit=crop&w=900&q=80',
        'description':
            'Aromatic rice bowls, kebabs, and warm breads inspired by regional classics.',
        'rating': 4.8,
      },
      {
        'id': 3,
        'name': 'Urban Noodles',
        'image':
            'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=900&q=80',
        'description':
            'Fast, fresh noodle bowls with rich broths and crisp vegetables.',
        'rating': 4.5,
      },
      {
        'id': 4,
        'name': 'Garden Crust',
        'image':
            'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=900&q=80',
        'description':
            'Wood-fired pizzas, bright salads, and seasonal vegetarian plates.',
        'rating': 4.6,
      },
    ];

    final menuItems = [
      {
        'id': 1,
        'restaurantId': 1,
        'name': 'Black Angus Burger',
        'description':
            'Beef patty, cheddar, charred onion, pickles, and house sauce.',
        'price': 12.99,
        'image':
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=900&q=80',
      },
      {
        'id': 2,
        'restaurantId': 1,
        'name': 'Smoked Brisket Plate',
        'description':
            'Slow-smoked brisket with fries, slaw, and pepper gravy.',
        'price': 18.50,
        'image':
            'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?auto=format&fit=crop&w=900&q=80',
      },
      {
        'id': 3,
        'restaurantId': 1,
        'name': 'Loaded Fire Fries',
        'description':
            'Crispy fries topped with cheese, jalapeno, and smoky aioli.',
        'price': 7.25,
        'image':
            'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?auto=format&fit=crop&w=900&q=80',
      },
      {
        'id': 4,
        'restaurantId': 2,
        'name': 'Kabuli Rice Bowl',
        'description':
            'Saffron rice, raisins, carrots, lamb, and toasted almonds.',
        'price': 14.75,
        'image':
            'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=900&q=80',
      },
      {
        'id': 5,
        'restaurantId': 2,
        'name': 'Chicken Tikka Skewers',
        'description': 'Marinated chicken, herbs, flatbread, and yogurt dip.',
        'price': 13.40,
        'image':
            'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?auto=format&fit=crop&w=900&q=80',
      },
      {
        'id': 6,
        'restaurantId': 2,
        'name': 'Bolani Trio',
        'description':
            'Crisp stuffed flatbreads with potato, leek, and pumpkin fillings.',
        'price': 8.95,
        'image':
            'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=900&q=80',
      },
      {
        'id': 7,
        'restaurantId': 3,
        'name': 'Spicy Miso Ramen',
        'description':
            'Miso broth, noodles, egg, mushrooms, corn, and chili oil.',
        'price': 12.25,
        'image':
            'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=900&q=80',
      },
      {
        'id': 8,
        'restaurantId': 3,
        'name': 'Teriyaki Udon',
        'description':
            'Thick udon noodles with glazed chicken and stir-fried greens.',
        'price': 11.80,
        'image':
            'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?auto=format&fit=crop&w=900&q=80',
      },
      {
        'id': 9,
        'restaurantId': 3,
        'name': 'Crispy Veg Dumplings',
        'description': 'Pan-seared dumplings with ginger soy dipping sauce.',
        'price': 6.95,
        'image':
            'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?auto=format&fit=crop&w=900&q=80',
      },
      {
        'id': 10,
        'restaurantId': 4,
        'name': 'Margherita Pizza',
        'description': 'San Marzano tomato, mozzarella, basil, and olive oil.',
        'price': 13.10,
        'image':
            'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=900&q=80',
      },
      {
        'id': 11,
        'restaurantId': 4,
        'name': 'Roasted Veggie Pizza',
        'description':
            'Mushrooms, peppers, olives, onion, mozzarella, and oregano.',
        'price': 14.20,
        'image':
            'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?auto=format&fit=crop&w=900&q=80',
      },
      {
        'id': 12,
        'restaurantId': 4,
        'name': 'Citrus Garden Salad',
        'description':
            'Greens, orange, cucumber, toasted seeds, and lemon dressing.',
        'price': 8.60,
        'image':
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=80',
      },
    ];

    for (final restaurant in restaurants) {
      batch.insert(
        'restaurants',
        restaurant,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    for (final item in menuItems) {
      batch.insert(
        'menu_items',
        item,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }
}
