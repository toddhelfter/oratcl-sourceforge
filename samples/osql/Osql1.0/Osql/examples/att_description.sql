/* Get the description for an attribute  or multiple attributes
   using the Oracle wildcards % and or _
 */
select parent_ent, attribute_nm, description_text
from attribute_description
where parent_ent  like upper('&Entity_Name')
and attribute_nm like upper('&Attribute_Name')
order by 1, 2
