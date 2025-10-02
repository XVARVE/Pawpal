import 'package:flutter/foundation.dart';
import 'package:pawpal/providers/models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, e) => sum + e.qty);

  int get subtotal => _items.fold(0, (sum, e) => sum + (e.price * e.qty));

  void addItem(CartItem item) {
    // If same product already in cart (by id or name+detail), just increase qty
    final idx = _items.indexWhere((e) =>
    (item.id != null && e.id == item.id) ||
        (item.id == null && e.name == item.name && e.detail == item.detail));
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(qty: _items[idx].qty + item.qty);
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItemByIndex(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void incrementQty(int index) {
    if (index >= 0 && index < _items.length) {
      final item = _items[index];
      _items[index] = item.copyWith(qty: item.qty + 1);
      notifyListeners();
    }
  }

  void decrementQty(int index) {
    if (index >= 0 && index < _items.length) {
      final item = _items[index];
      if (item.qty > 1) {
        _items[index] = item.copyWith(qty: item.qty - 1);
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
