import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/cart_item.dart';
import '../service/product_service.dart';
import '../service/supabase_product_service.dart';
import '../service/upc_lookup_service.dart';

class ScanScreen extends StatefulWidget {
  final void Function(CartItem item) onItemScanned;

  const ScanScreen({
    super.key,
    required this.onItemScanned,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  static const Color smartCartRed = Color(0xFFD6001C);

  final TextEditingController barcodeController = TextEditingController();

  CartItem? scannedItem;
  String message = 'Point your camera at a barcode or type one below.';
  bool hasScanned = false;
  bool isLoading = false;

  Future<void> lookupBarcode(String barcode) async {
    if (barcode.trim().isEmpty) return;

    setState(() {
      hasScanned = true;
      isLoading = true;
      scannedItem = null;
      message = 'Looking up product...\n\nBarcode:\n$barcode';
    });

    CartItem? product = await SupabaseProductService.findByBarcode(barcode);

    product ??= await ProductService.findByBarcode(barcode);

    if (product == null) {
      product = await UpcLookupService.lookup(barcode);

      if (product != null) {
        await SupabaseProductService.saveProduct(product.product);
      }
    }

    if (!mounted) return;

    setState(() {
      scannedItem = product;
      isLoading = false;
      message = product == null ? 'Product not found.\n\nBarcode:\n$barcode' : '';
    });
  }

  void resetScanner() {
    setState(() {
      hasScanned = false;
      scannedItem = null;
      isLoading = false;
      message = 'Point your camera at a barcode or type one below.';
      barcodeController.clear();
    });
  }

  @override
  void dispose() {
    barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Grocery Item'),
        backgroundColor: smartCartRed,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MobileScanner(
              onDetect: (capture) {
                final barcode = capture.barcodes.first.rawValue;
                if (barcode != null && !hasScanned) {
                  barcodeController.text = barcode;
                  lookupBarcode(barcode);
                }
              },
            ),
          ),
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: barcodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter barcode manually',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => lookupBarcode(barcodeController.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: smartCartRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Lookup Barcode'),
                    ),
                  ),
                  const SizedBox(height: 25),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else if (scannedItem == null)
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                    )
                  else
                    Column(
                      children: [
                        Text(
                          scannedItem!.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          scannedItem!.price == 0
                              ? 'Price not available yet'
                              : '\$${scannedItem!.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          scannedItem!.taxable
                              ? 'Ontario HST Applies'
                              : 'No HST',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            widget.onItemScanned(scannedItem!);
                            resetScanner();
                          },
                          child: const Text('Add to Cart'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: resetScanner,
                          child: const Text('Scan Another Item'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}