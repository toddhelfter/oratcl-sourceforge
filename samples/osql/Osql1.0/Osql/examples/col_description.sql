/* Get the description for a column or multiple columns
   using the Oracle wildcards % and or _
 */
select table_def_nm, column_def_nm, description_text
from column_description
where table_def_nm  like upper('&Table_Name')
and column_def_nm like upper('&Column_Name')
order by 1, 2

