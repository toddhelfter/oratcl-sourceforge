/* Get the description for a table or multiple tables
   using the Oracle wildcards % and or _
 */
select table_def_nm, description_text
from table_description
where table_def_nm  like upper('&Table_Name')
order by 1


