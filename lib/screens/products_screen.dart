import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/i18n.dart';
import '../models/product.dart';
import '../services/api_client.dart';
import '../services/session_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/premium_card.dart';
import '../widgets/tb_app_bar.dart';

class ProductsScreen extends StatefulWidget {
  final I18n i18n;
  final SessionService session;
  const ProductsScreen({super.key, required this.i18n, required this.session});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
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
      final products = await api.products();
      setState(() => items = products);
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
      appBar: TbAppBar(title: t('products'), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
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
                        child: _ProductCard(product: items[i], t: t),
                      ),
                    ),
            ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final String Function(String) t;
  const _ProductCard({required this.product, required this.t});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.cleaning_services, color: AppColors.forest),
          const SizedBox(width: 10),
          Expanded(child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.deepText))),
        ]),
        const SizedBox(height: 8),
        Text(product.trackingCode, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.leaf)),
        const SizedBox(height: 6),
        Text('${t('type')}: ${product.typeName}'),
        Text('${t('status')}: ${product.status}'),
        if (product.storageDays != null) Text('${t('storage_days')}: ${product.storageDays}'),
      ]),
    );
  }
}
