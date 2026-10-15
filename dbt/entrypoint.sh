#!/bin/sh
# Build the venv once (cached in the dbt-venv volume), then run dbt with the given args.
set -e
if [ ! -x /opt/venv/bin/dbt ]; # Check DBT ติดตั้งอยู่ใน venv หรือไม่
then
  python -m venv /opt/venv
  /opt/venv/bin/pip install -q --no-cache-dir -r /dbt/requirements.txt
fi
exec /opt/venv/bin/dbt "$@" #
