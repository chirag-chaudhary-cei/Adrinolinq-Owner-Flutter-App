import 'package:flutter/material.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/app_loading.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final secureStorage = SecureStorage.instance;
    final token = await secureStorage.read('auth_token');

    AppLogger.info('Splash: Checking auth token...');
    AppLogger.info('Token found: ${token != null && token.isNotEmpty}');

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      AppLogger.success('Token valid - navigating to home');
      Navigator.of(context).pushReplacementNamed(RouteNames.home);
    } else {
      AppLogger.info('No token - navigating to welcome');
      Navigator.of(context).pushReplacementNamed(RouteNames.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF030107),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/Logo.png',
                width: AppResponsive.s(context, 100),
                height: AppResponsive.s(context, 100),
                fit: BoxFit.contain,
              ),
              SizedBox(height: AppResponsive.s(context, 16)),
              Text(
                'ADRINOLINQ',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Reglo-Bold',
                  fontSize: AppResponsive.font(context, 48),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: AppResponsive.s(context, 32)),
              AppLoading.circular(
                size: AppResponsive.s(context, 40),
                strokeWidth: 2.5,
                color: const Color(0xFFC3FF00),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
