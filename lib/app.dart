import 'package:flutter/material.dart';

import 'models/cart_item.dart';
import 'models/product.dart';
import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/admin_screen.dart';

class SmartCartCanadaApp extends StatefulWidget {
  const SmartCartCanadaApp({super.key});

  @override
  State<SmartCartCanadaApp> createState() => _SmartCartCanadaAppState();
}

class _SmartCartCanadaAppState extends State<SmartCartCanadaApp> {
  static const Color smartCartRed = Color(0xFFD6001C);

  int selectedIndex = 0;

  final List<CartItem> cart = [
    CartItem(
      product: const Product(
        barcode: '000001',
        name: 'Milk',
        category: 'Dairy',
        size: '2 L',
        taxable: false,
      ),
      price: 5.49,
    ),
    CartItem(
      product: const Product(
        barcode: '000002',
        name: 'Bread',
        category: 'Bakery',
        size: '675 g',
        taxable: false,
      ),
      price: 3.29,
    ),
    CartItem(
      product: const Product(
        barcode: '000003',
        name: 'Paper Towels',
        category: 'Household',
        size: '6 Rolls',
        taxable: true,
      ),
      price: 9.99,
    ),
  ];

  void addToCart(CartItem item) {
    setState(() {
      final existingIndex =
          cart.indexWhere((cartItem) => cartItem.barcode == item.barcode);

      if (existingIndex >= 0) {
        cart[existingIndex].quantity++;
      } else {
        cart.add(item);
      }

      selectedIndex = 2;
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
            selectedIndex = 2;
          });
        },
      ),
      ScanScreen(
        onItemScanned: addToCart,
      ),
      CartScreen(
        cart: cart,
      ),
      const PlaceholderScreen(
        title: 'Savings',
        message: 'Savings and price comparisons will appear here.',
      ),
      const AdminScreen(),
      const PlaceholderScreen(
        title: 'Settings',
        message: 'Settings will appear here.',
      ),
    ];

    return MaterialApp(
      title: 'SmartCart Canada',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: smartCartRed,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Scaffold(
        body: screens[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          selectedItemColor: smartCartRed,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.savings),
              label: 'Savings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
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

  static const Color smartCartRed = Color(0xFFD6001C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: smartCartRed,
        foregroundColor: Colors.white,
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