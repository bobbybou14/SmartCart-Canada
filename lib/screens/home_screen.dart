import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color smartCartRed = Color(0xFFD6001C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCart Canada'),
        backgroundColor: smartCartRed,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 25),
            Icon(Icons.shopping_cart_checkout, size: 90, color: smartCartRed),
            SizedBox(height: 20),
            Text(
              'Know Before You Checkout',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Scan groceries, track your total, estimate Ontario HST, and save money while shopping.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}