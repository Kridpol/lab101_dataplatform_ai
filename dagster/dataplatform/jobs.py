from dagster import AssetSelection, define_asset_job

ingest_shop_data_pipeline = define_asset_job("ingest_shop_data_pipeline", 
                                             selection=AssetSelection.all())
