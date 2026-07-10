import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/shopping_trip.dart';
import '../service/shopping_trip_service.dart';
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
    return trips
        .map((trip) => trip.storeId.isEmpty ? trip.storeName : trip.storeId)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .length;
  }

  String formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Widget quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget statisticCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget recentTripCard(ShoppingTrip trip) {
    final storeName =
        trip.storeName.trim().isEmpty ? 'Unknown Store' : trip.storeName;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.shopping_bag),
        ),
        title: Text(
          storeName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(formatDate(trip.purchaseDate)),
        trailing: Text(
          '\$${trip.total.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          openScreen(const ShoppingTripHistoryScreen());
        },
      ),
    );
  }

  Widget dashboardContent() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
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

    final recentTrips = trips.take(3).toList();

    return RefreshIndicator(
      onRefresh: loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'SmartCart Canada',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your grocery savings and shopping activity in one place.',
            style: TextStyle(fontSize: 17),
          ),
          const SizedBox(height: 24),
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          quickAction(
            icon: Icons.receipt_long,
            title: 'Upload Receipt',
            subtitle: 'Add a new grocery receipt',
            onTap: () {
              openScreen(const ReceiptUploadScreen());
            },
          ),
          quickAction(
            icon: Icons.history,
            title: 'Shopping Trips',
            subtitle: 'Review saved grocery trips',
            onTap: () {
              openScreen(const ShoppingTripHistoryScreen());
            },
          ),
          quickAction(
            icon: Icons.inventory_2,
            title: 'Browse Products',
            subtitle: 'Search your product catalog',
            onTap: () {
              openScreen(const ProductCatalogScreen());
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'This Month',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.15,
            children: [
              statisticCard(
                icon: Icons.shopping_bag,
                label: 'Trips',
                value: tripsThisMonth.toString(),
              ),
              statisticCard(
                icon: Icons.attach_money,
                label: 'Spent',
                value: '\$${spentThisMonth.toStringAsFixed(2)}',
              ),
              statisticCard(
                icon: Icons.store,
                label: 'Stores',
                value: storesVisited.toString(),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No shopping trips saved yet. Upload a receipt to get started.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...recentTrips.map(recentTripCard),
          const SizedBox(height: 20),
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