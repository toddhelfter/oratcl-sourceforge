/* Get the description for named data type(s) 
   using the Oracle wildcards % and or _
 */
select type_def_nm, description_text
from type_description
where type_def_nm  like upper('&Type_Name')
order by 1


