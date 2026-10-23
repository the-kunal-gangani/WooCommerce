class AppConfig {
  AppConfig._();
  static const String appName = 'Magna Data Store';
  static const String baseUrl = String.fromEnvironment(
    'STORE_BASE_URL',
    defaultValue: 'https://serverboat.com',
  );
  static const String storeApiPath = '/wp-json/wc/store/v1';
  static const String magnaApiPath = '/wp-json/magna/v1';
  static const String phonePeEnvironment = String.fromEnvironment(
    'PHONEPE_ENVIRONMENT',
    defaultValue: 'SANDBOX',
  );
  static const String phonePeMerchantId = String.fromEnvironment(
    'PHONEPE_MERCHANT_ID',
  );
  static const String phonePeAppSchema = String.fromEnvironment(
    'PHONEPE_APP_SCHEMA',
    defaultValue: 'magnaDataStore',
  );
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
