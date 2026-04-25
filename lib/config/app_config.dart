// Create a config file: lib/config/app_config.dart
class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.0.5:8000/api', // your current IP
  );
}
