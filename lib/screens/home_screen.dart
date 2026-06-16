import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/i18n.dart';
import '../services/api_client.dart';
import '../services/offline_queue_service.dart';
import '../services/session_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/premium_card.dart';
import '../widgets/tb_app_bar.dart';
import 'alerts_screen.dart';
import 'product_entry_screen.dart';
import 'product_exit_screen.dart';
import 'products_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final I18n i18n;
  final SessionService session;
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.i18n, required this.session, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ApiClient api = ApiClient(widget.session);
  final queue = OfflineQueueService();
  int pending = 0;
  String userName = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final me = await api.me();
      final count = await queue.count();
      setState(() {
        userName = me.name;
        role = me.role;
        pending = count;
      });
    } catch (_) {
      final count = await queue.count();
      setState(() => pending = count);
    }
  }

  Future<void> _sync() async {
    try {
      final operations = await queue.pending();
      if (operations.isEmpty) {
        if (mounted) showAppSnack(context, widget.i18n.t('no_data'));
        return;
      }
      final payload = operations.map((o) => {
        'type': o['type'],
        'local_uuid': o['local_uuid'],
        'payload': o['payload'],
      }).toList();
      await api.syncOperations(payload);
      await queue.deleteIds(operations.map<int>((o) => o['id'] as int).toList());
      await _load();
      if (mounted) showAppSnack(context, widget.i18n.t('synced'));
    } catch (e) {
      if (mounted) showAppSnack(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.i18n.t;
    return Scaffold(
      appBar: TbAppBar(
        title: t('app_name'),
        actions: [
          IconButton(onPressed: () => _open(SettingsScreen(i18n: widget.i18n, session: widget.session)), icon: const Icon(Icons.settings_outlined)),
          IconButton(onPressed: widget.onLogout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            PremiumCard(
              child: Row(
                children: [
                  const CircleAvatar(backgroundColor: AppColors.forest, foregroundColor: Colors.white, child: Icon(Icons.person)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${t('welcome')}, ${userName.isEmpty ? 'T&B' : userName}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.deepText)),
                      Text('${t('role')}: $role', style: const TextStyle(color: AppColors.leaf)),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _HomeTile(icon: Icons.add_box_outlined, title: t('entry'), subtitle: '5 fotos + tipo + ubicación', onTap: () => _open(ProductEntryScreen(i18n: widget.i18n, session: widget.session))),
            _HomeTile(icon: Icons.qr_code_scanner, title: t('exit'), subtitle: 'QR + quién recogió + GPS', onTap: () => _open(ProductExitScreen(i18n: widget.i18n, session: widget.session, onChanged: _load))),
            _HomeTile(icon: Icons.inventory_2_outlined, title: t('products'), subtitle: 'Consulta rápida', onTap: () => _open(ProductsScreen(i18n: widget.i18n, session: widget.session))),
            _HomeTile(icon: Icons.notifications_active_outlined, title: t('alerts'), subtitle: 'Productos excedidos en almacén', onTap: () => _open(AlertsScreen(i18n: widget.i18n, session: widget.session))),
            _HomeTile(icon: Icons.sync, title: t('sync'), subtitle: '${t('pending_sync')}: $pending', onTap: _sync),
          ],
        ),
      ),
    );
  }

  Future<void> _open(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    await _load();
  }
}

class _HomeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.deepText)),
              Text(subtitle, style: const TextStyle(color: AppColors.leaf)),
            ])),
            const Icon(Icons.chevron_right, color: AppColors.leaf),
          ],
        ),
      ),
    );
  }
}
