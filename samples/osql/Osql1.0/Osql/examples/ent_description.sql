/* Get the description for an entity, or multiple entities
   using the Oracle wildcards % and or _
 */
select entity_def_nm, description_text
from entity_description
where entity_def_nm  like upper('&Entity_Name')
order by 1

