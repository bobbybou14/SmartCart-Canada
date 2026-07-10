import 'package:flutter/material.dart';

import '../models/shopping_trip.dart';
import '../service/shopping_trip_service.dart';
import '../widgets/dashboard/hero_card.dart';
import '../widgets/dashboard/quick_action_card.dart';
import '../widgets/dashboard/recent_trip_card.dart';
import '../widgets/dashboard/savings_card.dart';
import '../widgets/dashboard/stat_card.dart';
import 'basket_comparison_screen.dart';
import 'product_catalog_screen.dart';
import 'receipt_upload_screen.dart';
import 'shopping_trip_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ShoppingTrip> trips = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedTrips = await ShoppingTripService.getShoppingTrips();

      if (!mounted) return;

      setState(() {
        trips = loadedTrips;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load dashboard information: $error';
      });
    }
  }

  Future<void> openScreen(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );

    if (!mounted) return;

    await loadDashboard();
  }

  int get tripsThisMonth {
    final now = DateTime.now();

    return trips.where((trip) {
      return trip.purchaseDate.year == now.year &&
          trip.purchaseDate.month == now.month;
    }).length;
  }

  double get spentThisMonth {
    final now = DateTime.now();

    return trips.where((trip) {
      return trip.purchaseDate.year == now.year &&
          trip.purchaseDate.month == now.month;
    }).fold<double>(
      0,
      (total, trip) => total + trip.total,
    );
  }

  int get storesVisited {
    final now = DateTime.now();

    return trips
        .where((trip) {
          return trip.purchaseDate.year == now.year &&
              trip.purchaseDate.month == now.month;
        })
        .map((trip) {
          return trip.storeId.isEmpty
              ? trip.storeName.trim().toLowerCase()
              : trip.storeId;
        })
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .length;
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(tripDate).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String tripLocation(ShoppingTrip trip) {
    return [
      trip.city,
      trip.province,
    ].where((value) => value.trim().isNotEmpty).join(', ');
  }

  Widget sectionHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 10,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget loadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: loadDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget emptyRecentTrips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 30,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 54,
            ),
            const SizedBox(height: 14),
            const Text(
              'No shopping trips yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload a receipt to begin building your shopping history and price database.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                openScreen(const ReceiptUploadScreen());
              },
              icon: const Icon(Icons.receipt_long),
              label: const Text('Upload Receipt'),
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardContent() {
    if (isLoading) {
      return loadingState();
    }

    if (errorMessage != null) {
      return errorState();
    }

    final recentTrips = trips.take(3).toList();

    return RefreshIndicator(
      onRefresh: loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          HeroCard(
            userName: 'RJ',
            tripCount: tripsThisMonth,
            storeCount: storesVisited,
            amountSpent: spentThisMonth,
          ),
          const SizedBox(height: 22),
          sectionHeading('This Month'),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.95,
            children: [
              StatCard(
                icon: Icons.shopping_bag,
                label: 'Shopping Trips',
                value: tripsThisMonth.toString(),
                supportingText: 'This month',
              ),
              StatCard(
                icon: Icons.attach_money,
                label: 'Amount Spent',
                value: '\$${spentThisMonth.toStringAsFixed(2)}',
                supportingText: 'Groceries',
              ),
              StatCard(
                icon: Icons.store,
                label: 'Stores Visited',
                value: storesVisited.toString(),
                supportingText: 'This month',
              ),
            ],
          ),
          const SizedBox(height: 22),
          const SavingsCard(),
          const SizedBox(height: 22),
          sectionHeading('Quick Actions'),
          QuickActionCard(
            icon: Icons.receipt_long,
            title: 'Upload Receipt',
            subtitle: 'Turn a grocery receipt into shopping history and prices',
            onTap: () {
              openScreen(const ReceiptUploadScreen());
            },
          ),
          QuickActionCard(
            icon: Icons.history,
            title: 'Shopping Trips',
            subtitle: 'Review your saved grocery trips and receipt items',
            onTap: () {
              openScreen(const ShoppingTripHistoryScreen());
            },
          ),
          QuickActionCard(
            icon: Icons.inventory_2,
            title: 'Browse Products',
            subtitle: 'Search products, compare prices, and view history',
            onTap: () {
              openScreen(const ProductCatalogScreen());
            },
          ),
          QuickActionCard(
            icon: Icons.shopping_basket,
            title: 'Compare Basket',
            subtitle: 'Find the cheapest store for your grocery basket',
            onTap: () {
              openScreen(const BasketComparisonScreen());
            },
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Shopping',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  openScreen(const ShoppingTripHistoryScreen());
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recentTrips.isEmpty)
            emptyRecentTrips()
          else
            ...recentTrips.map(
              (trip) => RecentTripCard(
                store: trip.storeName,
                date: formatDate(trip.purchaseDate),
                total: trip.total,
                location: tripLocation(trip),
                onTap: () {
                  openScreen(const ShoppingTripHistoryScreen());
                },
              ),
            ),
          const SizedBox(height: 22),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.insights,
                        size: 30,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Price Insights',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'As SmartCart collects more prices, you will see your best stores, price trends, estimated savings, and smarter shopping recommendations here.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: dashboardContent(),
    );
  }
}