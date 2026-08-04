{{ config(
    materialized='view'
) }}

select
    Clau,
    Soci,
    SociPotencial,
    NIF,
    Nom,
    Cognoms,
    DataNaixement,
    Sexe,
    CodiPostal,
    Poblacio,
    Adreca,
    Email,
    Situacio,
    DataAlta,
    DataBaixa
from {{ ref('seed__PG_Socis_Completa') }}
