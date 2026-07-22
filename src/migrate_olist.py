import os
import sqlite3
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import URL, create_engine, text

load_dotenv()

SQLITE_PATH = Path(os.environ["SQLITE_PATH"])

POSTGRES_USER = os.environ["POSTGRES_USER"]
POSTGRES_PASSWORD = os.environ["POSTGRES_PASSWORD"]
POSTGRES_HOST = os.environ["POSTGRES_HOST"]
POSTGRES_PORT = int(os.environ["POSTGRES_PORT"])
POSTGRES_DATABASE = os.environ["POSTGRES_DATABASE"]


postgres_url = URL.create(
    drivername="postgresql+psycopg2",
    username=POSTGRES_USER,
    password=POSTGRES_PASSWORD,
    host=POSTGRES_HOST,
    port=POSTGRES_PORT,
    database=POSTGRES_DATABASE,
)


def main() -> None:
    if not SQLITE_PATH.exists():
        raise FileNotFoundError(
            f"SQLite-file not found: {SQLITE_PATH}"
        )

    postgres_engine = create_engine(postgres_url)
    sqlite_connection = sqlite3.connect(SQLITE_PATH)

    try:
        tables_query = """
            SELECT name
            FROM sqlite_master
            WHERE type = 'table'
              AND name NOT LIKE 'sqlite_%'
            ORDER BY name;
        """

        tables = pd.read_sql_query(
            tables_query,
            sqlite_connection
        )["name"].tolist()

        print(f"Tables found: {len(tables)}")
        print(tables)

        migration_results = []

        for table_name in tables:
            print(f"\nTransfer of table: {table_name}")

            query = f'SELECT * FROM "{table_name}"'

            dataframe = pd.read_sql_query(
                query,
                sqlite_connection
            )

            dataframe.to_sql(
                name=table_name,
                con=postgres_engine,
                schema="public",
                if_exists="replace",
                index=False,
                chunksize=5000,
                method="multi",
            )

            with postgres_engine.connect() as connection:
                result = connection.execute(
                    text(
                        f'SELECT COUNT(*) '
                        f'FROM public."{table_name}"'
                    )
                )
                postgres_count = result.scalar_one()

            sqlite_count = len(dataframe)

            status = (
                "OK"
                if sqlite_count == postgres_count
                else "ERROR"
            )

            migration_results.append(
                {
                    "table": table_name,
                    "sqlite_rows": sqlite_count,
                    "postgres_rows": postgres_count,
                    "status": status,
                }
            )

            print(
                f"{status}: SQLite {sqlite_count} lines, "
                f"PostgreSQL {postgres_count} lines"
            )

        results_dataframe = pd.DataFrame(migration_results)

        print("\nTransfer results:")
        print(results_dataframe.to_string(index=False))

        if not all(results_dataframe["status"] == "OK"):
            raise RuntimeError(
                "Some tables were transferred incorrectly."
            )

        print("\nAll tables have been successfully migrated.")

    finally:
        sqlite_connection.close()
        postgres_engine.dispose()


if __name__ == "__main__":
    main()