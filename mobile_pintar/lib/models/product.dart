class Product {
  final String id;
  final String kodeBarang;
  final String namaBarang;
  final int stok;
  final double harga;

  Product({
    required this.id,
    required this.kodeBarang,
    required this.namaBarang,
    required this.stok,
    required this.harga,
  });

  factory Product.fromFirestore(String docId, Map<String, dynamic> data) {
    return Product(
      id: docId,
      kodeBarang: data['kode']?.toString() ?? '',
      namaBarang: data['nama']?.toString() ?? 'Tanpa Nama',
      stok: int.tryParse(data['stok']?.toString() ?? '0') ?? 0,
      harga: double.tryParse(data['harga']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.harga * quantity;
}
