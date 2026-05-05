class Product {
  final int id;
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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      kodeBarang: json['kode_barang'],
      namaBarang: json['nama_barang'],
      stok: json['stok'],
      harga: double.parse(json['harga'].toString()),
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
