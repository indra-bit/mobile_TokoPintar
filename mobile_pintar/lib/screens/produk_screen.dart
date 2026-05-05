import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProdukScreen extends StatelessWidget {
  const ProdukScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('barangs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data?.docs ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text('Belum ada produk. Silakan tambah data.'),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.inventory)),
                  title: Text(data['nama'] ?? 'Tanpa Nama'),
                  subtitle: Text('Stok: ${data['stok'] ?? 0} | Rp ${data['harga'] ?? 0}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      FirebaseFirestore.instance.collection('barangs').doc(doc.id).delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addProductBtn',
        onPressed: () {
          _showAddProductDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final kodeController = TextEditingController();
    final namaController = TextEditingController();
    final hargaController = TextEditingController();
    final stokController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Produk'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: kodeController,
                  decoration: const InputDecoration(labelText: 'Kode/Barcode (Opsional)'),
                ),
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Barang'),
                ),
                TextField(
                  controller: hargaController,
                  decoration: const InputDecoration(labelText: 'Harga Jual (Rp)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: stokController,
                  decoration: const InputDecoration(labelText: 'Stok Awal'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (namaController.text.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('barangs').add({
                    'kode': kodeController.text,
                    'nama': namaController.text,
                    'harga': double.tryParse(hargaController.text) ?? 0,
                    'stok': int.tryParse(stokController.text) ?? 0,
                    'created_at': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
