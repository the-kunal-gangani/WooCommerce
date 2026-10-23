# Magna Data Store API

## Local setup

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
```

Required settings are documented in `.env.example`. At minimum, configure:

- `DATABASE_URL`
- `JWT_SECRET_KEY`
- `WOOCOMMERCE_CONSUMER_KEY`
- `WOOCOMMERCE_CONSUMER_SECRET`

Configure Razorpay and SMTP settings before enabling payments and invoice delivery.

## Database and server

```powershell
alembic upgrade head
uvicorn app.main:app --reload
```

The API is available under `/api/v1`; `/health` provides a basic liveness check and `/docs` exposes the development OpenAPI UI.

## Validation

```powershell
python -m compileall -q app
```
