import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:provider/provider.dart';
import '../core/config/app_config.dart';
import '../core/routing/app_router.dart';
import '../core/api/api_client.dart';
import '../core/theme/app_theme_new.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();
    return ProviderScope(
      child: MultiProvider(
        providers: [
          Provider<AppConfig>(create: (_) => AppConfig.load()),
          Provider<ApiClient>(
              create: (context) => ApiClient(context.read<AppConfig>()),),
        ],
        child: MaterialApp(
          title: 'Adrinolinq Owner',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          initialRoute: AppRouter.splash,
          onGenerateRoute: router.onGenerateRoute,
        ),
      ),
    );
  }
}
