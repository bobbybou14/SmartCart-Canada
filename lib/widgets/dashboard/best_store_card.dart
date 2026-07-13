import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/store_branding.dart';

class BestStoreCard extends StatelessWidget {
  final String storeName;
  final double averageSavings;
  final int trips;

  const BestStoreCard({
    super.key,
    required this.storeName,
    required this.averageSavings,
    required this.trips,
  });

  @override
  Widget build(BuildContext context) {
    final branding = StoreBranding.fromStoreName(storeName);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: branding.backgroundColor,
                borderRadius: BorderRadius.circular(18),
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Best Store',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    branding.displayName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: branding.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.savings,
                        size: 18,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '\$${averageSavings.toStringAsFixed(2)} average savings',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.shopping_bag,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$trips shopping trip${trips == 1 ? '' : 's'}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 38,
            ),
          ],
        ),
      ),
    );
  }
}