# Magna Data Store

Flutter commerce application integrated with WordPress and WooCommerce.

## Architecture

- `lib/`: Flutter client, organized by shared core services, data models, and features.
- `lib/wp-content/mu-plugins/`: WordPress REST API extension for app authentication, addresses, orders, checkout, payments, and devices.

The Flutter client uses the public WooCommerce Store API for catalog browsing and the custom WordPress API for authenticated customer operations. Privileged WooCommerce and Razorpay credentials remain on WordPress.

## Prerequisites

- Flutter/Dart compatible with the SDK constraint in `pubspec.yaml`
- Android Studio/JDK 17 for Android builds
- WordPress administrator access
- WooCommerce, Razorpay, and PhonePe configuration on WordPress
- An SMTP/mail delivery configuration on WordPress
- Firebase configuration for push notifications

## Run the Flutter client

```powershell
flutter pub get
flutter run
```

The default endpoints target the configured production services. Override them for local or staging development:

```powershell
flutter run `
  --dart-define=STORE_BASE_URL=https://serverboat.com
```

The same `STORE_BASE_URL` value is used by desktop, web, and mobile clients.

## WordPress setup

Copy `lib/wp-content/mu-plugins/magna-store-api.php` to the WordPress `wp-content/mu-plugins/` directory. Ensure WooCommerce is active.

Define these constants in `wp-config.php` before enabling Razorpay checkout:

```php
define('MAGNA_RAZORPAY_KEY_ID', 'rzp_...');
define('MAGNA_RAZORPAY_KEY_SECRET', '...');
```

The payment implementation calls Razorpay server-side through WordPress. Never put these constants in Flutter.

Cash-on-delivery checkout is also handled by the WordPress API. Product
availability, stock, address fields, shipping fees, coupons, and payment
amounts are validated and calculated server-side; the client must not be
treated as the source of truth for order totals.

PhonePe is an additional payment method, not a replacement for Razorpay. Configure
the following server-side constants when enabling PhonePe:

```php
define('MAGNA_PHONEPE_CLIENT_ID', '...');
define('MAGNA_PHONEPE_CLIENT_SECRET', '...');
define('MAGNA_PHONEPE_CLIENT_VERSION', '...');
define('MAGNA_PHONEPE_MERCHANT_ID', '...');
define('MAGNA_PHONEPE_ENVIRONMENT', 'PRODUCTION');
define('MAGNA_PHONEPE_WEBHOOK_SECRET', '...');
```

The Flutter PhonePe flow uses a server-created PhonePe SDK order token. Configure
the non-secret app values at build time:

```powershell
flutter run `
  --dart-define=PHONEPE_ENVIRONMENT=SANDBOX `
  --dart-define=PHONEPE_MERCHANT_ID=your_phonepe_merchant_id `
  --dart-define=PHONEPE_APP_SCHEMA=magnaDataStore
```

PhonePe credentials and webhook secrets must never be included in the app.
The SDK fork is checked in under `third_party/phonepe_payment_sdk` because
published SDK 3.0.2 references the removed `proguard-android.txt` file.

## Validate changes

```powershell
flutter analyze
flutter test
```

## Security and deployment notes

- Keep WooCommerce, JWT, Razorpay, PhonePe, database, and SMTP secrets in environment variables or a deployment secret manager.
- Never put WooCommerce consumer credentials in the Flutter application.
- Use a production Android signing key before releasing an APK.
- Configure PhonePe webhooks to call `/wp-json/magna/v1/payments/phonepe/webhook` over HTTPS.
- Do not enable verbose request/response logging in production.
