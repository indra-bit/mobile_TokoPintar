import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class ScannerScreen extends StatefulWidget {
  final bool returnBarcode;
  const ScannerScreen({super.key, this.returnBarcode = false});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController cameraController = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
    ],
  );
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode Produk'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              if (_isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final barcodeVal = barcodes.first.rawValue;
                if (barcodeVal != null) {
                  setState(() => _isProcessing = true);

                  if (widget.returnBarcode) {
                    Navigator.of(context).pop(barcodeVal);
                    return;
                  }

                  final cartProvider = context.read<CartProvider>();
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  final product = await cartProvider.scanBarcode(barcodeVal);

                  if (!mounted) return;

                  if (product != null) {
                    cartProvider.addItem(product);
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('${product.namaBarang} ditambahkan ke keranjang')),
                    );
                    navigator.pop(); // Optional: close scanner after successful scan
                  } else {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Produk tidak ditemukan')),
                    );
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _isProcessing = false);
                    });
                  }
                }
              }
            },
          ),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(),
            ),
          BarcodeScannerOverlay(overlayColour: Colors.black.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}

class BarcodeScannerOverlay extends StatelessWidget {
  const BarcodeScannerOverlay({super.key, required this.overlayColour});
  final Color overlayColour;

  @override
  Widget build(BuildContext context) {
    double scanAreaWidth = MediaQuery.of(context).size.width * 0.8;
    double scanAreaHeight = 150.0; // Kotak memanjang untuk barcode

    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(overlayColour, BlendMode.srcOut),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: scanAreaWidth,
                    height: scanAreaHeight,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: CustomPaint(
            foregroundPainter: BorderPainter(),
            child: SizedBox(
              width: scanAreaWidth + 25,
              height: scanAreaHeight + 25,
            ),
          ),
        ),
      ],
    );
  }
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const width = 4.0;
    const radius = 20.0;
    const tRadius = 3 * radius;
    final rect = Rect.fromLTWH(width, width, size.width - 2 * width, size.height - 2 * width);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(radius));
    const clippingRect0 = Rect.fromLTWH(0, 0, tRadius, tRadius);
    final clippingRect1 = Rect.fromLTWH(size.width - tRadius, 0, tRadius, tRadius);
    final clippingRect2 = Rect.fromLTWH(0, size.height - tRadius, tRadius, tRadius);
    final clippingRect3 = Rect.fromLTWH(size.width - tRadius, size.height - tRadius, tRadius, tRadius);

    final path = Path()
      ..addRect(clippingRect0)
      ..addRect(clippingRect1)
      ..addRect(clippingRect2)
      ..addRect(clippingRect3);

    canvas.clipPath(path);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
