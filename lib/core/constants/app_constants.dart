/// Application-wide constants
class AppConstants {
  AppConstants._();
  //baseUrl
  static const String baseUrl = 'https://adrinolinq.arkframework.com';
  // API
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
  static const int maxRetries = 3;

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyProfileSaved =
      'profile_saved'; // Onboarding completion flag
  static const String keyIsLoggedIn = 'is_logged_in'; // Login status flag
  static const String keyRegistrationOnboardingPending =
      'registration_onboarding_pending'; // Registration flow onboarding flag

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}
