import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/price.dart';
import '../service/price_service.dart';
import 'add_price_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final void Function(CartItem item)? onAddToCart;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.onAddToCart,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  List<Price> prices = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPrices();
  }

  Future<void> loadPrices() async {
    final results = await PriceService.getPricesForProduct(widget.product.barcode);

    if (!mounted) return;

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

  double get lowestPrice => prices.isEmpty ? 0 : prices.first.price;

  double get highestPrice {
    if (prices.isEmpty) return 0;
    return prices.map((p) => p.price).reduce((a, b) => a > b ? a : b);
  }

  double get potentialSavings {
    if (prices.length < 2) return 0;
    return highestPrice - lowestPrice;
  }

  Future<void> openAddPriceScreen() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddPriceScreen(product: widget.product),
      ),
    );

    if (saved == true) {
      setState(() {
        loading = true;
      });
      await loadPrices();
    }
  }

  void addToCart() {
    if (widget.onAddToCart == null) return;

    final item = CartItem(
      product: widget.product,
      price: lowestPrice,
    );

    widget.onAddToCart!(item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.product.name} added to cart')),
    );
  }

  Widget productImage() {
    if (widget.product.imageUrl.isEmpty) {
      return const Icon(
        Icons.shopping_bag,
        size: 110,
        color: AppColors.primary,
      );
    }

    return Image.network(
      widget.product.imageUrl,
      height: 160,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return const Icon(
          Icons.shopping_bag,
          size: 110,
          color: AppColors.primary,
        );
      },
    );
  }

  Widget priceSummaryCard() {
    if (prices.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text(
            'No price data yet.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final bestPrice = prices.first;

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🥇 Best Price',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              bestPrice.store.isEmpty ? 'Unknown Store' : bestPrice.store,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              '\$${bestPrice.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            const Divider(height: 28),
            _summaryRow('Average Price', averagePrice),
            _summaryRow('Highest Price', highestPrice),
            _summaryRow('Potential Savings', potentialSavings),
            const SizedBox(height: 6),
            Text(
              '${prices.length} store${prices.length == 1 ? '' : 's'} compared',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 17)),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget priceCard(Price price, int index) {
    final isCheapest = index == 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(
          isCheapest ? Icons.emoji_events : Icons.store,
          color: isCheapest ? AppColors.warning : AppColors.primary,
        ),
        title: Text(
          price.store.isEmpty ? 'Unknown Store' : price.store,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${price.city}, ${price.province}'),
        trailing: Text(
          '\$${price.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isCheapest ? AppColors.success : AppColors.textPrimary,
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
      ),
      body: RefreshIndicator(
        onRefresh: loadPrices,
        color: AppColors.primary,
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
            const SizedBox(height: 25),
            if (widget.onAddToCart != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: addToCart,
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Add to Cart'),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: openAddPriceScreen,
                icon: const Icon(Icons.add),
                label: const Text('Add Price'),
              ),
            ),
            const SizedBox(height: 25),
            priceSummaryCard(),
            const SizedBox(height: 25),
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
            else
              ...prices.asMap().entries.map(
                    (entry) => priceCard(entry.value, entry.key),
                  ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}