
    
    

select
    PersonaRol_Id as unique_field,
    count(*) as n_records

from "dev"."main"."PersonaRoles"
where PersonaRol_Id is not null
group by PersonaRol_Id
having count(*) > 1


