import 'package:supabase_flutter/supabase_flutter.dart';

class PriceHistoryEntry {
  final String id;
  final String barcode;
  final String store;
  final String province;
  final String city;
  final double price;
  final String currency;
  final String source;
  final DateTime createdAt;

  const PriceHistoryEntry({
    required this.id,
    required this.barcode,
    required this.store,
    required this.province,
    required this.city,
    required this.price,
    required this.currency,
    required this.source,
    required this.createdAt,
  });

  factory PriceHistoryEntry.fromMap(Map<String, dynamic> map) {
    return PriceHistoryEntry(
      id: map['id']?.toString() ?? '',
      barcode: map['barcode']?.toString() ?? '',
      store: map['store']?.toString() ?? '',
      province: map['province']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      price: _toDouble(map['price']),
      currency: map['currency']?.toString() ?? 'CAD',
      source: map['source']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class PriceHistorySummary {
  final List<PriceHistoryEntry> entries;
  final double currentPrice;
  final double lowestPrice;
  final double highestPrice;
  final double averagePrice;
  final String trend;
  final String bestStore;

  const PriceHistorySummary({
    required this.entries,
    required this.currentPrice,
    required this.lowestPrice,
    required this.highestPrice,
    required this.averagePrice,
    required this.trend,
    required this.bestStore,
  });
}

class PriceHistoryService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<PriceHistorySummary> getPriceHistory(
    String barcode,
  ) async {
    final response = await _supabase
        .from('prices')
        .select()
        .eq('barcode', barcode)
        .order('created_at', ascending: true);

    final entries = response
        .map<PriceHistoryEntry>(
          (row) => PriceHistoryEntry.fromMap(row),
        )
        .toList();

    if (entries.isEmpty) {
      return const PriceHistorySummary(
        entries: [],
        currentPrice: 0,
        lowestPrice: 0,
        highestPrice: 0,
        averagePrice: 0,
        trend: 'No data',
        bestStore: 'Not available',
      );
    }

    final prices = entries.map((entry) => entry.price).toList();

    final currentPrice = entries.last.price;
    final lowestPrice = prices.reduce(
      (value, element) => value < element ? value : element,
    );
    final highestPrice = prices.reduce(
      (value, element) => value > element ? value : element,
    );
    final averagePrice =
        prices.fold<double>(0, (total, price) => total + price) /
            prices.length;

    final lowestEntry = entries.reduce(
      (current, next) =>
          next.price < current.price ? next : current,
    );

    final trend = _calculateTrend(entries);

    return PriceHistorySummary(
      entries: entries,
      currentPrice: currentPrice,
      lowestPrice: lowestPrice,
      highestPrice: highestPrice,
      averagePrice: averagePrice,
      trend: trend,
      bestStore:
          lowestEntry.store.trim().isEmpty
              ? 'Unknown Store'
              : lowestEntry.store,
    );
  }

  static String _calculateTrend(
    List<PriceHistoryEntry> entries,
  ) {
    if (entries.length < 2) {
      return 'Not enough data';
    }

    final previousPrice = entries[entries.length - 2].price;
    final currentPrice = entries.last.price;
    final difference = currentPrice - previousPrice;

    if (difference.abs() < 0.01) {
      return 'Stable';
    }

    if (difference > 0) {
      return 'Rising';
    }

    return 'Falling';
  }
}