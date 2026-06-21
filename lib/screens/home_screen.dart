import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/restaurant.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/cart_badge_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/restaurant_card.dart';
import 'cart_screen.dart';
import 'menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user?.id;
      if (userId != null) {
        context.read<CartProvider>().loadCart(userId);
      }
      context.read<RestaurantProvider>().loadRestaurants();
    });
  }

  Future<void> _logout() async {
    context.read<CartProvider>().reset();
    await context.read<AuthProvider>().logout();
  }

  void _openRestaurant(Restaurant restaurant) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MenuScreen(restaurant: restaurant)),
    );
  }

  void _openCart() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        actions: [
          CartBadgeButton(onPressed: _openCart),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingRestaurants && provider.restaurants.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.restaurants.isEmpty) {
            return EmptyState(
              icon: Icons.error_outline,
              title: provider.errorMessage!,
              actionLabel: 'Try again',
              onAction: provider.loadRestaurants,
            );
          }

          if (provider.restaurants.isEmpty) {
            return EmptyState(
              icon: Icons.storefront_outlined,
              title: 'No restaurants yet.',
              actionLabel: 'Refresh',
              onAction: provider.loadRestaurants,
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadRestaurants,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width >= 1100
                    ? 3
                    : width >= 720
                    ? 2
                    : 1;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: columns == 1 ? 1.62 : 1.12,
                  ),
                  itemCount: provider.restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = provider.restaurants[index];
                    return RestaurantCard(
                      restaurant: restaurant,
                      onTap: () => _openRestaurant(restaurant),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
