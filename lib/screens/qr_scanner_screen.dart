import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../keochat_features/keochat_room_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  int _selectedTab = 0; // 0: Scan QR code, 1: My QR code
  bool _hasScanned = false;
  final MobileScannerController _cameraController = MobileScannerController();
  Future<void> _pickAndScan() async {
    try {
      final img = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (img != null) {
        final res = await _cameraController.analyzeImage(img.path);
        if (res != null && res.barcodes.isNotEmpty) {
          final val = res.barcodes.first.rawValue;
          if (val != null && val.isNotEmpty) {
            _hasScanned = true;
            _showFriendFoundDialog(val);
            return;
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No QR Code found in image')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }


  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawVal = barcode.rawValue;
      if (rawVal != null && rawVal.isNotEmpty) {
        _hasScanned = true;
        _showFriendFoundDialog(rawVal);
        break;
      }
    }
  }

  void _showFriendFoundDialog(String scannedData) {
    String friendName = 'KeoChat Friend';
    if (scannedData.toLowerCase().contains('keochat') || scannedData.startsWith('@')) {
      friendName = scannedData.replaceAll('@', '').replaceAll('keochat://', '').trim();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
              ),
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFF10B981),
                child: Icon(Icons.person_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 12),
              Text(
                friendName,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'KeoChat User Verified',
                style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() => _hasScanned = false);
                      },
                      child: const Text('Scan Again', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KeoChatRoomScreen(
                              friendName: friendName,
                              initial: friendName.isNotEmpty ? friendName[0].toUpperCase() : 'K',
                              isOnline: true,
                            ),
                          ),
                        );
                      },
                      child: const Text('Start Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Column(
          children: [
            // Top action bar with Close & Torch button (like Pic 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF1B5E20), size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  if (_selectedTab == 0)
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                      ),
                      onPressed: () => _cameraController.toggleTorch(),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            const Spacer(),

            if (_selectedTab == 0) ...[
              // Live Camera Preview Frame with curved white corners (like Pic 2)
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: MobileScanner(
                    controller: _cameraController,
                    onDetect: _onDetect,
                    errorBuilder: (context, error) {
                      return Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Text(
                            'Camera Permission Required',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Align QR code within frame',
                style: TextStyle(color: Color(0xFF2E7D32), fontSize: 14.5, fontWeight: FontWeight.bold, letterSpacing: 0.3),
              ),
              const SizedBox(height: 24),

              // Neon Green "Scan from Gallery" Button (like Pic 2)
              GestureDetector(
                onTap: _pickAndScan,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C853).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.photo_library_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Scan from Gallery',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // "My QR code" View
              Center(
                child: Container(
                  width: 240,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFF1877F2),
                        child: Text('K', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 12),
                      Text('Your KeoChat ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 16),
                      Icon(Icons.qr_code_2_rounded, size: 140, color: Color(0xFF0F172A)),
                      SizedBox(height: 12),
                      Text('Share this to connect instantly', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Just scan a QR code for quick access to features such as adding friends.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF388E3C), fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
              ),
            ),
            const SizedBox(height: 24),

            // Bottom Tabs: Scan QR code | My QR code (like Pic 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Scan QR code',
                            style: TextStyle(
                              color: _selectedTab == 0 ? const Color(0xFF1B5E20) : const Color(0xFF81C784),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 2.5,
                            width: 60,
                            color: _selectedTab == 0 ? const Color(0xFF00C853) : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'My QR code',
                            style: TextStyle(
                              color: _selectedTab == 1 ? const Color(0xFF1B5E20) : const Color(0xFF81C784),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 2.5,
                            width: 60,
                            color: _selectedTab == 1 ? const Color(0xFF00C853) : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
