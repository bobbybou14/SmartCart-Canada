import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/store_branding.dart';
import '../store/store_badge.dart';

class BestStoreCard extends StatelessWidget {
  final String storeName;
  final double totalSpent;
  final double averageTripCost;
  final int trips;
  final bool hasData;

  const BestStoreCard({
    super.key,
    required this.storeName,
    required this.totalSpent,
    required this.averageTripCost,
    required this.trips,
    required this.hasData,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasData) {
      return const _EmptyBestStoreCard();
    }

    final branding = StoreBranding.fromStoreName(storeName);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              branding.backgroundColor,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: branding.backgroundColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: branding.primaryColor.withValues(
                    alpha: 0.25,
                  ),
                ),
              ),
              child: Icon(
                branding.icon,
                size: 38,
                color: branding.primaryColor,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Most Visited Store This Month',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StoreBadge(
                    storeName: branding.displayName,
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.shopping_bag_outlined,
                    text:
                        '$trips shopping trip${trips == 1 ? '' : 's'}',
                    color: branding.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.receipt_long_outlined,
                    text:
                        '\$${averageTripCost.toStringAsFixed(2)} average trip',
                    color: branding.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.payments_outlined,
                    text:
                        '\$${totalSpent.toStringAsFixed(2)} spent there',
                    color: branding.primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyBestStoreCard extends StatelessWidget {
  const _EmptyBestStoreCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 30,
        ),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.store_outlined,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Store Insights Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Shopping trips saved this month will be used to identify your most visited store.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}