import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

abstract interface class ScannerSource {
  Widget preview({required ValueChanged<String> onCode, required Widget error});
  Future<void> dispose();
}

class CameraScannerSource implements ScannerSource {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
  );
  @override
  Widget preview({
    required ValueChanged<String> onCode,
    required Widget error,
  }) => MobileScanner(
    controller: _controller,
    errorBuilder: (context, e) => Center(child: error),
    onDetect: (capture) {
      for (final barcode in capture.barcodes) {
        if (barcode.rawValue != null) {
          onCode(barcode.rawValue!);
          break;
        }
      }
    },
  );
  @override
  Future<void> dispose() => _controller.dispose();
}
