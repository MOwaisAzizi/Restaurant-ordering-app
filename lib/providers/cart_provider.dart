import 'package:flutter/foundation.dart';

import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._cartService);

  final CartService _cartService;

  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  double get total => subtotal;

  Future<void> loadCart(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _cartService.getCartItems(userId);
    } catch (_) {
      _errorMessage = 'Unable to load your cart.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(int userId, MenuItemModel item) async {
    await _cartService.addItem(userId: userId, item: item);
    await loadCart(userId);
  }

  Future<void> increment(int userId, CartItemModel item) async {
    await _cartService.setQuantity(
      cartId: item.cartId,
      quantity: item.quantity + 1,
    );
    await loadCart(userId);
  }

  Future<void> decrement(int userId, CartItemModel item) async {
    await _cartService.setQuantity(
      cartId: item.cartId,
      quantity: item.quantity - 1,
    );
    await loadCart(userId);
  }

  Future<void> remove(int userId, CartItemModel item) async {
    await _cartService.removeItem(item.cartId);
    await loadCart(userId);
  }

  Future<void> clear(int userId) async {
    await _cartService.clearCart(userId);
    reset();
  }

  void reset() {
    _items = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
