/* Display all information about all direct attributes (excludes inherited
   attributes) belonging to an entity.
*/

select a.*
  from
    attribute a
  where
    a.parent_ent = upper('&Entity_Name')
  order by a.attribute_nm




