import '../models/cart_item.dart';

class ProductService {
  static final Map<String, CartItem> products = {
    '000001': CartItem(
      barcode: '000001',
      name: 'Milk',
      price: 5.49,
      taxable: false,
    ),
    '000002': CartItem(
      barcode: '000002',
      name: 'Bread',
      price: 3.29,
      taxable: false,
    ),
    '000003': CartItem(
      barcode: '000003',
      name: 'Paper Towels',
      price: 9.99,
      taxable: true,
    ),
  };

  static CartItem? findByBarcode(String barcode) {
    return products[barcode];
  }
}