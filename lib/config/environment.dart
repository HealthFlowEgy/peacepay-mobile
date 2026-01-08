/// Environment configuration for PeacePay
/// 
/// This file contains environment-specific settings that can be
/// changed based on the build flavor (development, staging, production).

class Environment {
  /// Current environment
  static const String current = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'production',
  );

  /// API Base URL
  static String get apiBaseUrl {
    switch (current) {
      case 'development':
        return 'http://localhost:8000/api/v1';
      case 'staging':
        return 'https://stg.peacepay.me/api/v1';
      case 'production':
      default:
        return 'http://142.93.108.213/api/v1';
    }
  }

  /// Whether to enable debug features
  static bool get isDebug => current == 'development';

  /// Whether to enable analytics
  static bool get enableAnalytics => current == 'production';

  /// Whether to enable crash reporting
  static bool get enableCrashReporting => current == 'production';

  /// App name based on environment
  static String get appName {
    switch (current) {
      case 'development':
        return 'PeacePay Dev';
      case 'staging':
        return 'PeacePay Staging';
      case 'production':
      default:
        return 'PeacePay';
    }
  }

  /// Cequens SMS Sender ID
  static const String smsSenderId = 'PeacePay';

  /// Support email
  static const String supportEmail = 'support@peacepay.me';

  /// Support phone
  static const String supportPhone = '+20 100 000 0000';

  /// Privacy policy URL
  static const String privacyPolicyUrl = 'https://peacepay.me/privacy';

  /// Terms of service URL
  static const String termsOfServiceUrl = 'https://peacepay.me/terms';
}
