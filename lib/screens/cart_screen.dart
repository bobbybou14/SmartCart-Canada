import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/cart_item.dart';
import '../service/basket_comparison_service.dart';
import 'basket_comparison_screen.dart';
import 'shopping_optimizer_screen.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cart;

  const CartScreen({
    super.key,
    required this.cart,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get subtotal {
    return widget.cart.fold<double>(
      0,
      (total, item) => total + item.subtotal,
    );
  }

  double get hst {
    return widget.cart.fold<double>(
      0,
      (total, item) => total + item.tax,
    );
  }

  double get total => subtotal + hst;

  void increaseQuantity(CartItem item) {
    setState(() {
      item.quantity++;
    });
  }

  void decreaseQuantity(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        widget.cart.remove(item);
      }
    });
  }

  void removeItem(CartItem item) {
    setState(() {
      widget.cart.remove(item);
    });
  }

  void clearCart() {
    setState(() {
      widget.cart.clear();
    });
  }

  void openOptimizer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShoppingOptimizerScreen(
          cart: widget.cart,
        ),
      ),
    );
  }

  void openBasketComparison() {
    final basketItems = widget.cart.map(
      (item) {
        return BasketItemRequest(
          product: item.product,
          quantity: item.quantity.toDouble(),
        );
      },
    ).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BasketComparisonScreen(
          initialItems: basketItems,
        ),
      ),
    );
  }

  Widget productImage(CartItem item) {
    if (item.imageUrl.isEmpty) {
      return const Icon(
        Icons.shopping_bag,
        size: 42,
        color: AppColors.primary,
      );
    }

    return Image.network(
      item.imageUrl,
      width: 55,
      height: 55,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return const Icon(
          Icons.shopping_bag,
          size: 42,
          color: AppColors.primary,
        );
      },
    );
  }

  Widget emptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 90,
              color: AppColors.primary,
            ),
            const SizedBox(height: 18),
            const Text(
              'Your cart is empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add products from the scanner or product catalog '
              'to begin building your grocery basket.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget cartItemCard(CartItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: productImage(item),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.brand.isEmpty
                        ? item.name
                        : '${item.brand} ${item.name}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.size.isEmpty ? "" : "${item.size} • "}'
                    '\$${item.price.toStringAsFixed(2)} each',
                  ),
                  Text(
                    item.taxable
                        ? 'Ontario HST applies'
                        : 'No HST',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Line total: '
                    '\$${item.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () =>
                      increaseQuantity(item),
                  icon: const Icon(
                    Icons.add_circle_outline,
                  ),
                  tooltip: 'Increase quantity',
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      decreaseQuantity(item),
                  icon: const Icon(
                    Icons.remove_circle_outline,
                  ),
                  tooltip: 'Decrease quantity',
                ),
                IconButton(
                  onPressed: () => removeItem(item),
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  tooltip: 'Remove item',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget cartSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _totalRow('Subtotal', subtotal),
            _totalRow('Ontario HST', hst),
            const Divider(),
            _totalRow(
              'Estimated Total',
              total,
              bold: true,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: openBasketComparison,
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Compare My Cart'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: openOptimizer,
                icon: const Icon(Icons.auto_graph),
                label: const Text('Optimize Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          if (widget.cart.isNotEmpty)
            IconButton(
              onPressed: clearCart,
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear Cart',
            ),
        ],
      ),
      body: widget.cart.isEmpty
          ? emptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 6,
                      bottom: 6,
                    ),
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      return cartItemCard(
                        widget.cart[index],
                      );
                    },
                  ),
                ),
                cartSummary(),
              ],
            ),
    );
  }

  Widget _totalRow(
    String label,
    double amount, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}