import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import 'pos_screen.dart';
import 'produk_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    final List<Widget> pages = [
      _buildHomeContent(user),
      const PosScreen(),
      const ProdukScreen(),
      _buildProfileContent(user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Mart', style: TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF87CEEB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak ada notifikasi baru')),
              );
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFC3CFE2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Kasir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedIndex = 1; // Go to Kasir
          });
        },
        child: const Icon(Icons.qr_code_scanner),
      ) : null,
    );
  }

  Widget _buildHomeContent(User? user) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Alert Selamat Datang bergaya Bootstrap Alert-Primary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFCFE2FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFB6D4FE)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF052C65)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Selamat datang, ${user?.displayName ?? user?.email?.split('@')[0] ?? 'Pengguna'}',
                  style: const TextStyle(color: Color(0xFF052C65), fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Hari Ini',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('penjualans')
                      .where('created_at', isGreaterThanOrEqualTo: startOfDay)
                      .snapshots(),
                  builder: (context, snapshot) {
                    int totalPenjualan = 0;
                    double totalPendapatan = 0.0;

                    if (snapshot.hasData) {
                      totalPenjualan = snapshot.data!.docs.length;
                      for (var doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final amount = data['total_amount'] ?? 0;
                        totalPendapatan += (amount is num) ? amount.toDouble() : double.tryParse(amount.toString()) ?? 0.0;
                      }
                    }

                    final String formatPendapatan = NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(totalPendapatan);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          'Penjualan',
                          totalPenjualan.toString(),
                          Icons.shopping_cart,
                          Colors.green
                        ),
                        _buildSummaryItem(
                          'Pendapatan',
                          formatPendapatan,
                          Icons.attach_money,
                          Colors.blue
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('barangs')
              .where('stok', isLessThanOrEqualTo: 10)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const SizedBox.shrink(); // Sembunyikan jika tidak ada stok tipis
            }

            final items = snapshot.data!.docs;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD), // Bootstrap alert-warning
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFECB5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFF664D03)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Peringatan Stok Rendah (${items.length} barang)',
                          style: const TextStyle(
                            color: Color(0xFF664D03),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFFFECB5), height: 1),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: items.length > 3 ? 150 : (items.length * 40.0),
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final data = items[index].data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  data['nama'] ?? 'Tanpa Nama',
                                  style: const TextStyle(color: Color(0xFF664D03)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Sisa: ${data['stok']}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfileContent(User? user) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF87CEEB)],
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Color(0xFF4A90E2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.displayName ?? user?.email?.split('@')[0] ?? 'Pengelola',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'email@example.com',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      context.read<AuthProvider>().logout();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
