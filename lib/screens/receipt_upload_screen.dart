import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_colors.dart';

class ReceiptUploadScreen extends StatefulWidget {
  const ReceiptUploadScreen({super.key});

  @override
  State<ReceiptUploadScreen> createState() => _ReceiptUploadScreenState();
}

class _ReceiptUploadScreenState extends State<ReceiptUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  File? _receiptImage;

  Future<void> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      _receiptImage = File(image.path);
    });
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      _receiptImage = File(image.path);
    });
  }

  void _uploadReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Receipt saved. OCR processing will be added in the next version.',
        ),
      ),
    );
  }

  Widget _preview() {
    if (_receiptImage == null) {
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
      child: Image.file(
        _receiptImage!,
        height: 260,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Receipt"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Receipt Upload",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Take a picture of your grocery receipt or choose one from your gallery.",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 25),

          _preview(),

          const SizedBox(height: 30),

          ElevatedButton.icon(
            onPressed: _pickFromCamera,
            icon: const Icon(Icons.photo_camera),
            label: const Text("Take Photo"),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: _pickFromGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text("Choose From Gallery"),
          ),

          const SizedBox(height: 30),

          FilledButton.icon(
            onPressed:
                _receiptImage == null ? null : _uploadReceipt,
            icon: const Icon(Icons.cloud_upload),
            label: const Text("Upload Receipt"),
          ),

          const SizedBox(height: 40),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Privacy Notice\n\n"
                "SmartCart only stores grocery-related information.\n\n"
                "Credit card numbers, loyalty numbers and other personal information "
                "will never be stored.",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}