import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartBadgeButton extends StatelessWidget {
  const CartBadgeButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final count = context.select<CartProvider, int>((cart) => cart.itemCount);

    return IconButton(
      tooltip: 'Cart',
      onPressed: onPressed,
      icon: count == 0
          ? const Icon(Icons.shopping_bag_outlined)
          : Badge.count(
              count: count,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
    );
  }
}
