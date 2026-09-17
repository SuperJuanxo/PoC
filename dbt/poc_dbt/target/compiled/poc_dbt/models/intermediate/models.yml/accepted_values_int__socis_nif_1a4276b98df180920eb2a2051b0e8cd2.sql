
    
    

with all_values as (

    select
        Descripcion_del_caso as value_field,
        count(*) as n_records

    from "dev"."main"."int__socis_nif_dup"
    group by Descripcion_del_caso

)

select *
from all_values
where value_field not in (
    'DNI en varios Socis','Ambos casos'
)


