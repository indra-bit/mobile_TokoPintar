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
      _buildHomeContent(),
      const PosScreen(),
      const ProdukScreen(),
      _buildProfileContent(user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Pintar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show alerts
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak ada notifikasi baru')),
              );
            },
          )
        ],
      ),
      body: pages[_selectedIndex],
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

  Widget _buildHomeContent() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
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
        const Text(
          'Peringatan Stok',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.orange),
            title: const Text('Lihat barang yang tipis stoknya'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to alerts screen
            },
          ),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(
          radius: 50,
          child: Icon(Icons.person, size: 50),
        ),
        const SizedBox(height: 16),
        Text(
          user?.displayName ?? 'Pengguna',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? 'email@example.com',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text('Logout', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () {
            context.read<AuthProvider>().logout();
          },
        ),
      ],
    );
  }
}
