import 'package:flutter/material.dart';

import '../core/widgets/dashboard_card.dart';
import '../models/cart_item.dart';
import '../service/dashboard_service.dart';

class HomeScreen extends StatefulWidget {
  final List<CartItem> cart;
  final VoidCallback onScanTap;
  final VoidCallback onCartTap;

  const HomeScreen({
    super.key,
    required this.cart,
    required this.onScanTap,
    required this.onCartTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color smartCartRed = Color(0xFFD6001C);

  double potentialSavings = 0;
  String bestStore = '--';
  bool loadingInsights = true;

  @override
  void initState() {
    super.initState();
    loadDashboardInsights();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.cart != widget.cart) {
      loadDashboardInsights();
    }
  }

  Future<void> loadDashboardInsights() async {
    final savings = await DashboardService.potentialSavings(widget.cart);
    final store = await DashboardService.bestStore(widget.cart);

    if (!mounted) return;

    setState(() {
      potentialSavings = savings;
      bestStore = store;
      loadingInsights = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = DashboardService.cartItemCount(widget.cart);
    final cartTotal = DashboardService.cartTotal(widget.cart);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCart Canada'),
        backgroundColor: smartCartRed,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboardInsights,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ready to save money today?',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 30),

            DashboardCard(
              icon: Icons.qr_code_scanner,
              title: 'Scan Product',
              value: '',
              subtitle: 'Scan a barcode to compare prices',
              onTap: widget.onScanTap,
            ),

            DashboardCard(
              icon: Icons.shopping_cart,
              title: 'Shopping Cart',
              value: '$itemCount',
              subtitle: '\$${cartTotal.toStringAsFixed(2)} estimated total',
              onTap: widget.onCartTap,
            ),

            DashboardCard(
              icon: Icons.savings,
              title: 'Potential Savings',
              value: loadingInsights ? '...' : '\$${potentialSavings.toStringAsFixed(2)}',
              subtitle: 'Based on cheapest known prices',
            ),

            DashboardCard(
              icon: Icons.store,
              title: 'Best Store Today',
              value: loadingInsights ? '...' : bestStore,
              subtitle: 'Based on your current cart',
            ),

            DashboardCard(
              icon: Icons.local_offer,
              title: 'Recent Price Drops',
              value: '0',
              subtitle: 'Price drop tracking coming soon',
            ),
          ],
        ),
      ),
    );
  }
}