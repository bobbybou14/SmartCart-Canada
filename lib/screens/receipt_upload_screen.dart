import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_colors.dart';
import '../models/receipt.dart';
import '../service/receipt_service.dart';
import 'receipt_history_screen.dart';

class ReceiptUploadScreen extends StatefulWidget {
  const ReceiptUploadScreen({super.key});

  @override
  State<ReceiptUploadScreen> createState() => _ReceiptUploadScreenState();
}

class _ReceiptUploadScreenState extends State<ReceiptUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  XFile? _receiptImage;
  Uint8List? _imageBytes;
  bool _isSaving = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      _receiptImage = image;
      _imageBytes = bytes;
    });
  }

  Future<void> _uploadReceipt() async {
    if (_receiptImage == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await ReceiptService.saveReceipt(
        const Receipt(
          id: '',
          source: 'receipt',
          processingStatus: 'pending',
          personalDataRedacted: true,
          rawImageStored: false,
          notes: 'Receipt image selected. OCR processing not yet implemented.',
        ),
      );

      if (!mounted) return;

      setState(() {
        _receiptImage = null;
        _imageBytes = null;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt record saved to Supabase.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Receipt save failed: $error'),
        ),
      );
    }
  }

  void _openReceiptHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReceiptHistoryScreen(),
      ),
    );
  }

  Widget _preview() {
    if (_imageBytes == null) {
      return Container(
        height: 260,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: const Center(
          child: Icon(
            Icons.receipt_long,
            size: 120,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.memory(
        _imageBytes!,
        height: 260,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _privacyNotice() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Privacy Notice\n\n'
          'SmartCart only stores grocery-related information.\n\n'
          'At this stage, the receipt image is not uploaded or stored. '
          'Only a receipt processing record is saved.\n\n'
          'Credit card numbers, loyalty numbers, authorization codes, and other '
          'personal payment information will never be intentionally stored.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _receiptImage != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Receipt'),
        actions: [
          IconButton(
            onPressed: _openReceiptHistory,
            icon: const Icon(Icons.history),
            tooltip: 'Receipt History',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Receipt Upload',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Take a picture of your grocery receipt or choose one from your device.',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 25),
          _preview(),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.photo_camera),
            label: const Text('Take Photo'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose From Device'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _openReceiptHistory,
            icon: const Icon(Icons.history),
            label: const Text('View Receipt History'),
          ),
          const SizedBox(height: 30),
          FilledButton.icon(
            onPressed: !hasImage || _isSaving ? null : _uploadReceipt,
            icon: const Icon(Icons.cloud_upload),
            label: Text(_isSaving ? 'Saving...' : 'Upload Receipt'),
          ),
          const SizedBox(height: 40),
          _privacyNotice(),
        ],
      ),
    );
  }
}