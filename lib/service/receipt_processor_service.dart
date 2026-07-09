import '../models/receipt.dart';

class ReceiptProcessorService {
  /// This is the first version of the receipt processing pipeline.
  ///
  /// Later this will run:
  /// 1. OCR
  /// 2. Privacy filtering
  /// 3. Product matching
  /// 4. Price extraction
  /// 5. Confidence scoring
  static Future<ReceiptProcessingResult> processReceipt(Receipt receipt) async {
    return ReceiptProcessingResult(
      receiptId: receipt.id,
      status: 'ready_for_ocr',
      personalDataRedacted: true,
      rawImageStored: receipt.rawImageStored,
      productsFound: 0,
      productsMatched: 0,
      pricesUpdated: 0,
      message: 'Receipt saved and ready for OCR processing.',
    );
  }
}

class ReceiptProcessingResult {
  final String receiptId;
  final String status;
  final bool personalDataRedacted;
  final bool rawImageStored;
  final int productsFound;
  final int productsMatched;
  final int pricesUpdated;
  final String message;

  const ReceiptProcessingResult({
    required this.receiptId,
    required this.status,
    required this.personalDataRedacted,
    required this.rawImageStored,
    required this.productsFound,
    required this.productsMatched,
    required this.pricesUpdated,
    required this.message,
  });
}