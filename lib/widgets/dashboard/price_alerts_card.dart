import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PriceAlertsCard extends StatelessWidget {
  const PriceAlertsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for now.
    // Later this will come from PriceHistoryService.
    const alerts = [
      _PriceAlert(
        product: 'Neilson 2% Milk',
        store: 'Food Basics',
        percentChange: -9.2,
      ),
      _PriceAlert(
        product: 'Large Eggs',
        store: 'FreshCo',
        percentChange: -14.3,
      ),
      _PriceAlert(
        product: 'Salted Butter',
        store: 'Metro',
        percentChange: 6.4,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: AppColors.primary,
                ),
                SizedBox(width: 10),
                Text(
                  'Price Alerts',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...alerts.map(
              (alert) => _PriceAlertTile(alert: alert),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceAlertTile extends StatelessWidget {
  final _PriceAlert alert;

  const _PriceAlertTile({
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final isDrop = alert.percentChange < 0;

    final color = isDrop
        ? AppColors.success
        : Colors.red;

    final icon = isDrop
        ? Icons.trending_down
        : Icons.trending_up;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      title: Text(
        alert.product,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(alert.store),
      trailing: Text(
        '${isDrop ? '' : '+'}${alert.percentChange.toStringAsFixed(1)}%',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _PriceAlert {
  final String product;
  final String store;
  final double percentChange;

  const _PriceAlert({
    required this.product,
    required this.store,
    required this.percentChange,
  });
}