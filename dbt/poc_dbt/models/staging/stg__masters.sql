{{ config(
    materialized='view'
) }}

select *
from {{ ref('seed_Masters') }}