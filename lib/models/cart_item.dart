class CartItem {
  final String barcode;
  final String name;

  final String brand;
  final String category;
  final String size;
  final String imageUrl;
  final String store;

  final double price;
  final bool taxable;

  int quantity;

  CartItem({
    required this.barcode,
    required this.name,
    this.brand = '',
    this.category = '',
    this.size = '',
    this.imageUrl = '',
    this.store = '',
    required this.price,
    required this.taxable,
    this.quantity = 1,
  });

  double get subtotal => price * quantity;

  double get tax => taxable ? subtotal * 0.13 : 0;

  double get total => subtotal + tax;
}