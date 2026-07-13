import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class StatsGrid extends StatelessWidget {
  final int tripCount;
  final int storeCount;
  final double amountSpent;
  final double averageTripCost;

  const StatsGrid({
    super.key,
    required this.tripCount,
    required this.storeCount,
    required this.amountSpent,
    required this.averageTripCost,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        final columnCount = isNarrow ? 2 : 4;

        return GridView.count(
          crossAxisCount: columnCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isNarrow ? 1.15 : 1.25,
          children: [
            _StatTile(
              icon: Icons.shopping_bag,
              label: 'Shopping Trips',
              value: tripCount.toString(),
              supportingText: 'This month',
            ),
            _StatTile(
              icon: Icons.store,
              label: 'Stores Visited',
              value: storeCount.toString(),
              supportingText: 'This month',
            ),
            _StatTile(
              icon: Icons.attach_money,
              label: 'Amount Spent',
              value: '\$${amountSpent.toStringAsFixed(2)}',
              supportingText: 'Groceries',
            ),
            _StatTile(
              icon: Icons.receipt_long,
              label: 'Average Trip',
              value: '\$${averageTripCost.toStringAsFixed(2)}',
              supportingText: 'Per trip',
            ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String supportingText;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.supportingText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 27,
              ),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              supportingText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}