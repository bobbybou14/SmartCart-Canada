import 'package:flutter/material.dart';

import '../models/product.dart';
import '../service/basket_comparison_service.dart';
import '../service/product_service.dart';
import '../widgets/store_comparison_card.dart';

class BasketComparisonScreen extends StatefulWidget {
  final List<BasketItemRequest> initialItems;

  const BasketComparisonScreen({
    super.key,
    this.initialItems = const [],
  });

  @override
  State<BasketComparisonScreen> createState() =>
      _BasketComparisonScreenState();
}

class _BasketComparisonScreenState extends State<BasketComparisonScreen> {
  List<Product> products = [];
  final Map<String, double> selectedQuantities = {};

  BasketComparisonResult? comparisonResult;

  bool isLoadingProducts = true;
  bool isComparing = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    for (final item in widget.initialItems) {
      selectedQuantities[item.product.barcode] = item.quantity;
    }

    loadProducts();
  }

  Future<void> loadProducts() async {
    setState(() {
      isLoadingProducts = true;
      errorMessage = null;
    });

    try {
      final loadedProducts = await ProductService.getProducts();

      for (final initialItem in widget.initialItems) {
        final alreadyIncluded = loadedProducts.any(
          (product) =>
              product.barcode == initialItem.product.barcode,
        );

        if (!alreadyIncluded) {
          loadedProducts.add(initialItem.product);
        }
      }

      loadedProducts.sort(
        (a, b) => productDisplayName(a).compareTo(
          productDisplayName(b),
        ),
      );

      if (!mounted) return;

      setState(() {
        products = loadedProducts;
        isLoadingProducts = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoadingProducts = false;
        errorMessage = 'Unable to load products: $error';
      });
    }
  }

  Future<void> compareBasket() async {
    final basketItems = products
        .where(
          (product) =>
              (selectedQuantities[product.barcode] ?? 0) > 0,
        )
        .map(
          (product) => BasketItemRequest(
            product: product,
            quantity:
                selectedQuantities[product.barcode] ?? 1,
          ),
        )
        .toList();

    if (basketItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Select at least one product before comparing.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isComparing = true;
      comparisonResult = null;
      errorMessage = null;
    });

    try {
      final result =
          await BasketComparisonService.compareBasket(
        basketItems,
      );

      if (!mounted) return;

      setState(() {
        comparisonResult = result;
        isComparing = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isComparing = false;
        errorMessage = 'Unable to compare basket: $error';
      });
    }
  }

  void increaseQuantity(Product product) {
    setState(() {
      final current =
          selectedQuantities[product.barcode] ?? 0;

      selectedQuantities[product.barcode] = current + 1;
      comparisonResult = null;
    });
  }

  void decreaseQuantity(Product product) {
    setState(() {
      final current =
          selectedQuantities[product.barcode] ?? 0;

      if (current <= 1) {
        selectedQuantities.remove(product.barcode);
      } else {
        selectedQuantities[product.barcode] = current - 1;
      }

      comparisonResult = null;
    });
  }

  void clearBasket() {
    setState(() {
      selectedQuantities.clear();
      comparisonResult = null;
    });
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

  int get selectedProductCount {
    return selectedQuantities.values
        .where((quantity) => quantity > 0)
        .length;
  }

  double get selectedUnitCount {
    return selectedQuantities.values.fold<double>(
      0,
      (total, quantity) => total + quantity,
    );
  }

  Widget basketSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              child: Icon(Icons.shopping_cart),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Basket',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$selectedProductCount product'
                    '${selectedProductCount == 1 ? '' : 's'} • '
                    '${selectedUnitCount.toStringAsFixed(0)} total item'
                    '${selectedUnitCount == 1 ? '' : 's'}',
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: selectedQuantities.isEmpty
                  ? null
                  : clearBasket,
              child: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }

  Widget productCard(Product product) {
    final quantity =
        selectedQuantities[product.barcode] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              child: Icon(
                quantity > 0
                    ? Icons.check
                    : Icons.inventory_2,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    productDisplayName(product),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category.trim().isEmpty
                        ? 'No category'
                        : product.category,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: quantity <= 0
                  ? null
                  : () => decreaseQuantity(product),
              icon: const Icon(
                Icons.remove_circle_outline,
              ),
              tooltip: 'Decrease quantity',
            ),
            SizedBox(
              width: 34,
              child: Text(
                quantity.toStringAsFixed(0),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () => increaseQuantity(product),
              icon: const Icon(
                Icons.add_circle_outline,
              ),
              tooltip: 'Increase quantity',
            ),
          ],
        ),
      ),
    );
  }

  Widget cheapestBasketSummary(
    BasketComparisonResult result,
  ) {
    final cheapest = result.cheapestCompleteStore;

    if (cheapest == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.warning_amber,
                size: 46,
                color: Colors.orange,
              ),
              SizedBox(height: 12),
              Text(
                'No Complete Basket Available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'No store currently has recorded prices for every item in this basket. Partial totals are shown below but are not eligible for cheapest-basket ranking.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 32,
                  color: Colors.green,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cheapest Complete Basket',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              cheapest.storeName,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${cheapest.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              result.potentialSavings > 0
                  ? 'Potential savings compared with the highest complete basket: '
                      '\$${result.potentialSavings.toStringAsFixed(2)}'
                  : 'Add more complete store price data to calculate potential savings.',
            ),
          ],
        ),
      ),
    );
  }

  Widget comparisonSummary(
    BasketComparisonResult result,
  ) {
    final cheapest = result.cheapestCompleteStore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 26),
        const Text(
          'Comparison Results',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        cheapestBasketSummary(result),
        const SizedBox(height: 14),
        ...result.stores.map(
          (store) => StoreComparisonCard(
            store: store,
            isCheapest: cheapest != null &&
                store.storeId == cheapest.storeId,
            potentialSavings: result.potentialSavings,
          ),
        ),
      ],
    );
  }

  Widget loadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget fullPageErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget emptyProductsState() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 56,
            ),
            SizedBox(height: 14),
            Text(
              'No Products Available',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add products to SmartCart before building a basket comparison.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget bodyContent() {
    if (isLoadingProducts) {
      return loadingState();
    }

    if (errorMessage != null && products.isEmpty) {
      return fullPageErrorState();
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Basket Comparison',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose products and quantities, then compare the latest recorded prices across stores.',
          style: TextStyle(fontSize: 17),
        ),
        const SizedBox(height: 18),
        basketSummaryCard(),
        const SizedBox(height: 18),
        if (products.isEmpty)
          emptyProductsState()
        else
          ...products.map(productCard),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isComparing ? null : compareBasket,
            icon: isComparing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.compare_arrows),
            label: Text(
              isComparing
                  ? 'Comparing...'
                  : 'Compare Basket',
            ),
          ),
        ),
        if (errorMessage != null &&
            products.isNotEmpty) ...[
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (comparisonResult != null)
          comparisonSummary(comparisonResult!),
        const SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basket Comparison'),
        actions: [
          IconButton(
            onPressed:
                isLoadingProducts || isComparing
                    ? null
                    : loadProducts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Products',
          ),
        ],
      ),
      body: bodyContent(),
    );
  }
}