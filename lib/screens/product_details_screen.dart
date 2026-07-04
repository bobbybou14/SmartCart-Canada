import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/price.dart';
import '../service/price_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  static const Color smartCartRed = Color(0xFFD6001C);

  List<Price> prices = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPrices();
  }

  Future<void> loadPrices() async {
    final results = await PriceService.getPricesForProduct(widget.product.barcode);

    setState(() {
      prices = results;
      loading = false;
    });
  }

  double get averagePrice {
    if (prices.isEmpty) return 0;
    final total = prices.fold<double>(0, (sum, price) => sum + price.price);
    return total / prices.length;
  }

  Widget productImage() {
    if (widget.product.imageUrl.isEmpty) {
      return const Icon(Icons.shopping_bag, size: 110, color: smartCartRed);
    }

    return Image.network(
      widget.product.imageUrl,
      height: 160,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return const Icon(Icons.shopping_bag, size: 110, color: smartCartRed);
      },
    );
  }

  Widget priceCard(Price price, int index) {
    final isCheapest = index == 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(
          isCheapest ? Icons.emoji_events : Icons.store,
          color: isCheapest ? Colors.orange : smartCartRed,
        ),
        title: Text(
          price.store.isEmpty ? 'Unknown Store' : price.store,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${price.city}, ${price.province}',
        ),
        trailing: Text(
          '\$${price.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isCheapest ? Colors.green : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: smartCartRed,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: loadPrices,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            productImage(),
            const SizedBox(height: 20),
            Text(
              product.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            if (product.brand.isNotEmpty)
              Text(
                product.brand,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            if (product.size.isNotEmpty)
              Text(
                product.size,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 10),
            Text(
              product.taxable ? 'Ontario HST Applies' : 'No HST',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            const Text(
              'Current Prices',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (prices.isEmpty)
              const Text(
                'No prices found yet.',
                style: TextStyle(fontSize: 18),
              )
            else ...[
              ...prices.asMap().entries.map(
                    (entry) => priceCard(entry.value, entry.key),
                  ),
              const SizedBox(height: 15),
              Text(
                'Average Price: \$${averagePrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}