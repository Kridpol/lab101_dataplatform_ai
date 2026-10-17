# lab101_dataplatform_ai

Batch data platform: Postgres / APIs / files -> Airbyte -> SeaweedFS -> ClickHouse (raw + marts), with dbt for
transformations, Dagster for orchestration, and Great Expectations for data quality.


## Quick start

```bash
cp .env.example .env          # non-secret settings; edit if needed
bash scripts/gen_secrets.sh   # random passwords and keys into ./secrets (git-ignored)
docker compose up -d
docker compose ps
```

## Secrets

Passwords and keys are files in `./secrets`, one per value, created by `scripts/gen_secrets.sh` (existing files are kept). Compose mounts them into containers at `/run/secrets/<name>`, so they are not in environment variables or `docker inspect`. Two are not generated: copy `airbyte_client_id` and `airbyte_client_secret` from `abctl local credentials` into `secrets/`. To read one: `cat secrets/<name>`. Init scripts run only on an empty volume: to change a password later, run `ALTER USER` and update its file.

## Sample data

Postgres loads `postgres/seed/customers.csv`, `products.csv` and `orders.csv` on first start. The CSVs are git-ignored; a missing file is skipped and its table stays empty. To use your own data, put CSVs with these headers in `postgres/seed/` before the first `docker compose up`:

- `customers.csv`: `customer_id,name,email,country,created_at,updated_at`
- `products.csv`: `product_id,name,category,price,created_at,updated_at`
- `orders.csv`: `order_id,customer_id,product_id,quantity,amount,status,created_at,updated_at`

After `docker compose down -v` and a reseed, clear the three streams in Airbyte before syncing again, or its saved cursor skips older rows.

## Local web UIs and ports

| Service | URL | Login |
|---|---|---|
| Airbyte | http://localhost:8000 | Email set with `abctl local credentials --email <email>`; password printed by that command |
| SeaweedFS Admin (buckets, files) | http://localhost:12646 | `SEAWEEDFS_UI_USER` from `.env`, password in `secrets/seaweedfs_ui_password`; bound to 127.0.0.1 only |
| Dagster (orchestrator) | http://localhost:3000 | No login; bound to 127.0.0.1 only |
| ClickHouse SQL editor | http://localhost:8123/play | User `loader` (`secrets/clickhouse_loader_password`) or `default` (`secrets/clickhouse_admin_password`) |

Ports without a web UI:

| Service | Address | How to use |
|---|---|---|
| Postgres (source) | `localhost:5433` | DBeaver or `psql` |
| ClickHouse HTTP / native | `localhost:8123` / `localhost:9000` | DBeaver (HTTP, port 8123) or `clickhouse-client` |
| SeaweedFS S3 API | `localhost:8333` | S3 clients with the keys in `secrets/seaweedfs_*`; `/healthz` returns 200 |

The SeaweedFS Filer UI (port 8888) is not published because it has no login.

## Timezone

`TIMEZONE` in `.env` (default `Asia/Bangkok`) sets the display timezone for logs and ClickHouse. Stored timestamps stay UTC. Set a SQL client's timezone separately (for DBeaver, add `-Duser.timezone=Asia/Bangkok` to `dbeaver.ini`).
