# Magna Data Store

Flutter commerce application with a FastAPI backend and WooCommerce integration.

## Architecture

- `lib/`: Flutter client, organized by shared core services, data models, and features.
- `backend/app/`: FastAPI API, JWT authentication, PostgreSQL persistence, Razorpay integration, and WooCommerce client.
- `lib/wp-content/mu-plugins/`: WordPress order-history REST extension.

The Flutter client uses WooCommerce for catalog browsing and the FastAPI backend for authentication, addresses, notifications, checkout, payment verification, and invoice delivery.

## Prerequisites

- Flutter/Dart compatible with the SDK constraint in `pubspec.yaml`
- Android Studio/JDK 17 for Android builds
- Python 3.11+ and PostgreSQL for the backend
- WooCommerce REST API credentials
- Razorpay credentials for checkout
- SMTP credentials for invoice email
- Firebase configuration for push notifications

## Run the backend

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
```

Configure `backend/.env`, especially `DATABASE_URL`, `JWT_SECRET_KEY`, WooCommerce credentials, and Razorpay credentials. Then run migrations and the API:

```powershell
alembic upgrade head
uvicorn app.main:app --reload
```

Health check: `http://127.0.0.1:8000/health`

## Run the Flutter client

```powershell
flutter pub get
flutter run
```

The default endpoints target the configured production services. Override them for local or staging development:

```powershell
flutter run `
  --dart-define=STORE_BASE_URL=https://serverboat.com `
  --dart-define=BACKEND_BASE_URL=http://10.0.2.2:8000/api/v1
```

Use `http://127.0.0.1:8000/api/v1` for a desktop/web client running on the same machine. Android emulators should use `10.0.2.2`.

## Validate changes

```powershell
flutter analyze
flutter test
python -m compileall -q backend\app
```

## Security and deployment notes

- Keep WooCommerce, JWT, Razorpay, database, and SMTP secrets in environment variables or a deployment secret manager.
- Never put WooCommerce consumer credentials in the Flutter application.
- Use a production Android signing key before releasing an APK.
- Configure Razorpay webhooks to call `/api/v1/payments/webhook`.
- Do not enable verbose request/response logging in production.
