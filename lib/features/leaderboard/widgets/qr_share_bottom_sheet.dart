import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

/// QR Share Bottom Sheet
/// Generates QR code for user profile sharing
class QRShareBottomSheet extends StatefulWidget {
  final String userId;
  final String username;
  final int level;
  final String characterClass;

  const QRShareBottomSheet({
    super.key,
    required this.userId,
    required this.username,
    required this.level,
    required this.characterClass,
  });

  @override
  State<QRShareBottomSheet> createState() => _QRShareBottomSheetState();
}

class _QRShareBottomSheetState extends State<QRShareBottomSheet> {
  // Screenshot controller
  final ScreenshotController _screenshotController = ScreenshotController();
  
  // QR data - contains user info for sharing
  String get _qrData => 'rpg_profile:${widget.userId}|${widget.username}|${widget.level}|${widget.characterClass}';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ═══════════════════════════════════════════════════════════════════════
          // DRAG HANDLE AND HEADER
          // ═══════════════════════════════════════════════════════════════════════
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          
          // ═══════════════════════════════════════════════════════════════════════
          // QR CODE CONTENT
          // ═══════════════════════════════════════════════════════════════════════
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // User info header
                Text(
                  widget.username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Level ${widget.level} ${widget.characterClass}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                
                // QR Code container
                Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7B2CBF).withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // QR Image
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: QrImageView(
                            data: _qrData,
                            size: 180,
                            backgroundColor: Colors.white,
                            version: QrVersions.auto,
                            gapless: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // App branding
                        Text(
                          'Scan to view profile',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // ═══════════════════════════════════════════════════════════════════════
          // SHARE BUTTON
          // ═══════════════════════════════════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _shareQRCode,
                icon: const Icon(Icons.share),
                label: const Text('Share QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B2CBF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Capture and share QR code
  Future<void> _shareQRCode() async {
    try {
      // Capture the QR code widget
      final Uint8List? imageBytes = await _screenshotController.capture();
      
      if (imageBytes != null) {
        // Save to temporary file for sharing
        final tempDir = await getTemporaryDirectory();
        final tempFile = await File('${tempDir.path}/qr_code.png').create();
        await tempFile.writeAsBytes(imageBytes);
        
        // Share using share_plus
        await Share.shareXFiles(
          [XFile(tempFile.path)],
          text: 'Scan this QR code to view my profile in Real Life RPG!',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    }
  }
}

/// Helper function to get temp directory
Future<Directory> getTemporaryDirectory() async {
  return Directory.systemTemp;
}
