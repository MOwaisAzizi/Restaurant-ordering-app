import 'package:flutter/foundation.dart';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._orderService);

  final OrderService _orderService;

  bool _isPlacingOrder = false;
  String? _errorMessage;
  OrderModel? _lastOrder;

  bool get isPlacingOrder => _isPlacingOrder;
  String? get errorMessage => _errorMessage;
  OrderModel? get lastOrder => _lastOrder;

  Future<bool> placeOrder({
    required int userId,
    required List<CartItemModel> cartItems,
  }) async {
    _isPlacingOrder = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastOrder = await _orderService.placeOrder(
        userId: userId,
        cartItems: cartItems,
      );
      return true;
    } on OrderException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to place order. Please try again.';
      return false;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }
}
