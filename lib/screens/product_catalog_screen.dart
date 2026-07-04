import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';
import '../core/widgets/product_card.dart';
import 'product_details_screen.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  static const Color smartCartRed = Color(0xFFD6001C);

  final client = Supabase.instance.client;

  List<Product> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final response = await client.from('products').select().order('name');

    setState(() {
      products = response.map<Product>((item) => Product.fromMap(item)).toList();
      loading = false;
    });
  }

  void openProductDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
        backgroundColor: smartCartRed,
        foregroundColor: Colors.white,
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