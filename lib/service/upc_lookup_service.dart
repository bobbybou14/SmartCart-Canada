import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/cart_item.dart';

class UpcLookupService {
  static Future<CartItem?> lookup(String barcode) async {
    final url = Uri.parse(
      'https://world.openfoodfacts.org/api/v2/product/$barcode.json',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);

    if (data['status'] != 1) {
      return null;
    }

    final product = data['product'];

    final name = product['product_name'] ?? 'Unknown Product';
    final brand = product['brands'] ?? '';
    final imageUrl = product['image_front_url'] ?? '';
    final quantity = product['quantity'] ?? '';

    return CartItem(
      barcode: barcode,
      name: name,
      brand: brand,
      size: quantity,
      imageUrl: imageUrl,
      price: 0.00,
      taxable: false,
    );
  }
}