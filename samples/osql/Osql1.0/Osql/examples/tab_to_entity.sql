/* Get the entity or entities that table(s) were projected from
   using the Oracle wildcards % and or _
 */
select table_def_nm, entity_def_nm, ref_proj_meth
from entity_table
where table_def_nm  like upper('&Table_Name')
order by 1, 2


