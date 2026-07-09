import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/receipt.dart';

class ReceiptItemsScreen extends StatelessWidget {
  final Receipt receipt;

  const ReceiptItemsScreen({
    super.key,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Items'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receipt.storeName.isEmpty
                        ? 'Unknown Store'
                        : receipt.storeName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${receipt.city}, ${receipt.province}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 70,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No receipt items yet.',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'When OCR is added, SmartCart will automatically extract every product from the receipt and display it here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'OCR receipt scanning will be available in Version 1.0.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Scan Receipt (Coming Soon)'),
          ),
        ],
      ),
    );
  }
}