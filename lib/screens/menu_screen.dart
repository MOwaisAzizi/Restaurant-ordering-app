import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/restaurant.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/app_network_image.dart';
import '../widgets/cart_badge_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/menu_item_card.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().loadMenu(widget.restaurant.id);
    });
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
        title: Text(widget.restaurant.name),
        actions: [CartBadgeButton(onPressed: _openCart)],
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, _) {
          final items = provider.menuFor(widget.restaurant.id);

          if (provider.isLoadingMenu && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.menu_book_outlined,
              title: provider.errorMessage ?? 'No menu items found.',
              actionLabel: 'Refresh',
              onAction: () => provider.loadMenu(widget.restaurant.id),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: items.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _RestaurantHeader(restaurant: widget.restaurant);
              }

              final item = items[index - 1];
              return MenuItemCard(
                item: item,
                onAdd: () async {
                  final userId = context.read<AuthProvider>().user?.id;
                  if (userId == null) {
                    return;
                  }

                  await context.read<CartProvider>().addItem(userId, item);

                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.name} added to cart.')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _RestaurantHeader extends StatelessWidget {
  const _RestaurantHeader({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: AppNetworkImage(url: restaurant.image),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                restaurant.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const Icon(Icons.star, size: 18),
            const SizedBox(width: 4),
            Text(
              restaurant.rating.toStringAsFixed(1),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(restaurant.description),
      ],
    );
  }
}
