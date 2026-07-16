import 'package:flutter/material.dart';

import '../models/product.dart';
import '../service/favorites_service.dart';
import '../service/watchlist_intelligence_service.dart';
import '../widgets/favorites/watchlist_empty_state.dart';
import '../widgets/favorites/watchlist_error_state.dart';
import '../widgets/favorites/watchlist_header.dart';
import '../widgets/favorites/watchlist_insight_card.dart';
import '../widgets/favorites/watchlist_loading.dart';
import '../widgets/favorites/watchlist_summary_card.dart';
import 'product_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() =>
      _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  WatchlistIntelligenceResult result =
      const WatchlistIntelligenceResult.empty();

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedResult =
          await WatchlistIntelligenceService
              .loadWatchlistIntelligence();

      if (!mounted) return;

      setState(() {
        result = loadedResult;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load favourites: $error';
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

    await loadWatchlist();
  }

  Future<void> removeFavorite(
    WatchlistInsight insight,
  ) async {
    try {
      await FavoritesService.removeFavorite(
        insight.product.barcode,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${insight.product.name} removed from favourites.',
          ),
        ),
      );

      await loadWatchlist();
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

  Widget watchlistContent() {
    if (isLoading) {
      return const WatchlistLoading();
    }

    if (errorMessage != null) {
      return WatchlistErrorState(
        message: errorMessage!,
        onRetry: loadWatchlist,
      );
    }

    if (!result.hasInsights) {
      return WatchlistEmptyState(
        onRefresh: loadWatchlist,
      );
    }

    return RefreshIndicator(
      onRefresh: loadWatchlist,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          WatchlistHeader(
            totalProducts: result.insights.length,
          ),
          const SizedBox(height: 18),
          WatchlistSummaryCard(
            totalProducts: result.insights.length,
            priceDrops: result.priceDrops,
            priceIncreases: result.priceIncreases,
            lowestPrices:
                result.productsAtLowestPrice,
          ),
          const SizedBox(height: 22),
          const Text(
            'Latest Insights',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...result.insights.map(
            (insight) => WatchlistInsightCard(
              insight: insight,
              onTap: () {
                openProduct(insight.product);
              },
              onRemove: () {
                removeFavorite(insight);
              },
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
      appBar: AppBar(
        title: const Text('Favourites'),
        actions: [
          IconButton(
            onPressed:
                isLoading ? null : loadWatchlist,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Watchlist',
          ),
        ],
      ),
      body: watchlistContent(),
    );
  }
}