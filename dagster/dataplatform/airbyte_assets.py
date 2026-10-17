import os

from dagster import EnvVar
from dagster_airbyte import AirbyteWorkspace, build_airbyte_assets_definitions


airbyte_workspace = AirbyteWorkspace(
    rest_api_base_url="http://host.docker.internal:8000/api/public/v1",
    configuration_api_base_url="http://host.docker.internal:8000/api/v1",
    workspace_id=EnvVar("AIRBYTE_WORKSPACE_ID"),
    client_id=EnvVar("AIRBYTE_CLIENT_ID"),
    client_secret=EnvVar("AIRBYTE_CLIENT_SECRET"),
)

_connection_id = os.environ["AIRBYTE_CONNECTION_ID"]


airbyte_assets = build_airbyte_assets_definitions(
    workspace=airbyte_workspace,
    connection_selector_fn=lambda connection: connection.id == _connection_id,
)
