class AppConfig {
  AppConfig._();

  static const String appName = 'Magna Data Store';
  static const String baseUrl = 'https://serverboat.com';
  static const String storeApiPath = '/wp-json/wc/store/v1';
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
