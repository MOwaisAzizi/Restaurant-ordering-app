import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';
import '../models/app_user.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  static const _currentUserKey = 'current_user_id';

  final AppDatabase _database;

  Future<AppUser> register({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final db = await _database.database;

    final existing = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      throw const AuthException('This email is already registered.');
    }

    final user = AppUser(
      email: normalizedEmail,
      password: password,
      createdAt: DateTime.now(),
    );

    final id = await db.insert('users', user.toMap());
    final createdUser = AppUser(
      id: id,
      email: user.email,
      password: user.password,
      createdAt: user.createdAt,
    );

    await _saveCurrentUser(id);
    return createdUser;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final db = await _database.database;

    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [normalizedEmail, password],
      limit: 1,
    );

    if (rows.isEmpty) {
      throw const AuthException('Invalid email or password.');
    }

    final user = AppUser.fromMap(rows.first);
    await _saveCurrentUser(user.id!);
    return user;
  }

  Future<AppUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_currentUserKey);

    if (userId == null) {
      return null;
    }

    final db = await _database.database;
    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (rows.isEmpty) {
      await logout();
      return null;
    }

    return AppUser.fromMap(rows.first);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  Future<void> _saveCurrentUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentUserKey, userId);
  }
}
