class ParsedReceipt {
  final String storeName;
  final DateTime? purchaseDate;
  final double subtotal;
  final double tax;
  final double total;
  final List<ParsedReceiptItem> items;
  final List<String> ignoredSensitiveLines;

  const ParsedReceipt({
    this.storeName = '',
    this.purchaseDate,
    this.subtotal = 0,
    this.tax = 0,
    this.total = 0,
    this.items = const [],
    this.ignoredSensitiveLines = const [],
  });
}

class ParsedReceiptItem {
  final String name;
  final double price;
  final double quantity;
  final double confidenceScore;

  const ParsedReceiptItem({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.confidenceScore = 70,
  });
}

class ReceiptParserService {
  static ParsedReceipt parse(String rawText) {
    final lines = rawText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final ignoredSensitiveLines = <String>[];
    final items = <ParsedReceiptItem>[];

    String storeName = '';
    DateTime? purchaseDate;
    double subtotal = 0;
    double tax = 0;
    double total = 0;

    for (final line in lines) {
      final upper = line.toUpperCase();

      if (_isSensitiveLine(upper)) {
        ignoredSensitiveLines.add(line);
        continue;
      }

      storeName = storeName.isEmpty ? _detectStoreName(line) : storeName;
      purchaseDate ??= _detectDate(line);

      final amount = _extractAmount(line);

      if (amount != null) {
        if (upper.contains('SUBTOTAL') || upper.contains('SUB TOTAL')) {
          subtotal = amount;
        } else if (upper.contains('HST') ||
            upper.contains('TAX') ||
            upper.contains('GST')) {
          tax = amount;
        } else if (upper.contains('TOTAL')) {
          total = amount;
        } else if (!_isNonProductLine(upper)) {
          final name = _removeAmount(line).trim();

          if (name.length >= 2) {
            items.add(
              ParsedReceiptItem(
                name: name,
                price: amount,
                confidenceScore: 70,
              ),
            );
          }
        }
      }
    }

    return ParsedReceipt(
      storeName: storeName,
      purchaseDate: purchaseDate,
      subtotal: subtotal,
      tax: tax,
      total: total,
      items: items,
      ignoredSensitiveLines: ignoredSensitiveLines,
    );
  }

  static bool _isSensitiveLine(String line) {
    return line.contains('CARD') ||
        line.contains('VISA') ||
        line.contains('MASTERCARD') ||
        line.contains('DEBIT') ||
        line.contains('CREDIT') ||
        line.contains('AUTH') ||
        line.contains('APPROVAL') ||
        line.contains('TRANSACTION') ||
        line.contains('TERMINAL') ||
        line.contains('LOYALTY') ||
        line.contains('MEMBER');
  }

  static bool _isNonProductLine(String line) {
    return line.contains('TOTAL') ||
        line.contains('SUBTOTAL') ||
        line.contains('SUB TOTAL') ||
        line.contains('HST') ||
        line.contains('GST') ||
        line.contains('TAX') ||
        line.contains('CHANGE') ||
        line.contains('BALANCE') ||
        line.contains('CASH') ||
        line.contains('PAYMENT');
  }

  static String _detectStoreName(String line) {
    final upper = line.toUpperCase();

    if (upper.contains('WALMART')) return 'Walmart';
    if (upper.contains('COSTCO')) return 'Costco';
    if (upper.contains('NO FRILLS')) return 'No Frills';
    if (upper.contains('FRESHCO')) return 'FreshCo';
    if (upper.contains('FOOD BASICS')) return 'Food Basics';
    if (upper.contains('REAL CANADIAN SUPERSTORE')) {
      return 'Real Canadian Superstore';
    }

    return '';
  }

  static DateTime? _detectDate(String line) {
    final dateRegex = RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})');
    final match = dateRegex.firstMatch(line);

    if (match == null) return null;

    final year = int.tryParse(match.group(1) ?? '');
    final month = int.tryParse(match.group(2) ?? '');
    final day = int.tryParse(match.group(3) ?? '');

    if (year == null || month == null || day == null) return null;

    return DateTime(year, month, day);
  }

  static double? _extractAmount(String line) {
    final amountRegex = RegExp(r'(\d+\.\d{2})');
    final matches = amountRegex.allMatches(line).toList();

    if (matches.isEmpty) return null;

    return double.tryParse(matches.last.group(1) ?? '');
  }

  static String _removeAmount(String line) {
    return line.replaceAll(RegExp(r'\d+\.\d{2}'), '').trim();
  }
}