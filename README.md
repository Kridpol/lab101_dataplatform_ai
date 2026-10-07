# lab101_dataplatform_ai

Batch data platform: Postgres / APIs / files → Airbyte → ClickHouse (raw + marts), with dbt for
transformations, Airflow for orchestration, and Great Expectations for data quality.

Built incrementally; see `CLAUDE.md` for the plan and current status.

## Quick start

```bash
cp .env.example .env     # then edit the values
docker compose up -d
docker compose ps
```
