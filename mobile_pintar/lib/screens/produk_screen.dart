import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProdukScreen extends StatelessWidget {
  const ProdukScreen({super.key});

  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Mengikuti gradient dari container base
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('barangs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan saat memuat data.', style: TextStyle(color: Colors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data?.docs ?? [];

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada produk.\nSilakan tambah data.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 80), // Sisakan ruang untuk FAB
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = doc.data() as Map<String, dynamic>;

              final stok = int.tryParse(data['stok']?.toString() ?? '0') ?? 0;
              final formatHarga = formatCurrency(double.tryParse(data['harga']?.toString() ?? '0') ?? 0);

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F0FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory, color: Color(0xFF4A90E2)),
                  ),
                  title: Text(data['nama'] ?? 'Tanpa Nama', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatHarga, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('Stok: '),
                            Text(
                              '$stok',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: stok <= 10 ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmation(context, doc.id, data['nama'] ?? 'Item');
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addProductBtn',
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        onPressed: () {
          _showAddProductDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String docId, String namaBarang) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Hapus Produk'),
          content: Text('Yakin ingin menghapus\n"$namaBarang"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                FirebaseFirestore.instance.collection('barangs').doc(docId).delete();
                Navigator.pop(context);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.add_box, color: Color(0xFF4A90E2)),
              SizedBox(width: 8),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: kodeController,
                  decoration: InputDecoration(
                    labelText: 'Kode/Barcode (Opsional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama Barang',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hargaController,
                  decoration: InputDecoration(
                    labelText: 'Harga Jual (Rp)',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stokController,
                  decoration: InputDecoration(
                    labelText: 'Stok Awal',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
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
