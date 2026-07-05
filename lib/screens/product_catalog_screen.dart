import 'package:flutter/material.dart';

import '../core/widgets/product_card.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../service/supabase_product_service.dart';
import 'product_details_screen.dart';

class ProductCatalogScreen extends StatefulWidget {
  final void Function(CartItem item)? onAddToCart;

  const ProductCatalogScreen({
    super.key,
    this.onAddToCart,
  });

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  List<Product> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final results = await SupabaseProductService.getProducts();

    if (!mounted) return;

    setState(() {
      products = results;
      loading = false;
    });
  }

  void openProductDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          product: product,
          onAddToCart: widget.onAddToCart,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(
                  child: Text(
                    'No products found.',
                    style: TextStyle(fontSize: 22),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadProducts,
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return ProductCard(
                        product: product,
                        onTap: () => openProductDetails(product),
                      );
                    },
                  ),
                ),
    );
  }
}