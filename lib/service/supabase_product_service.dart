import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class SupabaseProductService {
  static final _client = Supabase.instance.client;

  static Future<CartItem?> findByBarcode(String barcode) async {
    final response = await _client
        .from('products')
        .select()
        .eq('barcode', barcode)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final product = Product.fromMap(response);

    return CartItem(
      product: product,
      price: 0.00,
    );
  }

  static Future<void> saveProduct(Product product) async {
    await _client.from('products').upsert(product.toMap());
  }
}