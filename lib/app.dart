import 'package:flutter/material.dart';

import 'models/cart_item.dart';
import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/cart_screen.dart';

class SmartCartCanadaApp extends StatefulWidget {
  const SmartCartCanadaApp({super.key});

  @override
  State<SmartCartCanadaApp> createState() => _SmartCartCanadaAppState();
}

class _SmartCartCanadaAppState extends State<SmartCartCanadaApp> {
  static const Color smartCartRed = Color(0xFFD6001C);

  int selectedIndex = 0;

  final List<CartItem> cart = [
    CartItem(barcode: '000001', name: 'Milk', price: 5.49, taxable: false),
    CartItem(barcode: '000002', name: 'Bread', price: 3.29, taxable: false),
    CartItem(barcode: '000003', name: 'Paper Towels', price: 9.99, taxable: true),
  ];

  void addToCart(CartItem item) {
    setState(() {
      final existingIndex = cart.indexWhere((cartItem) => cartItem.barcode == item.barcode);

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
      const HomeScreen(),
      ScanScreen(onItemScanned: addToCart),
      CartScreen(cart: cart),
      const PlaceholderScreen(title: 'Savings', message: 'Savings and price comparisons will appear here.'),
      const PlaceholderScreen(title: 'Settings', message: 'Settings will appear here.'),
    ];

    return MaterialApp(
      title: 'SmartCart Canada',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: smartCartRed),
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
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Savings'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
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