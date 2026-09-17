
    
    

with all_values as (

    select
        Situacio as value_field,
        count(*) as n_records

    from "dev"."main"."PG_Socis_Completa"
    group by Situacio

)

select *
from all_values
where value_field not in (
    '0','1','2','3'
)


