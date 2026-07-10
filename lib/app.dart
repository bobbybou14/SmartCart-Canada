import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'models/cart_item.dart';
import 'screens/admin_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/product_catalog_screen.dart';
import 'screens/receipt_upload_screen.dart';
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
      const DashboardScreen(),
      ScanScreen(
        onItemScanned: addToCart,
      ),
      ProductCatalogScreen(
        onAddToCart: addToCart,
      ),
      CartScreen(
        cart: cart,
      ),
      const ReceiptUploadScreen(),
      const AdminScreen(),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartCart Canada',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: screens[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Receipts',
            ),
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