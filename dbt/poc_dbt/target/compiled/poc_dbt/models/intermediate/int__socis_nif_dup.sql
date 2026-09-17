

WITH BASE AS (

    SELECT *
    FROM "dev"."main"."stg__socis_completa"
    WHERE NIF IS NOT NULL
        AND LEFT(NIF, 8) <> REPEAT(LEFT(NIF, 1), 8)
        AND LEFT(NIF, 7) <> '0000000'
        AND LEFT(NIF, 8) <> ' 000000'
        AND NIF <> ''

),

SOCI_DUP AS (

    SELECT
        Soci,
        NIF
    FROM BASE
    GROUP BY
        Soci,
        NIF

),

NIF_REUSED AS (

    SELECT
        NIF,
        COUNT(*) AS Qty_NIF
    FROM SOCI_DUP
    GROUP BY NIF
    HAVING COUNT(*) > 1

),

SOCI_REUSED AS (

    SELECT
        Soci,
        COUNT(*) AS Qty_NIF
    FROM SOCI_DUP
    GROUP BY Soci
    HAVING COUNT(*) > 1

),

SA AS (

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

    LEFT JOIN "dev"."main"."stg__masters" mtr
        ON mtr.Tabla = 'Clientes'
       AND mtr.Codigo_PG = s.Soci

),

ULTIMA_FILA_ISLA AS (

    SELECT
        *,

        ROW_NUMBER() OVER (
            PARTITION BY Cliente_Id, NIF, rn
            ORDER BY
                DataAlta DESC,
                COALESCE(DataBaixa, DATE '9999-12-31') DESC
        ) AS rn_last

    FROM SA

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

    FROM ULTIMA_FILA_ISLA

    WHERE rn_last = 1

),

FINAL_GROUP AS (

    SELECT
        a.*,

        CASE
            WHEN nr.NIF IS NOT NULL
             AND sr.Soci IS NOT NULL
                THEN 'Ambos casos'

            WHEN nr.NIF IS NOT NULL
                THEN 'DNI en varios Socis'

            WHEN sr.Soci IS NOT NULL
                THEN 'Soci con varios NIF'
        END AS Descripcion_del_caso

    FROM FINAL_PROPUESTA a

    LEFT JOIN NIF_REUSED nr
        ON nr.NIF = a.NIF

    LEFT JOIN SOCI_REUSED sr
        ON sr.Soci = a.Soci

    WHERE
        nr.NIF IS NOT NULL
        OR sr.Soci IS NOT NULL

),

FINAL_NIF AS (

    SELECT *
    FROM FINAL_GROUP

    WHERE Descripcion_del_caso IN (
        'DNI en varios Socis',
        'Ambos casos'
    )

)

SELECT *
FROM FINAL_NIF