class AppConfig {
  const AppConfig({
    required this.appTitle,
    required this.environment,
    required this.apiBaseUrl,
  });

  final String appTitle;
  final String environment;
  final String apiBaseUrl;

  static AppConfig load() {
    return const AppConfig(
      appTitle: 'Adrinolinq Owner',
      environment: 'production',
      apiBaseUrl: 'https://adrinolinq.arkframework.com',
    );
  }
}
