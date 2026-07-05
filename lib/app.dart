import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'models/cart_item.dart';
import 'screens/admin_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_catalog_screen.dart';
import 'screens/scan_screen.dart';

class SmartCartCanadaApp extends StatefulWidget {
  const SmartCartCanadaApp({super.key});

  @override
  State<SmartCartCanadaApp> createState() => _SmartCartCanadaAppState();
}

class _SmartCartCanadaAppState extends State<SmartCartCanadaApp> {
  int selectedIndex = 0;

  final List<CartItem> cart = [];

  void addToCart(CartItem item) {
    setState(() {
      final existingIndex =
          cart.indexWhere((cartItem) => cartItem.barcode == item.barcode);

      if (existingIndex >= 0) {
        cart[existingIndex].quantity++;
      } else {
        cart.add(item);
      }

      selectedIndex = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        cart: cart,
        onScanTap: () {
          setState(() {
            selectedIndex = 1;
          });
        },
        onCartTap: () {
          setState(() {
            selectedIndex = 3;
          });
        },
      ),
      ScanScreen(onItemScanned: addToCart),
      ProductCatalogScreen(onAddToCart: addToCart),
      CartScreen(cart: cart),
      const PlaceholderScreen(
        title: 'Savings',
        message: 'Savings and price comparisons will appear here.',
      ),
      const AdminScreen(),
    ];

    return MaterialApp(
      title: 'SmartCart Canada',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: screens[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Browse',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Savings'),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String message;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}