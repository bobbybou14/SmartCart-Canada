import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/product.dart';
import '../service/favorites_service.dart';
import '../service/price_history_service.dart';
import 'product_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<_FavoriteWatchItem> items = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final favorites = await FavoritesService.getFavorites();

      final loadedItems = <_FavoriteWatchItem>[];

      for (final favorite in favorites) {
        final product = favorite.product;

        if (product == null) {
          continue;
        }

        final summary = await PriceHistoryService.getPriceHistory(
          product.barcode,
        );

        loadedItems.add(
          _FavoriteWatchItem(
            favorite: favorite,
            product: product,
            summary: summary,
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        items = loadedItems;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load favourites: $error';
      });
    }
  }

  Future<void> openProduct(Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          product: product,
        ),
      ),
    );

    if (!mounted) return;

    await loadFavorites();
  }

  Future<void> removeFavorite(
    _FavoriteWatchItem item,
  ) async {
    try {
      await FavoritesService.removeFavorite(
        item.product.barcode,
      );

      if (!mounted) return;

      setState(() {
        items.removeWhere(
          (entry) =>
              entry.product.barcode ==
              item.product.barcode,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.product.name} removed from favourites.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to remove favourite: $error',
          ),
        ),
      );
    }
  }

  String productDisplayName(Product product) {
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

  Color trendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'rising':
        return Colors.red;
      case 'falling':
        return AppColors.success;
      case 'stable':
        return AppColors.warning;
      default:
        return Colors.grey;
    }
  }

  Widget productImage(Product product) {
    if (product.imageUrl.trim().isEmpty) {
      return const Icon(
        Icons.shopping_bag,
        size: 34,
        color: AppColors.primary,
      );
    }

    return Image.network(
      product.imageUrl,
      width: 54,
      height: 54,
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

  Widget favoriteCard(_FavoriteWatchItem item) {
    final summary = item.summary;
    final hasPrice = summary.hasData;

    final changePrefix =
        summary.percentageChange > 0 ? '+' : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openProduct(item.product),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: productImage(item.product),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      productDisplayName(item.product),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.product.category.trim().isEmpty
                          ? 'No category'
                          : item.product.category,
                    ),
                    const SizedBox(height: 10),
                    if (hasPrice) ...[
                      Text(
                        '\$${summary.currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            trendIcon(summary.trend),
                            size: 19,
                            color:
                                trendColor(summary.trend),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${summary.trend} '
                            '($changePrefix${summary.percentageChange.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                                  trendColor(summary.trend),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Best store: ${summary.bestStore}',
                      ),
                    ] else
                      const Text(
                        'No recorded price history yet.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
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
                    onPressed: () =>
                        removeFavorite(item),
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

  Widget loadingState() {
    return const Center(
      child: CircularProgressIndicator(),
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
              size: 62,
            ),
            const SizedBox(height: 16),
            const Text(
              'Favourites Could Not Be Loaded',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage ?? 'An unknown error occurred.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: loadFavorites,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget emptyState() {
    return RefreshIndicator(
      onRefresh: loadFavorites,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          const Icon(
            Icons.star_border,
            size: 90,
            color: AppColors.primary,
          ),
          const SizedBox(height: 18),
          const Text(
            'No Favourite Products Yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Open a product and tap the star to add it to your watchlist.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget favoritesContent() {
    if (isLoading) {
      return loadingState();
    }

    if (errorMessage != null) {
      return errorState();
    }

    if (items.isEmpty) {
      return emptyState();
    }

    return RefreshIndicator(
      onRefresh: loadFavorites,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Your Watchlist',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${items.length} favourite product'
            '${items.length == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 18),
          ...items.map(favoriteCard),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
        actions: [
          IconButton(
            onPressed:
                isLoading ? null : loadFavorites,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Favourites',
          ),
        ],
      ),
      body: favoritesContent(),
    );
  }
}

class _FavoriteWatchItem {
  final FavoriteProduct favorite;
  final Product product;
  final PriceHistorySummary summary;

  const _FavoriteWatchItem({
    required this.favorite,
    required this.product,
    required this.summary,
  });
}