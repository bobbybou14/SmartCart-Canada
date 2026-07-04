import 'package:flutter/material.dart';

import 'admin_products_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  static const Color smartCartRed = Color(0xFFD6001C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCart Admin'),
        backgroundColor: smartCartRed,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Database Management',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _adminButton(
              context,
              Icons.inventory_2,
              'Products',
              'Add and edit products',
              const AdminProductsScreen(),
            ),
            _adminButton(
              context,
              Icons.store,
              'Stores',
              'Manage Canadian stores',
              null,
            ),
            _adminButton(
              context,
              Icons.attach_money,
              'Prices',
              'Manage product prices',
              null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminButton(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget? screen,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, color: smartCartRed, size: 34),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (screen == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title coming soon')),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
      ),
    );
  }
}