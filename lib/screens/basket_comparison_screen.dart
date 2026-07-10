import 'package:flutter/material.dart';

import '../models/product.dart';
import '../service/basket_comparison_service.dart';
import '../service/product_service.dart';

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
        .where((product) {
          return (selectedQuantities[product.barcode] ?? 0) > 0;
        })
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

  String storeLocation(BasketStoreComparison store) {
    return [
      store.city,
      store.province,
    ].where((value) => value.trim().isNotEmpty).join(', ');
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
            const SizedBox(width: 12),
            IconButton(
              onPressed: quantity <= 0
                  ? null
                  : () => decreaseQuantity(product),
              icon:
                  const Icon(Icons.remove_circle_outline),
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
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Increase quantity',
            ),
          ],
        ),
      ),
    );
  }

  Widget storeComparisonCard(
    BasketStoreComparison store, {
    required bool isCheapest,
  }) {
    final location = storeLocation(store);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Icon(
            isCheapest
                ? Icons.emoji_events
                : Icons.store,
          ),
        ),
        title: Text(
          store.storeName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${location.isEmpty ? "" : "$location\n"}'
          '${store.pricedItems} priced, '
          '${store.missingItems} missing',
        ),
        trailing: Text(
          store.total <= 0
              ? 'No total'
              : '\$${store.total.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isCheapest ? Colors.green : null,
          ),
        ),
        children: [
          const Divider(height: 1),
          ...store.items.map(
            (item) => ListTile(
              title: Text(item.productName),
              subtitle: Text(
                'Quantity: '
                '${item.quantity.toStringAsFixed(0)}',
              ),
              trailing: item.hasPrice
                  ? Text(
                      '\$${item.lineTotal!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Text(
                      'Missing',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
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
        const SizedBox(height: 24),
        const Text(
          'Comparison Results',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (cheapest == null)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'No store currently has prices for every item '
                'in this basket.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Cheapest Complete Basket',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cheapest.storeName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${cheapest.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.potentialSavings > 0
                        ? 'Potential savings: '
                            '\$${result.potentialSavings.toStringAsFixed(2)}'
                        : 'Add more store price data to calculate savings.',
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        ...result.stores.map(
          (store) => storeComparisonCard(
            store,
            isCheapest: cheapest != null &&
                store.storeId == cheapest.storeId,
          ),
        ),
      ],
    );
  }

  Widget bodyContent() {
    if (isLoadingProducts) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null && products.isEmpty) {
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
          'Choose products and quantities, then compare '
          'the latest recorded prices across stores.',
          style: TextStyle(fontSize: 17),
        ),
        const SizedBox(height: 16),
        basketSummaryCard(),
        const SizedBox(height: 16),
        if (products.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No products are available yet.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...products.map(productCard),
        const SizedBox(height: 16),
        FilledButton.icon(
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
        if (errorMessage != null &&
            products.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            errorMessage!,
            style: const TextStyle(
              color: Colors.red,
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