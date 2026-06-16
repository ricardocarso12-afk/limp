import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/app_colors.dart';
import '../core/i18n.dart';
import '../widgets/tb_app_bar.dart';

class ScannerScreen extends StatefulWidget {
  final I18n i18n;
  const ScannerScreen({super.key, required this.i18n});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final controller = MobileScannerController();
  bool returned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.i18n.t;
    return Scaffold(
      appBar: TbAppBar(title: t('scan_qr')),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (returned) return;
              if (capture.barcodes.isEmpty) return;
              final code = capture.barcodes.first.rawValue;
              if (code == null || code.trim().isEmpty) return;
              returned = true;
              Navigator.pop(context, code.trim());
            },
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.cream, width: 4),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 30,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.black.withOpacity(.62), borderRadius: BorderRadius.circular(16)),
              child: Text(t('camera_permission'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
