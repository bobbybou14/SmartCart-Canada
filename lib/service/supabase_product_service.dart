import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart_item.dart';

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

    return CartItem(
      barcode: response['barcode'] ?? barcode,
      name: response['name'] ?? 'Unknown Product',
      brand: response['brand'] ?? '',
      category: response['category'] ?? '',
      size: response['size'] ?? '',
      imageUrl: response['image_url'] ?? '',
      price: 0.00,
      taxable: response['taxable'] ?? false,
    );
  }

  static Future<void> saveProduct(CartItem item) async {
    await _client.from('products').upsert({
      'barcode': item.barcode,
      'name': item.name,
      'brand': item.brand,
      'category': item.category,
      'size': item.size,
      'image_url': item.imageUrl,
      'taxable': item.taxable,
    });
  }
}