class AppConfig {
  AppConfig._();
  static const String appName = 'Magna Data Store';
  static const String baseUrl = String.fromEnvironment(
    'STORE_BASE_URL',
    defaultValue: 'https://serverboat.com',
  );
  static const String storeApiPath = '/wp-json/wc/store/v1';
  static const String magnaApiPath = '/wp-json/magna/v1';
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
