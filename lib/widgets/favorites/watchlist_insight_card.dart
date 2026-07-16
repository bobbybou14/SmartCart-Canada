import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../service/watchlist_intelligence_service.dart';

class WatchlistInsightCard extends StatelessWidget {
  final WatchlistInsight insight;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const WatchlistInsightCard({
    super.key,
    required this.insight,
    required this.onTap,
    required this.onRemove,
  });

  IconData get insightIcon {
    switch (insight.type) {
      case WatchlistInsightType.lowestRecorded:
        return Icons.local_offer;
      case WatchlistInsightType.priceDrop:
        return Icons.trending_down;
      case WatchlistInsightType.priceIncrease:
        return Icons.trending_up;
      case WatchlistInsightType.stable:
        return Icons.trending_flat;
      case WatchlistInsightType.notEnoughData:
        return Icons.info_outline;
    }
  }

  Color get insightColor {
    switch (insight.type) {
      case WatchlistInsightType.lowestRecorded:
        return AppColors.primary;
      case WatchlistInsightType.priceDrop:
        return AppColors.success;
      case WatchlistInsightType.priceIncrease:
        return Colors.red;
      case WatchlistInsightType.stable:
        return AppColors.warning;
      case WatchlistInsightType.notEnoughData:
        return Colors.grey;
    }
  }

  Widget productImage() {
    final product = insight.product;

    if (product.imageUrl.trim().isEmpty) {
      return const Icon(
        Icons.shopping_bag,
        size: 34,
        color: AppColors.primary,
      );
    }

    return Image.network(
      product.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return const Icon(
          Icons.shopping_bag,
          size: 34,
          color: AppColors.primary,
        );
      },
    );
  }

  String get productName {
    final product = insight.product;

    final parts = [
      product.brand,
      product.name,
      product.size,
    ].where((value) => value.trim().isNotEmpty).toList();

    if (parts.isEmpty) {
      return product.barcode;
    }

    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final color = insightColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: productImage(),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            insightIcon,
                            size: 17,
                            color: color,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              insight.headline,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      insight.message,
                      style: const TextStyle(
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(
                      Icons.delete_outline,
                    ),
                    tooltip: 'Remove from favourites',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}