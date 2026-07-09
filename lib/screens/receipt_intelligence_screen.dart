import 'package:flutter/material.dart';

import '../service/receipt_intelligence_service.dart';

class ReceiptIntelligenceScreen extends StatefulWidget {
  const ReceiptIntelligenceScreen({super.key});

  @override
  State<ReceiptIntelligenceScreen> createState() =>
      _ReceiptIntelligenceScreenState();
}

class _ReceiptIntelligenceScreenState extends State<ReceiptIntelligenceScreen> {
  final TextEditingController textController = TextEditingController();

  ReceiptIntelligenceResult? result;
  bool isLoading = false;

  Future<void> processReceipt() async {
    setState(() {
      isLoading = true;
      result = null;
    });

    try {
      final processed =
          await ReceiptIntelligenceService.processRawText(textController.text);

      if (!mounted) return;

      setState(() {
        result = processed;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receipt processing failed: $error')),
      );
    }
  }

  void loadSampleText() {
    textController.text =
        'WALMART\n'
        '2026-07-09\n'
        'MLK HOMO 2L 5.49\n'
        'WHT BRD 3.29\n'
        'BNNS 1.264 KG 2.73\n'
        'EGGS 4.99\n'
        'SUBTOTAL 16.50\n'
        'HST 0.65\n'
        'TOTAL 17.15\n'
        'VISA CARD ****1234\n'
        'AUTH 123456';
  }

  Widget resultCard() {
    final data = result;
    if (data == null) return const SizedBox.shrink();

    final receipt = data.parsedReceipt;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Receipt Intelligence Result',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Store: ${receipt.storeName.isEmpty ? "Not found" : receipt.storeName}'),
            Text('Items found: ${receipt.items.length}'),
            Text('High confidence matches: ${data.highConfidenceMatches}'),
            Text('Review required: ${data.reviewRequired}'),
            const SizedBox(height: 16),
            ...data.productMatches.map(
              (match) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(match.receiptItem.name),
                subtitle: Text(
                  match.product == null
                      ? 'No product match found'
                      : 'Matched: ${match.product!.brand} ${match.product!.name} ${match.product!.size}\n${match.reason}',
                ),
                trailing: Text(
                  '${match.confidenceScore.toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Intelligence'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Receipt Intelligence',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Paste raw receipt text and SmartCart will parse it, match products, and identify items that need review.',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: textController,
            minLines: 10,
            maxLines: 18,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Raw receipt text',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: isLoading ? null : loadSampleText,
            icon: const Icon(Icons.text_snippet),
            label: const Text('Load Sample Receipt Text'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: isLoading ? null : processReceipt,
            icon: const Icon(Icons.auto_awesome),
            label: Text(isLoading ? 'Processing...' : 'Process Receipt'),
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            resultCard(),
        ],
      ),
    );
  }
}