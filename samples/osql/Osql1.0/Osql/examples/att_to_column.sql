/* Get the column(s) that an attribute or attributes  project to
   using the Oracle wildcards % and or _
 */
select entity_def_nm, attribute_nm, parent_table_nm, column_def_nm, ref_proj_meth
from attribute_column
where entity_def_nm  like upper('&Entity_Name')
and attribute_nm like upper('&Attribute_Name')
order by 1, 2



