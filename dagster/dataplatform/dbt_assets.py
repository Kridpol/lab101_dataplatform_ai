from pathlib import Path

from dagster import AssetExecutionContext
from dagster_dbt import DbtCliResource, DbtProject, dbt_assets

dbt_project = DbtProject(project_dir=Path("/dbt"))
# Run `dbt parse` on every code load so the manifest matches the models on disk.
dbt_project.preparer.prepare(dbt_project)

dbt_resource = DbtCliResource(project_dir=dbt_project)


# One asset per model/seed; dbt tests become asset checks. Sources raw.pg_* map to
# the load assets with the same keys (raw/pg_*).
@dbt_assets(manifest=dbt_project.manifest_path)
def dbt_models(context: AssetExecutionContext, dbt: DbtCliResource):
    yield from dbt.cli(["build"], context=context).stream()
