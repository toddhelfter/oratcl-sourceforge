/* Display all information about all attributes (including inherited attributes)
   belonging to an entity.
*/

select a.*
  from
    all_attributes a  -- all_attributes is a view not a table.
  where
    a.entity_def_nm = upper('&Entity_Name')
  order by a.attribute_nm

