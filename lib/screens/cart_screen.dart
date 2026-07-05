import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/cart_item.dart';
import 'shopping_optimizer_screen.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cart;

  const CartScreen({super.key, required this.cart});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get subtotal {
    return widget.cart.fold(0, (total, item) => total + item.subtotal);
  }

  double get hst {
    return widget.cart.fold(0, (total, item) => total + item.tax);
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

  void openOptimizer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShoppingOptimizerScreen(cart: widget.cart),
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
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.shopping_bag,
          size: 42,
          color: AppColors.primary,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: widget.cart.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(fontSize: 22),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: productImage(item),
                          ),
                          title: Text(
                            item.brand.isEmpty
                                ? item.name
                                : '${item.brand} ${item.name}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item.size.isEmpty ? "" : "${item.size} • "}'
                            '\$${item.price.toStringAsFixed(2)} each • '
                            '${item.taxable ? "13% HST" : "No HST"}',
                          ),
                          trailing: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () => decreaseQuantity(item),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                onPressed: () => increaseQuantity(item),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                              IconButton(
                                onPressed: () => removeItem(item),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.divider)),
                  ),
                  child: Column(
                    children: [
                      _totalRow('Subtotal', subtotal),
                      _totalRow('Ontario HST', hst),
                      const Divider(),
                      _totalRow('Estimated Total', total, bold: true),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: openOptimizer,
                          icon: const Icon(Icons.auto_graph),
                          label: const Text('Optimize Cart'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _totalRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}