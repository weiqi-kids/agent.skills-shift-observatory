#!/usr/bin/env python3
"""
Parse ABS SDMX-JSON to JSONL format
Usage: python3 parse_sdmx.py input.json output.jsonl [--filter]
"""

import json
import sys
from datetime import datetime, timezone

# Key measures to include when filtering
KEY_MEASURES = {
    'M3',   # Employed persons
    'M6',   # Unemployed persons
    'M9',   # Labour Force
    'M12',  # Participation rate
    'M13',  # Unemployment rate
    'M16',  # Employment to population ratio
}

def parse_sdmx_json(input_file, output_file, filter_data=True):
    with open(input_file, 'r') as f:
        data = json.load(f)

    # Extract dimension mappings
    series_dims = data['structure']['dimensions']['series']
    obs_dims = data['structure']['dimensions']['observation']

    # Build lookup tables for each dimension
    dim_values = {}
    for dim in series_dims:
        dim_values[dim['id']] = {i: v for i, v in enumerate(dim['values'])}

    # Time period lookup
    time_periods = {i: v for i, v in enumerate(obs_dims[0]['values'])}

    # Get dimension order (for series key parsing)
    dim_order = [d['id'] for d in series_dims]

    records = []
    fetched_at = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')

    # Iterate through all series
    for series_key, series_data in data['dataSets'][0]['series'].items():
        # Parse series key (e.g., "0:0:0:0:0:0")
        key_indices = [int(x) for x in series_key.split(':')]

        # Map indices to actual values
        series_info = {}
        for i, dim_id in enumerate(dim_order):
            if i < len(key_indices):
                idx = key_indices[i]
                if idx in dim_values[dim_id]:
                    val = dim_values[dim_id][idx]
                    series_info[dim_id.lower()] = val['id']
                    series_info[f"{dim_id.lower()}_name"] = val['name']

        # Apply filter: National (AUS), Seasonally Adjusted (20), Total Persons (3), Key Measures
        if filter_data:
            if series_info.get('region') != 'AUS':
                continue
            if series_info.get('tsest') != '20':  # Seasonally Adjusted
                continue
            if series_info.get('sex') != '3':  # Total Persons
                continue
            if series_info.get('measure') not in KEY_MEASURES:
                continue

        # Iterate through observations
        for obs_key, obs_value in series_data.get('observations', {}).items():
            obs_idx = int(obs_key)
            if obs_idx not in time_periods:
                continue

            time_info = time_periods[obs_idx]
            value = obs_value[0] if obs_value else None

            if value is None:
                continue

            record = {
                'source': 'abs_labour_force',
                'country': 'AUS',
                'country_name': 'Australia',
                'time_period': time_info['id'],
                'time_period_name': time_info['name'],
                'value': value,
                'fetched_at': fetched_at,
                **series_info
            }
            records.append(record)

    # Write JSONL
    with open(output_file, 'w') as f:
        for record in records:
            f.write(json.dumps(record, ensure_ascii=False) + '\n')

    return len(records)

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} input.json output.jsonl [--no-filter]")
        sys.exit(1)

    filter_data = '--no-filter' not in sys.argv
    count = parse_sdmx_json(sys.argv[1], sys.argv[2], filter_data)
    print(f"Parsed {count} records")
