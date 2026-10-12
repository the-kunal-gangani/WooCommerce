
from sqlalchemy import text

from app.db.session import engine

try:
    with engine.connect() as connection:
        version = connection.execute(
            text("SELECT version()")
        ).scalar_one()

        print("PostgreSQL connection successful!")
        print(version)
finally:
    engine.dispose()
