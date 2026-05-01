import 'dart:developer' as developer;

class AppConfig {
  AppConfig._();

  // Para Android Emulator: 'http://10.0.2.2:3000/'
  // Para Dispositivo Real: Configure a URL do seu servidor, ex: 'http://192.168.1.10:3000/'
  // Para teste local: 'http://localhost:3000/' (apenas web)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/',
  );

  static void logConfiguration() {
    developer.log('[AppConfig] API Base URL: $apiBaseUrl');
  }
}
