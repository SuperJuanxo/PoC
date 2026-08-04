{{ config(
    materialized='view'
) }}

select *
from {{ ref('seed_PersonaRoles') }}