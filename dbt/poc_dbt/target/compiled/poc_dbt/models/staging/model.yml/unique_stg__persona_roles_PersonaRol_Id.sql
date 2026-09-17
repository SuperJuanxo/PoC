
    
    

select
    PersonaRol_Id as unique_field,
    count(*) as n_records

from "dev"."main"."stg__persona_roles"
where PersonaRol_Id is not null
group by PersonaRol_Id
having count(*) > 1


