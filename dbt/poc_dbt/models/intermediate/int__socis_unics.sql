{{
    config(
        materialized='table',
        tags= ['socis']
    )
}}

WITH BASE AS (

    SELECT *
    FROM {{ ref('stg__socis_completa') }}
    WHERE NIF IS NOT NULL

        /*
        Elimina DNIs tipo:
        00000000T
        11111111A
        99999999R
        */

        AND LEFT(NIF, 8) <> REPEAT(LEFT(NIF, 1), 8)
        AND LEFT(NIF, 7) <> '0000000'
        AND LEFT(NIF, 8) <> ' 000000'
        AND NIF <> ''

),

SOCI_NIF AS (

    SELECT
        Soci,
        NIF
    FROM BASE
    GROUP BY
        Soci,
        NIF

),

NIF_SIMPLE AS (

    SELECT
        NIF,
        COUNT(*) AS Qty_NIF
    FROM SOCI_NIF
    GROUP BY NIF
    HAVING COUNT(*) = 1

),

SOCI_SIMPLE AS (

    SELECT
        Soci,
        COUNT(*) AS Qty_NIF
    FROM SOCI_NIF
    GROUP BY Soci
    HAVING COUNT(*) = 1

),

sa AS (

    SELECT
        s.Soci,
        s.NIF,
        s.DataAlta,
        s.DataBaixa,
        s.Situacio,

        mtr.Id AS Cliente_Id,

        ROW_NUMBER() OVER (
            PARTITION BY mtr.Id
            ORDER BY
                DataAlta,
                COALESCE(DataBaixa, DATE '9999-12-31')
        )

        -

        ROW_NUMBER() OVER (
            PARTITION BY mtr.Id, NIF
            ORDER BY
                DataAlta,
                COALESCE(DataBaixa, DATE '9999-12-31')
        ) AS rn

    FROM BASE s

    LEFT JOIN {{ ref('stg__masters') }} mtr
        ON mtr.Tabla = 'Clientes'
       AND mtr.Codigo_PG = s.Soci

),

ultima_fila_isla AS (

    SELECT
        *,

        ROW_NUMBER() OVER (
            PARTITION BY Cliente_Id, NIF, rn
            ORDER BY
                DataAlta DESC,
                COALESCE(DataBaixa, DATE '9999-12-31') DESC
        ) AS rn_last

    FROM sa

),

FINAL_PROPUESTA AS (

    SELECT
        Soci,
        Cliente_Id,
        NIF,
        rn,
        DataAlta,
        DataBaixa,
        Situacio

    FROM ultima_fila_isla

    WHERE rn_last = 1

),

FINAL_GROUP AS (

    SELECT
        a.*,

        'OK' AS Descripcion_del_caso

    FROM FINAL_PROPUESTA a

    LEFT JOIN NIF_SIMPLE nr
        ON nr.NIF = a.NIF

    LEFT JOIN SOCI_SIMPLE sr
        ON sr.Soci = a.Soci

    WHERE
        nr.NIF IS NOT NULL
        AND sr.Soci IS NOT NULL

)

SELECT *
FROM FINAL_GROUP