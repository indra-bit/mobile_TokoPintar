import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.total);
  }

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  Future<Product?> scanBarcode(String kode) async {
    _setLoading(true);
    try {
      final response = await _apiService.get('/barangs/search/$kode');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final product = Product.fromJson(data);
        _setLoading(false);
        return product;
      }
    } catch (e) {
      // Error fetching
    }
    _setLoading(false);
    return null;
  }

  void addItem(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (_items[index].quantity < product.stok) {
        _items[index].quantity++;
      }
    } else {
      if (product.stok > 0) {
        _items.add(CartItem(product: product));
      }
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        removeItem(productId);
      } else if (quantity <= _items[index].product.stok) {
        _items[index].quantity = quantity;
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<bool> checkout() async {
    if (_items.isEmpty) return false;
    _setLoading(true);

    final payload = {
      'items': _items.map((item) => {
        'barang_id': item.product.id,
        'jumlah': item.quantity,
        'harga': item.product.harga,
      }).toList(),
    };

    try {
      final response = await _apiService.post('/penjualans', payload);
      if (response.statusCode == 201) {
        clearCart();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      // Error during checkout
    }

    _setLoading(false);
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
