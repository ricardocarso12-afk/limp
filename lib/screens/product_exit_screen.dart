import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/i18n.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/location_service.dart';
import '../services/offline_queue_service.dart';
import '../services/session_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/premium_card.dart';
import '../widgets/tb_app_bar.dart';
import '../widgets/tb_button.dart';
import 'scanner_screen.dart';

class ProductExitScreen extends StatefulWidget {
  final I18n i18n;
  final SessionService session;
  final VoidCallback? onChanged;
  const ProductExitScreen({super.key, required this.i18n, required this.session, this.onChanged});

  @override
  State<ProductExitScreen> createState() => _ProductExitScreenState();
}

class _ProductExitScreenState extends State<ProductExitScreen> {
  late final api = ApiClient(widget.session);
  final location = LocationService();
  final queue = OfflineQueueService();
  final codeController = TextEditingController();
  final notesController = TextEditingController();
  Product? product;
  List<User> pickupUsers = [];
  User? selectedUser;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await api.pickupUsers();
      setState(() {
        pickupUsers = users;
        selectedUser = users.isEmpty ? null : users.first;
      });
    } catch (e) {
      if (mounted) showAppSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _scan() async {
    final code = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => ScannerScreen(i18n: widget.i18n)));
    if (code != null) {
      codeController.text = code;
      await _search();
    }
  }

  Future<void> _search() async {
    if (codeController.text.trim().isEmpty) return;
    setState(() => loading = true);
    try {
      final item = await api.scanProduct(codeController.text.trim());
      setState(() => product = item);
    } catch (e) {
      if (mounted) showAppSnack(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _confirm() async {
    if (product == null || selectedUser == null) return;
    setState(() => loading = true);
    try {
      final pos = await location.currentPosition();
      try {
        await api.productExit(
          trackingCode: product!.trackingCode,
          pickedByUserId: selectedUser!.id,
          latitude: pos.latitude,
          longitude: pos.longitude,
          notes: notesController.text,
        );
        if (mounted) showAppSnack(context, widget.i18n.t('exit_saved'));
      } catch (_) {
        await queue.addProductExit(
          trackingCode: product!.trackingCode,
          pickedByUserId: selectedUser!.id,
          latitude: pos.latitude,
          longitude: pos.longitude,
          notes: notesController.text,
        );
        if (mounted) showAppSnack(context, widget.i18n.t('offline_saved'));
      }
      widget.onChanged?.call();
      setState(() {
        product = null;
        codeController.clear();
        notesController.clear();
      });
    } catch (e) {
      if (mounted) showAppSnack(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.i18n.t;
    return Scaffold(
      appBar: TbAppBar(title: t('exit')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          PremiumCard(
            child: Column(
              children: [
                TbButton(text: t('scan_qr'), icon: Icons.qr_code_scanner, onPressed: _scan),
                const SizedBox(height: 14),
                TextField(controller: codeController, decoration: InputDecoration(labelText: t('tracking_code'), prefixIcon: const Icon(Icons.tag))),
                const SizedBox(height: 12),
                TbButton(text: t('search_product'), icon: Icons.search, secondary: true, loading: loading, onPressed: _search),
              ],
            ),
          ),
          if (product != null) ...[
            const SizedBox(height: 16),
            PremiumCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t('product_detected'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.forest)),
                const SizedBox(height: 10),
                _Line(label: t('tracking_code'), value: product!.trackingCode),
                _Line(label: t('name'), value: product!.name),
                _Line(label: t('type'), value: product!.typeName),
                _Line(label: t('status'), value: product!.status),
                const Divider(height: 26),
                DropdownButtonFormField<User>(
                  value: selectedUser,
                  items: pickupUsers.map((u) => DropdownMenuItem(value: u, child: Text(u.name))).toList(),
                  onChanged: (u) => setState(() => selectedUser = u),
                  decoration: InputDecoration(labelText: t('picked_by'), prefixIcon: const Icon(Icons.person_pin_circle_outlined)),
                ),
                const SizedBox(height: 12),
                TextField(controller: notesController, maxLines: 3, decoration: InputDecoration(labelText: t('notes'), prefixIcon: const Icon(Icons.notes_outlined))),
                const SizedBox(height: 16),
                TbButton(text: t('confirm_exit'), icon: Icons.check_circle, loading: loading, onPressed: _confirm),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  const _Line({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AppColors.leaf, fontWeight: FontWeight.w700))),
        Expanded(child: Text(value, style: const TextStyle(color: AppColors.deepText))),
      ]),
    );
  }
}
