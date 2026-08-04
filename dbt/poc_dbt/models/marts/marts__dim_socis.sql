{{
    config(
        materialized='table',
        tags=['socis']
    )
}}

WITH UNION_ALL AS (

    SELECT
        Soci,
        Cliente_Id,
        NIF,
        rn,
        DataAlta,
        DataBaixa,
        Situacio,
        Descripcion_del_caso
    FROM {{ ref('int__socis_unics') }}

    UNION ALL

    SELECT
        Soci,
        Cliente_Id,
        NIF,
        rn,
        DataAlta,
        DataBaixa,
        Situacio,
        Descripcion_del_caso
    FROM {{ ref('int__socis_nif_dup') }}

)

SELECT *
FROM UNION_ALL