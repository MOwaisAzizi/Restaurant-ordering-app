import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/formatters.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/primary_button.dart';
import '../widgets/summary_row.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user?.id;
      if (userId != null) {
        context.read<CartProvider>().loadCart(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.select<AuthProvider, int?>((auth) => auth.user?.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isLoading && cart.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cart.items.isEmpty) {
            return const EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty.',
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return CartItemTile(
                      item: item,
                      onIncrement: userId == null
                          ? null
                          : () => cart.increment(userId, item),
                      onDecrement: userId == null
                          ? null
                          : () => cart.decrement(userId, item),
                      onRemove: userId == null
                          ? null
                          : () => cart.remove(userId, item),
                    );
                  },
                ),
              ),
              _CartSummary(cart: cart),
            ],
          );
        },
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart});

  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          border: Border(top: BorderSide(color: Color(0xFF323232))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SummaryRow(label: 'Items', value: cart.itemCount.toString()),
            const SizedBox(height: 8),
            SummaryRow(
              label: 'Subtotal',
              value: Formatters.money(cart.subtotal),
            ),
            const SizedBox(height: 8),
            SummaryRow(
              label: 'Total',
              value: Formatters.money(cart.total),
              isStrong: true,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Checkout',
              icon: Icons.payment,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
