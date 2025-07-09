import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  static const double faddingPercentage = 0.1;
  static const double lineSpacingThreshold = 15.0;
  static const double charSpacingRatio = 8.0;
  static const double lineHeightTolerance = 5.0;

  Future<File> _addPadding(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw 'Invalid image file';

    final paddingX = (image.width * 0.1).round();
    final paddingY = (image.height * 0.1).round();

    final paddedImage = img.copyResize(
      image,
      width: image.width + (paddingX * 2),
      height: image.height + (paddingY * 2),
      backgroundColor: img.ColorRgb8(255, 255, 255),
    );

    img.compositeImage(
      paddedImage,
      image,
      dstX: paddingX,
      dstY: paddingY,
    );

    final tempDir = Directory.systemTemp;
    final paddedFile = File('${tempDir.path}/padded_receipt.jpg');
    await paddedFile.writeAsBytes(img.encodeJpg(paddedImage));

    return paddedFile;
  }

  Future<String> scanReceipt(File imageFile) async {
    try {
      final paddedFile = await _addPadding(imageFile);
      final InputImage inputImage = InputImage.fromFile(paddedFile);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      StringBuilder result = StringBuilder();
      String? totalLine;
      DateTime? scannedDate;
      bool afterTotal = false;
      bool dateFound = false;

      final datePattern = RegExp(r'DATA\s+(\d{2}[./-]\d{2}[./-](?:20)?\d{2})',
          caseSensitive: false);
      final shortDatePattern =
          RegExp(r'(?<!\d)(\d{2}[./-]\d{2}[./-]\d{2})(?!\d)');
      final beforeTotalPattern = RegExp(
          r'(\d+[.,]\d{2})\s*(?:EUR|€)?\s*(?:TOTAL|TOT\.|IMPORTO)',
          caseSensitive: false);
      final afterTotalPattern = RegExp(
          r'(?:TOTAL|TOT\.|IMPORTO)\s*(?:EUR|€)?\s*(\d+[.,]\d{2})',
          caseSensitive: false);

      Map<double, List<TextElement>> lineElements = {};

      try {
        for (TextBlock block in recognizedText.blocks) {
          for (TextLine line in block.lines) {
            String processedText = _cleanText(line.text);
            if (processedText.isEmpty) continue;

            if (!dateFound) {
              final dateMatch = datePattern.firstMatch(processedText) ??
                  shortDatePattern.firstMatch(processedText);
              if (dateMatch != null) {
                try {
                  final normalizedDate = _normalizeDate(dateMatch.group(1)!);
                  final parts = normalizedDate.split(RegExp(r'[./-]'));
                  if (parts.length == 3) {
                    scannedDate = DateTime(int.parse(parts[2]),
                        int.parse(parts[1]), int.parse(parts[0]));
                    dateFound = true;
                    result.writeln('Data: ${_formatDate(scannedDate)}');
                  }
                } catch (e) {
                  dateFound = false;
                }
              }
            }

            if (!afterTotal && _containsTotalKeyword(processedText)) {
              final match = beforeTotalPattern.firstMatch(processedText) ??
                  afterTotalPattern.firstMatch(processedText);
              if (match != null) {
                totalLine = _formatTotalLine(processedText, match.group(1)!);
                afterTotal = true;
                continue;
              }
            }

            if (afterTotal) continue;

            _addLineElement(lineElements, line);
          }
        }

        _formatResult(result, lineElements, totalLine);
      } finally {
        await paddedFile.delete().catchError((error) => paddedFile);
      }

      return result.toString();
    } catch (e) {
      throw 'Error scanning receipt: $e';
    }
  }

  String _normalizeDate(String date) {
    final parts = date.split('.');
    return parts.length == 3 && parts[2].length == 2
        ? '${parts[0]}.${parts[1]}.20${parts[2]}'
        : date;
  }

  bool _containsTotalKeyword(String text) {
    final lowerText = text.toLowerCase();
    return lowerText.contains('total') ||
        lowerText.contains('tot.') ||
        lowerText.contains('importo');
  }

  String _formatTotalLine(String text, String total) =>
      _cleanText(text.replaceAll(total, '*** $total ***'));

  void _addLineElement(
      Map<double, List<TextElement>> lineElements, TextLine line) {
    final yPosition = line.boundingBox.top;
    final key = (yPosition / lineHeightTolerance).round() * lineHeightTolerance;
    if (line.elements.isNotEmpty) {
      lineElements.putIfAbsent(key, () => []).addAll(
          line.elements.where((element) => element.text.trim().isNotEmpty));
    }
  }

  void _formatResult(StringBuilder result,
      Map<double, List<TextElement>> lineElements, String? totalLine) {
    final sortedKeys = lineElements.keys.toList()..sort();
    for (var key in sortedKeys) {
      final elements = lineElements[key]!
        ..sort((a, b) => (a.boundingBox.left).compareTo(b.boundingBox.left));

      final line = _formatLine(elements);
      if (line.isNotEmpty) {
        if (totalLine != null && line == _cleanText(totalLine)) {
          result.writeln('----------------------------------------');
        }
        result.writeln(line);
      }
    }
  }

  String _formatLine(List<TextElement> elements) {
    if (elements.isEmpty) return '';

    final StringBuffer line = StringBuffer();
    double lastRight = 0;

    for (var element in elements) {
      if (!element.boundingBox.left.isNaN) {
        final currentLeft = element.boundingBox.left;
        if (currentLeft - lastRight > lineSpacingThreshold) {
          final spaces = ((currentLeft - lastRight) / charSpacingRatio).round();
          line.write(' ' * spaces);
        }
        line.write(_cleanText(element.text));
        lastRight = element.boundingBox.right;
      }
    }

    return line.toString();
  }

  void dispose() {
    _textRecognizer.close();
  }

  String _cleanText(String text) => text
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .replaceAll(RegExp(r'[^\S\r\n]'), ' ');

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class StringBuilder {
  final StringBuffer _buffer = StringBuffer();

  void writeln(String line) {
    _buffer.writeln(line);
  }

  @override
  String toString() => _buffer.toString();
}
