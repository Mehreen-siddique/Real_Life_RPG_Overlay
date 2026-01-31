import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:real_life_rpg/Services/QRCode/qr_code_service.dart';
import 'package:real_life_rpg/Screens/Leaderboard/UserProfileScreen.dart';
import 'package:real_life_rpg/utils/constants.dart';

/// 📱 QR Scanner Screen
/// Scans QR codes to view user profiles
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late MobileScannerController _scannerController;
  final QRScannerService _qrScannerService = QRScannerService.instance;
  
  bool _isScanning = true;
  bool _isProcessing = false;
  String? _scannedData;
  
  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }
  
  void _initializeScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }
  
  Future<void> _processQRCode(String rawData) async {
    setState(() {
      _isProcessing = true;
      _isScanning = false;
      _scannedData = rawData;
    });
    
    try {
      // Parse QR code
      final qrService = QRCodeService.instance;
      final qrData = qrService.parseQRCode(rawData);
      
      if (qrData == null) {
        _showErrorDialog('Invalid QR Code', 'This QR code is not a valid Real Life RPG profile.');
        return;
      }
      
      if (qrData.isExpired) {
        _showErrorDialog('Expired QR Code', 'This QR code has expired. Please generate a new one.');
        return;
      }
      
      // Get user profile
      final userProfile = await _qrScannerService.getUserProfileFromQR(qrData);
      
      if (userProfile == null) {
        _showErrorDialog('User Not Found', 'Unable to find user profile. The user may have been removed.');
        return;
      }
      
      // Navigate to user profile
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileScreen(userId: userProfile.userId),
          ),
        );
      }
    } catch (e) {
      print('🚨 [QR-SCANNER] Error processing QR code: $e');
      _showErrorDialog('Scan Error', 'Failed to process QR code. Please try again.');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanner();
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _resetScanner() {
    setState(() {
      _isScanning = true;
      _isProcessing = false;
      _scannedData = null;
    });
  }
  
  void _toggleTorch() {
    _scannerController.toggleTorch();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan QR Code',
          style: TextStyle(
            color: AppColors.whiteBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: AppColors.whiteBackground),
        actions: [
          IconButton(
            icon: Icon(
              _scannerController.torchEnabled ? Icons.flash_on : Icons.flash_off,
              color: AppColors.whiteBackground,
            ),
            onPressed: _toggleTorch,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              if (!_isProcessing && capture.barcodes.isNotEmpty) {
                final barcode = capture.barcodes.first;
                if (barcode.rawValue != null) {
                  _processQRCode(barcode.rawValue!);
                }
              }
            },
          ),
          _buildScannerOverlay(),
          
          // Processing Indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.whiteBackground,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        color: AppColors.whiteBackground,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Instructions
          if (_isScanning && !_isProcessing)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Text(
                      'Scan a Real Life RPG QR Code',
                      style: TextStyle(
                        color: AppColors.whiteBackground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Position the QR code within the frame',
                      style: TextStyle(
                        color: AppColors.whiteBackground,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildScannerOverlay() {
    return CustomPaint(
      size: Size.infinite,
      painter: ScannerOverlayPainter(),
    );
  }
  
  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}

/// 🎨 Scanner Overlay Painter
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = AppColors.primaryPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final cutoutSize = 250.0;
    final cutoutOffset = (size.width - cutoutSize) / 2;
    
    // Create cutout path
    final cutoutPath = Path()
      ..addRect(Rect.fromLTWH(
        cutoutOffset,
        (size.height - cutoutSize) / 2,
        cutoutSize,
        cutoutSize,
      ));
    
    // Draw overlay with cutout
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addPath(cutoutPath, Offset.zero);
    
    canvas.drawPath(overlayPath, paint);
    
    // Draw corner brackets
    final cornerLength = 30.0;
    final cornerWidth = 4.0;
    
    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutoutOffset, cutoutOffset + cornerLength)
        ..lineTo(cutoutOffset, cutoutOffset)
        ..lineTo(cutoutOffset + cornerLength, cutoutOffset),
      strokePaint,
    );
    
    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutoutOffset + cutoutSize - cornerLength, cutoutOffset)
        ..lineTo(cutoutOffset + cutoutSize, cutoutOffset)
        ..lineTo(cutoutOffset + cutoutSize, cutoutOffset + cornerLength),
      strokePaint,
    );
    
    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutoutOffset, (size.height - cutoutSize) / 2 + cutoutSize - cornerLength)
        ..lineTo(cutoutOffset, (size.height - cutoutSize) / 2 + cutoutSize)
        ..lineTo(cutoutOffset + cornerLength, (size.height - cutoutSize) / 2 + cutoutSize),
      strokePaint,
    );
    
    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutoutOffset + cutoutSize - cornerLength, (size.height - cutoutSize) / 2 + cutoutSize)
        ..lineTo(cutoutOffset + cutoutSize, (size.height - cutoutSize) / 2 + cutoutSize)
        ..lineTo(cutoutOffset + cutoutSize, (size.height - cutoutSize) / 2 + cutoutSize - cornerLength),
      strokePaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
