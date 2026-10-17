import os
from pathlib import Path

import clickhouse_connect
from dagster import AssetExecutionContext, AssetKey, asset

SQL_DIR = Path("/sql")
TABLES = ["pg_customers", "pg_products", "pg_orders"]


def run_sql_file(relative_path: str) -> None:
    client = clickhouse_connect.get_client(
        host=os.environ["CLICKHOUSE_HOST"],
        port=int(os.environ["CLICKHOUSE_PORT"]),
        username=os.environ["CLICKHOUSE_LOADER_USER"],
        password=os.environ["CLICKHOUSE_LOADER_PASSWORD"],
    )
    text = (SQL_DIR / relative_path).read_text()
    # Drop comment lines first: some contain ';'.
    text = "\n".join(l for l in text.splitlines() if not l.strip().startswith("--"))
    for statement in text.split(";"):
        if statement.strip():
            client.command(statement)


def make_load_asset(table: str):
    @asset(key=["raw", table], deps=[AssetKey(table)], group_name="raw")
    def load(context: AssetExecutionContext) -> None:
        run_sql_file("ddl/_load_log.sql")
        run_sql_file(f"ddl/{table}.sql")
        run_sql_file(f"load/{table}.sql")
        context.log.info(f"loaded raw.{table}")

    return load


load_assets = [make_load_asset(t) for t in TABLES]
