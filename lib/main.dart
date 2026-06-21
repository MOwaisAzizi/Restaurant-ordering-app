import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database/app_database.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/restaurant_provider.dart';
import 'screens/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/order_service.dart';
import 'services/restaurant_service.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database;
  runApp(const RestaurantOrderingApp());
}

class RestaurantOrderingApp extends StatelessWidget {
  const RestaurantOrderingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService())..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              RestaurantProvider(RestaurantService())..loadRestaurants(),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider(CartService())),
        ChangeNotifierProvider(create: (_) => OrderProvider(OrderService())),
      ],
      child: MaterialApp(
        title: 'Restaurant Ordering',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthGate(),
      ),
    );
  }
}
