import 'package:flutter/material.dart';

import '../models/product.dart';
import '../service/price_history_service.dart';

class PriceHistoryScreen extends StatefulWidget {
  final Product product;

  const PriceHistoryScreen({
    super.key,
    required this.product,
  });

  @override
  State<PriceHistoryScreen> createState() => _PriceHistoryScreenState();
}

class _PriceHistoryScreenState extends State<PriceHistoryScreen> {
  PriceHistorySummary? summary;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadPriceHistory();
  }

  Future<void> loadPriceHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await PriceHistoryService.getPriceHistory(
        widget.product.barcode,
      );

      if (!mounted) return;

      setState(() {
        summary = result;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load price history: $error';
      });
    }
  }

  String productDisplayName() {
    final parts = [
      widget.product.brand,
      widget.product.name,
      widget.product.size,
    ].where((value) => value.trim().isNotEmpty).toList();

    if (parts.isEmpty) {
      return 'Unknown Product';
    }

    return parts.join(' ');
  }

  String formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  IconData trendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'rising':
        return Icons.trending_up;
      case 'falling':
        return Icons.trending_down;
      case 'stable':
        return Icons.trending_flat;
      default:
        return Icons.show_chart;
    }
  }

  Color trendColour(String trend) {
    switch (trend.toLowerCase()) {
      case 'rising':
        return Colors.red;
      case 'falling':
        return Colors.green;
      case 'stable':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget statisticCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
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

  Widget summarySection(PriceHistorySummary data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  productDisplayName(),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Barcode: ${widget.product.barcode}',
                ),
                if (widget.product.category.trim().isNotEmpty)
                  Text(
                    'Category: ${widget.product.category}',
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.35,
          children: [
            statisticCard(
              label: 'Current Price',
              value: '\$${data.currentPrice.toStringAsFixed(2)}',
              icon: Icons.attach_money,
            ),
            statisticCard(
              label: 'Average Price',
              value: '\$${data.averagePrice.toStringAsFixed(2)}',
              icon: Icons.calculate,
            ),
            statisticCard(
              label: 'Lowest Price',
              value: '\$${data.lowestPrice.toStringAsFixed(2)}',
              icon: Icons.arrow_downward,
            ),
            statisticCard(
              label: 'Highest Price',
              value: '\$${data.highestPrice.toStringAsFixed(2)}',
              icon: Icons.arrow_upward,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: Icon(
              trendIcon(data.trend),
              color: trendColour(data.trend),
              size: 34,
            ),
            title: const Text(
              'Price Trend',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(data.trend),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.store,
              size: 34,
            ),
            title: const Text(
              'Best Recorded Store',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(data.bestStore),
          ),
        ),
      ],
    );
  }

  Widget historySection(PriceHistorySummary data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 22),
        const Text(
          'Price History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        if (data.entries.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No price history is available for this product yet.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...data.entries.reversed.map(
            (entry) {
              final location = [
                entry.city,
                entry.province,
              ].where((value) => value.trim().isNotEmpty).join(', ');

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.price_check),
                  ),
                  title: Text(
                    entry.store.trim().isEmpty
                        ? 'Unknown Store'
                        : entry.store,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${formatDate(entry.createdAt)}'
                    '${location.isEmpty ? "" : "\n$location"}'
                    '${entry.source.trim().isEmpty ? "" : "\nSource: ${entry.source}"}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    '\$${entry.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget bodyContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
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
                onPressed: loadPriceHistory,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final data = summary;

    if (data == null) {
      return const Center(
        child: Text('No price history was found.'),
      );
    }

    return RefreshIndicator(
      onRefresh: loadPriceHistory,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          summarySection(data),
          historySection(data),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price History'),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadPriceHistory,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: bodyContent(),
    );
  }
}