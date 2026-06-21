import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/primary_button.dart';
import '../widgets/summary_row.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  Future<void> _placeOrder(BuildContext context) async {
    final userId = context.read<AuthProvider>().user?.id;
    final cart = context.read<CartProvider>();

    if (userId == null || cart.items.isEmpty) {
      return;
    }

    final order = context.read<OrderProvider>();
    final ok = await order.placeOrder(
      userId: userId,
      cartItems: List.of(cart.items),
    );

    if (!context.mounted) {
      return;
    }

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(order.errorMessage ?? 'Unable to place order.')),
      );
      return;
    }

    cart.reset();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Order placed'),
          content: Text(
            'Your order #${order.lastOrder?.id ?? ''} was saved successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );

    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Consumer2<CartProvider, OrderProvider>(
        builder: (context, cart, order, _) {
          if (cart.items.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Nothing to checkout.',
            );
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text('Qty ${item.quantity}'),
                              ],
                            ),
                          ),
                          Text(
                            Formatters.money(item.subtotal),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    border: Border(top: BorderSide(color: Color(0xFF323232))),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SummaryRow(label: 'Items', value: '${cart.itemCount}'),
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
                        label: 'Place order',
                        icon: Icons.check_circle_outline,
                        isLoading: order.isPlacingOrder,
                        onPressed: order.isPlacingOrder
                            ? null
                            : () => _placeOrder(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
