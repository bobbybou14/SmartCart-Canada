import '../models/cart_item.dart';
import '../models/product.dart';

class ProductService {
  static final Map<String, Product> products = {
    '000001': const Product(
      barcode: '000001',
      name: 'Milk',
      category: 'Dairy',
      size: '2 L',
      taxable: false,
    ),
    '000002': const Product(
      barcode: '000002',
      name: 'Bread',
      category: 'Bakery',
      size: '675 g',
      taxable: false,
    ),
    '000003': const Product(
      barcode: '000003',
      name: 'Paper Towels',
      category: 'Household',
      size: '6 rolls',
      taxable: true,
    ),
  };

  static CartItem? findByBarcode(String barcode) {
    final product = products[barcode];

    if (product == null) {
      return null;
    }

    return CartItem(
      product: product,
      price: barcode == '000001'
          ? 5.49
          : barcode == '000002'
              ? 3.29
              : 9.99,
    );
  }
}