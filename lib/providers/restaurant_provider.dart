import 'package:flutter/foundation.dart';

import '../models/menu_item_model.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';

class RestaurantProvider extends ChangeNotifier {
  RestaurantProvider(this._restaurantService);

  final RestaurantService _restaurantService;

  final Map<int, List<MenuItemModel>> _menusByRestaurant = {};
  List<Restaurant> _restaurants = [];
  bool _isLoadingRestaurants = false;
  bool _isLoadingMenu = false;
  String? _errorMessage;

  List<Restaurant> get restaurants => List.unmodifiable(_restaurants);
  bool get isLoadingRestaurants => _isLoadingRestaurants;
  bool get isLoadingMenu => _isLoadingMenu;
  String? get errorMessage => _errorMessage;

  List<MenuItemModel> menuFor(int restaurantId) {
    return List.unmodifiable(_menusByRestaurant[restaurantId] ?? []);
  }

  Future<void> loadRestaurants() async {
    _isLoadingRestaurants = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _restaurants = await _restaurantService.getRestaurants();
    } catch (_) {
      _errorMessage = 'Unable to load restaurants.';
    } finally {
      _isLoadingRestaurants = false;
      notifyListeners();
    }
  }

  Future<void> loadMenu(int restaurantId) async {
    if (_menusByRestaurant.containsKey(restaurantId)) {
      return;
    }

    _isLoadingMenu = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _menusByRestaurant[restaurantId] = await _restaurantService.getMenuItems(
        restaurantId,
      );
    } catch (_) {
      _errorMessage = 'Unable to load menu.';
    } finally {
      _isLoadingMenu = false;
      notifyListeners();
    }
  }
}
