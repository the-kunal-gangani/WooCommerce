
from sqlalchemy import text

from app.db.session import engine


def main() -> None:
    try:
        with engine.connect() as connection:
            result = connection.execute(
                text("SELECT version()")
            ).scalar_one()

            print("Database connection successful.")
            print(result)

    finally:
        engine.dispose()


if __name__ == "__main__":
    main()
