import 'package:flutter/material.dart';
import 'package:snapbasket/services/scanner_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../models/receipt.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final OcrService _scannerService = OcrService();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isProcessing = false;
  DateTime? _lastScannedDate;
  double? _lastScannedTotal;
  bool _lastScanSuccessful = false;

  Future<DateTime?> _showDatePicker() async {
    return showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Date not found'),
          content: const Text(
            'The scanner could not find the receipt date. '
            'Please enter the date manually.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                Navigator.of(context).pop(date);
              },
              child: const Text('Select Date'),
            ),
          ],
        );
      },
    );
  }

  Future<double?> _showTotalDialog() async {
    final totalController = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Total not found'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'The scanner could not find the receipt total. '
                'Please enter the total manually.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: totalController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Total',
                  prefixText: '€ ',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final total = double.tryParse(
                  totalController.text.replaceAll(',', '.'),
                );
                Navigator.of(context).pop(total);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _resetPage() {
    setState(() {
      _image = null;
      _isProcessing = false;
      _lastScanSuccessful = false;
      _lastScannedDate = null;
      _lastScannedTotal = null;
    });
  }

  Future<void> _processImage(File image) async {
    setState(() {
      _isProcessing = true;
      _image = image;
    });

    try {
      final text = await _scannerService.scanReceipt(image);
      final extractedData = _extractReceiptData(text);

      if (extractedData['date'] == null) {
        final selectedDate = await _showDatePicker();
        if (selectedDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You need to select a date for the receipt'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        extractedData['date'] = selectedDate;
      }

      if (extractedData['total'] == null) {
        final manualTotal = await _showTotalDialog();
        if (manualTotal == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You need to enter the receipt total'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        extractedData['total'] = manualTotal;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final receipt = Receipt(
          userId: user.uid,
          fullText: text,
          total: extractedData['total'],
          date: extractedData['date'],
        );

        await FirebaseFirestore.instance
            .collection('receipts')
            .add(receipt.toMap());

        setState(() {
          _lastScannedDate = extractedData['date'];
          _lastScannedTotal = extractedData['total'];
          _lastScanSuccessful = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Receipt saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _lastScanSuccessful = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing receipt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        await _processImage(File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Map<String, dynamic> _extractReceiptData(String text) {
    double? total;
    DateTime? date;
    List<Map<String, dynamic>> items = [];

    final lines =
        text.split('\n').where((line) => line.trim().isNotEmpty).toList();

    for (String line in lines) {
      if (RegExp(r'\d{12,}').hasMatch(line)) continue;

      final priceMatch = RegExp(
        r'(?<!\d)(\d{1,3}(?:[.,]\d{3})*[.,]\d{2})(?!\d)$',
      ).firstMatch(line.trim());

      if (priceMatch != null) {
        final priceStr = priceMatch
            .group(1)!
            .replaceAll('.', '')
            .replaceAll(',', '.');

        final price = double.tryParse(priceStr);
        if (price != null) {
          String description = line
              .substring(0, line.length - priceMatch.group(0)!.length)
              .trim()
              .replaceAll(RegExp(r'\s+'), ' ')
              .replaceAll(RegExp(r'[^\w\s€.,]'), '');

          if (description.isNotEmpty) {
            items.add({'description': description, 'price': price});
          }
        }
      }

      if (line.toLowerCase().contains('total') ||
          line.toLowerCase().contains('tot.') ||
          line.toLowerCase().contains('importo')) {
        final totalMatch = RegExp(
          r'(\d{1,3}(?:[.,]\d{3})*[.,]\d{2})',
        ).firstMatch(line);
        if (totalMatch != null) {
          final totalStr = totalMatch
              .group(1)!
              .replaceAll('.', '')
              .replaceAll(',', '.');
          total = double.tryParse(totalStr);
        }
      }

      final dateMatch = RegExp(
        r'(\d{2})[./-](\d{2})[./-](\d{4})',
      ).firstMatch(line);
      if (dateMatch != null) {
        try {
          date = DateTime(
            int.parse(dateMatch.group(3)!),
            int.parse(dateMatch.group(2)!),
            int.parse(dateMatch.group(1)!),
          );
        } catch (e) {
          print('Error parsing date: $e');
        }
      }
    }

    return {'total': total, 'date': date, 'items': items};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          0,
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.grey[300],
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[300],
        child: SingleChildScrollView(
          physics:
              const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isProcessing)
                  const Center(child: CircularProgressIndicator())
                else if (_lastScanSuccessful)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(
                      bottom: 20,
                    ),
                    width:
                        MediaQuery.of(context).size.width *
                        0.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Receipt Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _resetPage,
                              icon: const Icon(Icons.refresh),
                              color: Colors.black,
                              tooltip: 'Reset',
                            ),
                          ],
                        ),
                        const Divider(),
                        if (_lastScannedDate != null)
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: const Text('Date'),
                            subtitle: Text(
                              '${_lastScannedDate!.day}/${_lastScannedDate!.month}/${_lastScannedDate!.year}',
                            ),
                          ),
                        if (_lastScannedTotal != null)
                          ListTile(
                            leading: const Icon(Icons.euro),
                            title: const Text('Total'),
                            subtitle: Text(
                              '€ ${_lastScannedTotal!.toStringAsFixed(2)}',
                            ),
                          ),
                        ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          title: const Text('Stato'),
                          subtitle: const Text('Saved successfully'),
                        ),
                      ],
                    ),
                  ),
                Container(
                  height: 350,
                  width:
                      MediaQuery.of(context).size.width *
                      0.5,
                  alignment:
                      Alignment.center,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child:
                      _image != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _image!,
                              fit:
                                  BoxFit.contain,
                            ),
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.android_rounded,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Hey! I\'m ready to scan\nyour receipt!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Use camera or choose from gallery',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                ),
                const SizedBox(height: 5),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _getImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _getImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _resetPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        elevation: 4,
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }
}
