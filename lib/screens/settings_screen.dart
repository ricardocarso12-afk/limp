import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/i18n.dart';
import '../services/session_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/premium_card.dart';
import '../widgets/tb_app_bar.dart';
import '../widgets/tb_button.dart';

class SettingsScreen extends StatefulWidget {
  final I18n i18n;
  final SessionService session;
  const SettingsScreen({super.key, required this.i18n, required this.session});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final apiUrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.session.getApiUrl().then((value) => setState(() => apiUrl.text = value));
  }

  Future<void> _save() async {
    await widget.session.saveApiUrl(apiUrl.text);
    if (mounted) showAppSnack(context, widget.i18n.t('save'));
  }

  Future<void> _setLang(String code) async {
    widget.i18n.setLanguage(code);
    await widget.session.saveLanguage(code);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.i18n.t;
    return Scaffold(
      appBar: TbAppBar(title: t('settings')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          PremiumCard(
            child: Column(children: [
              TextField(controller: apiUrl, decoration: InputDecoration(labelText: t('api_url'), prefixIcon: const Icon(Icons.link))),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => _setLang('es'), style: _style(widget.i18n.code == 'es'), child: Text(t('spanish')))),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton(onPressed: () => _setLang('en'), style: _style(widget.i18n.code == 'en'), child: Text(t('english')))),
              ]),
              const SizedBox(height: 14),
              TbButton(text: t('save'), icon: Icons.save_outlined, onPressed: _save),
            ]),
          ),
        ],
      ),
    );
  }

  ButtonStyle _style(bool selected) {
    return OutlinedButton.styleFrom(
      backgroundColor: selected ? AppColors.forest : Colors.white,
      foregroundColor: selected ? Colors.white : AppColors.forest,
      side: const BorderSide(color: AppColors.forest),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
