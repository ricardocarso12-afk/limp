import 'dart:io';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/i18n.dart';
import '../services/api_client.dart';
import '../services/session_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/premium_card.dart';
import '../widgets/tb_button.dart';

class LoginScreen extends StatefulWidget {
  final I18n i18n;
  final SessionService session;
  final VoidCallback onLoggedIn;

  const LoginScreen({super.key, required this.i18n, required this.session, required this.onLoggedIn});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final apiController = TextEditingController(text: 'https://tudominio.com/public/api.php');
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    widget.session.getApiUrl().then((url) => setState(() => apiController.text = url));
  }

  Future<void> _login() async {
    setState(() => loading = true);
    try {
      await widget.session.saveApiUrl(apiController.text);
      final api = ApiClient(widget.session);
      await api.login(
        email: emailController.text.trim(),
        password: passwordController.text,
        deviceName: Platform.operatingSystem,
        platform: Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : Platform.operatingSystem,
        appVersion: '1.0.0',
      );
      widget.onLoggedIn();
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const SizedBox(height: 28),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset('assets/images/tb_logo.jpg', width: 156, height: 156, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 18),
            Text(t('app_name'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.forest)),
            const SizedBox(height: 4),
            Text(t('tagline'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: AppColors.leaf)),
            const SizedBox(height: 24),
            PremiumCard(
              child: Column(
                children: [
                  TextField(controller: apiController, decoration: InputDecoration(labelText: t('api_url'), prefixIcon: const Icon(Icons.link))),
                  const SizedBox(height: 12),
                  TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: t('email'), prefixIcon: const Icon(Icons.email_outlined))),
                  const SizedBox(height: 12),
                  TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: t('password'), prefixIcon: const Icon(Icons.lock_outline))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _LangButton(text: 'ES', selected: widget.i18n.code == 'es', onTap: () => _setLang('es'))),
                      const SizedBox(width: 8),
                      Expanded(child: _LangButton(text: 'EN', selected: widget.i18n.code == 'en', onTap: () => _setLang('en'))),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TbButton(text: t('enter'), icon: Icons.login, loading: loading, onPressed: _login),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setLang(String code) async {
    widget.i18n.setLanguage(code);
    await widget.session.saveLanguage(code);
  }
}

class _LangButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _LangButton({required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.forest : Colors.white,
        foregroundColor: selected ? Colors.white : AppColors.forest,
        side: const BorderSide(color: AppColors.forest),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(text),
    );
  }
}
