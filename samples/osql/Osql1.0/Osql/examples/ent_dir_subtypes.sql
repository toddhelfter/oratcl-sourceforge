/* Display the entity name and the abstract entity indicator for all direct
   subtypes of a specified entity.
*/

select e2.entity_def_nm,
          e2.is_abstract
     from entity_def e2,
          supersub ss,
          entity_def e1
     where e1.entity_def_nm = upper('&Entity_Name') and
           e1.entity_def_s = ss.super_s and
           ss.origin_s = ss.super_s and
           e2.entity_def_s = ss.sub_s
     order by e2.entity_def_nm

