/* Get the table(s) that an entity or entities project to
   using the Oracle wildcards % and or _
 */
select entity_def_nm, table_def_nm, ref_proj_meth
from entity_table
where entity_def_nm  like upper('&Entity_Name')
order by 1, 2



