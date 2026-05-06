import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;

  double get totalAmount {
    return _items.fold(0.0, (acc, item) => acc + item.total);
  }

  int get totalItems {
    return _items.fold(0, (acc, item) => acc + item.quantity);
  }

  Future<Product?> scanBarcode(String query) async {
    _setLoading(true);
    try {
      // 1. Coba cari persis berdasarkan kode terlebih dahulu
      final snippetCode = await _firestore
          .collection('barangs')
          .where('kode', isEqualTo: query)
          .limit(1)
          .get();

      if (snippetCode.docs.isNotEmpty) {
        final doc = snippetCode.docs.first;
        _setLoading(false);
        return Product.fromFirestore(doc.id, doc.data());
      }

      // 2. Jika tidak ketemu, cari berdasarkan nama persis (case-sensitive)
      final snippetName = await _firestore
          .collection('barangs')
          .where('nama', isEqualTo: query)
          .limit(1)
          .get();

      if (snippetName.docs.isNotEmpty) {
        final doc = snippetName.docs.first;
        _setLoading(false);
        return Product.fromFirestore(doc.id, doc.data());
      }

      // 3. Fallback: ambil semua dan cari parsial di memori
      // (Beresiko lemot kalau data sangat besar,
      // tapi untuk POS mobile toko kecil, ini metode termudah di Firestore)
      final allDocs = await _firestore.collection('barangs').get();
      final lowerQuery = query.toLowerCase();

      final partialMatches = allDocs.docs.where((doc) {
        final data = doc.data();
        final nama = (data['nama']?.toString() ?? '').toLowerCase();
        return nama.contains(lowerQuery);
      }).toList();

      if (partialMatches.isNotEmpty) {
        final doc = partialMatches.first;
        _setLoading(false);
        return Product.fromFirestore(doc.id, doc.data());
      }

    } catch (e) {
      debugPrint('Error fetch barcode: $e');
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

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
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

    try {
      // Create a batch to update stock and create sales record
      final batch = _firestore.batch();

      final docRef = _firestore.collection('penjualans').doc();
      batch.set(docRef, {
        'total_amount': totalAmount,
        'items_count': totalItems,
        'created_at': FieldValue.serverTimestamp(),
        'items': _items.map((item) => {
          'barang_id': item.product.id,
          'nama': item.product.namaBarang,
          'jumlah': item.quantity,
          'harga': item.product.harga,
          'subtotal': item.total,
        }).toList(),
      });

      // Update stok in barangs
      for (var item in _items) {
        final barangRef = _firestore.collection('barangs').doc(item.product.id);
        batch.update(barangRef, {
          'stok': FieldValue.increment(-item.quantity)
        });
      }

      await batch.commit();

      clearCart();
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Checkout error: $e');
    }

    _setLoading(false);
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
