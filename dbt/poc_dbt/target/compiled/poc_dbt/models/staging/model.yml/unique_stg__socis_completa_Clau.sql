
    
    

select
    Clau as unique_field,
    count(*) as n_records

from "dev"."main"."stg__socis_completa"
where Clau is not null
group by Clau
having count(*) > 1


