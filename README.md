# lab101_dataplatform_ai

Batch data platform: Postgres / APIs / files -> Airbyte -> SeaweedFS -> ClickHouse (raw + marts), with dbt for
transformations, Dagster for orchestration, and Great Expectations for data quality.


## Quick start

```bash  # then edit the values
docker compose up -d
docker compose ps
```

## Local web UIs and ports

| Service | URL | Login |
|---|---|---|
| Airbyte | http://localhost:8000 | Email set with `abctl local credentials --email <email>`; password printed by that command |
| SeaweedFS Admin (buckets, files) | http://localhost:12646 | `SEAWEEDFS_UI_USER` / `SEAWEEDFS_UI_PASSWORD` from `.env`; bound to 127.0.0.1 only |
| ClickHouse SQL editor | http://localhost:8123/play | User `loader` (password `CLICKHOUSE_LOADER_PASSWORD`) or `default` (password `CLICKHOUSE_ADMIN_PASSWORD`) |

Ports without a web UI:

| Service | Address | How to use |
|---|---|---|
| Postgres (source) | `localhost:5433` | DBeaver or `psql` |
| ClickHouse HTTP / native | `localhost:8123` / `localhost:9000` | DBeaver (HTTP, port 8123) or `clickhouse-client` |
| SeaweedFS S3 API | `localhost:8333` | S3 clients with the keys from `.env`; `/healthz` returns 200 |

The SeaweedFS Filer UI (port 8888) is not published because it has no login.

## Timezone

`TIMEZONE` in `.env` (default `Asia/Bangkok`) sets the display timezone for logs and ClickHouse. Stored timestamps stay UTC. Set a SQL client's timezone separately (for DBeaver, add `-Duser.timezone=Asia/Bangkok` to `dbeaver.ini`).
