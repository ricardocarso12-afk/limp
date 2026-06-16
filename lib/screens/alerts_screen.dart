import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/i18n.dart';
import '../models/product.dart';
import '../services/api_client.dart';
import '../services/session_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/premium_card.dart';
import '../widgets/tb_app_bar.dart';

class AlertsScreen extends StatefulWidget {
  final I18n i18n;
  final SessionService session;
  const AlertsScreen({super.key, required this.i18n, required this.session});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late final api = ApiClient(widget.session);
  List<Product> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final alerts = await api.storageAlerts();
      setState(() => items = alerts);
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
      appBar: TbAppBar(title: t('alerts'), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: items.isEmpty
                  ? ListView(padding: const EdgeInsets.all(24), children: [Center(child: Text(t('no_data')))])
                  : ListView.builder(
                      padding: const EdgeInsets.all(18),
                      itemCount: items.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PremiumCard(
                          child: Row(children: [
                            const CircleAvatar(backgroundColor: AppColors.warning, foregroundColor: Colors.white, child: Icon(Icons.warning_amber_rounded)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(items[i].name, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepText)),
                              Text(items[i].trackingCode, style: const TextStyle(color: AppColors.leaf)),
                              Text('${t('storage_days')}: ${items[i].storageDays ?? '-'}'),
                            ])),
                          ]),
                        ),
                      ),
                    ),
            ),
    );
  }
}
