import '../models/cart_item.dart';
import '../models/price.dart';
import 'price_service.dart';

class StoreRecommendation {
  final String store;
  final double total;
  final int itemsFound;
  final int totalItems;

  const StoreRecommendation({
    required this.store,
    required this.total,
    required this.itemsFound,
    required this.totalItems,
  });

  bool get hasCompleteCart => itemsFound == totalItems;
}

class ShoppingOptimizerService {
  /// Calculates the total cost of the current cart at every store.
  static Future<List<StoreRecommendation>> optimize(
      List<CartItem> cart) async {
    if (cart.isEmpty) {
      return [];
    }

    final Map<String, double> storeTotals = {};
    final Map<String, int> storeItemCounts = {};

    for (final item in cart) {
      final List<Price> prices =
          await PriceService.getPricesForProduct(item.barcode);

      for (final price in prices) {
        storeTotals.update(
          price.store,
          (value) => value + (price.price * item.quantity),
          ifAbsent: () => price.price * item.quantity,
        );

        storeItemCounts.update(
          price.store,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final recommendations = <StoreRecommendation>[];

    for (final entry in storeTotals.entries) {
      recommendations.add(
        StoreRecommendation(
          store: entry.key,
          total: entry.value,
          itemsFound: storeItemCounts[entry.key] ?? 0,
          totalItems: cart.length,
        ),
      );
    }

    recommendations.sort((a, b) => a.total.compareTo(b.total));

    return recommendations;
  }

  /// Returns the cheapest store that has prices for the most items.
  static Future<StoreRecommendation?> bestStore(
      List<CartItem> cart) async {
    final recommendations = await optimize(cart);

    if (recommendations.isEmpty) {
      return null;
    }

    recommendations.sort((a, b) {
      if (a.itemsFound != b.itemsFound) {
        return b.itemsFound.compareTo(a.itemsFound);
      }

      return a.total.compareTo(b.total);
    });

    return recommendations.first;
  }
}