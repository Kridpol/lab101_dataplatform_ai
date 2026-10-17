from dagster import AssetExecutionContext, Definitions, asset

from .airbyte_assets import airbyte_assets, airbyte_workspace
from .clickhouse_load import load_assets
from .dbt_assets import dbt_models, dbt_resource
from .jobs import ingest_shop_data_pipeline

defs = Definitions(
    assets=[*airbyte_assets, *load_assets, dbt_models],
    jobs=[ingest_shop_data_pipeline],
    resources={"airbyte": airbyte_workspace, "dbt": dbt_resource},
)

