import 'package:flutter/material.dart';

import 'core/app_colors.dart';
import 'core/i18n.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/session_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TbMobileApp());
}

class TbMobileApp extends StatefulWidget {
  const TbMobileApp({super.key});

  @override
  State<TbMobileApp> createState() => _TbMobileAppState();
}

class _TbMobileAppState extends State<TbMobileApp> {
  final i18n = I18n();
  final session = SessionService();
  bool loading = true;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final lang = await session.getLanguage();
    i18n.setLanguage(lang);
    final token = await session.getToken();
    setState(() {
      loggedIn = token != null && token.isNotEmpty;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: i18n,
      builder: (context, _) {
        return MaterialApp(
          title: 'T&B Custom Clean',
          debugShowCheckedModeBanner: false,
          locale: i18n.locale,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.forest, brightness: Brightness.light),
            scaffoldBackgroundColor: AppColors.cream,
            fontFamily: 'Roboto',
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.sage)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.sage)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.forest, width: 2)),
            ),
          ),
          home: loading
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : loggedIn
                  ? HomeScreen(i18n: i18n, session: session, onLogout: _logout)
                  : LoginScreen(i18n: i18n, session: session, onLoggedIn: () => setState(() => loggedIn = true)),
        );
      },
    );
  }

  Future<void> _logout() async {
    await session.logout();
    setState(() => loggedIn = false);
  }
}
