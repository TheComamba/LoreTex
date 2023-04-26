use super::{lore_database::LoreDatabase, schema::relationships};
use crate::errors::{sql_loading_error, LoreTexError};
use ::diesel::prelude::*;
use diesel::Insertable;
use diesel::{QueryDsl, Queryable, RunQueryDsl};

#[derive(Insertable, Queryable)]
#[diesel(table_name = relationships)]
#[repr(C)]
pub struct EntityRelationship {
    pub parent: String,
    pub child: String,
    pub role: Option<String>,
}

impl LoreDatabase {
    pub fn write_relationship(&self, rel: EntityRelationship) -> Result<(), LoreTexError> {
        let mut connection = self.db_connection()?;
        diesel::insert_into(relationships::table)
            .values(&rel)
            .execute(&mut connection)
            .map_err(|e| {
                LoreTexError::SqlError(
                    "Writing relationship to database failed: ".to_string() + &e.to_string(),
                )
            })?;
        Ok(())
    }

    pub fn get_parents(&self, child: &Option<&String>) -> Result<Vec<String>, LoreTexError> {
        let mut connection = self.db_connection()?;
        let mut query = relationships::table.into_boxed();
        if let Some(child) = child {
            query = query.filter(relationships::child.eq(child));
        }
        let parents = query
            .load::<EntityRelationship>(&mut connection)
            .map_err(|e| sql_loading_error("relationships", "parents", vec![("child", child)], e))?
            .into_iter()
            .map(|r| r.parent)
            .collect::<Vec<_>>();
        Ok(parents)
    }

    pub fn get_children(&self, parent: &Option<&String>) -> Result<Vec<String>, LoreTexError> {
        let mut connection = self.db_connection()?;
        let mut query = relationships::table.into_boxed();
        if let Some(parent) = parent {
            query = query.filter(relationships::parent.eq(parent))
        }
        let children = query
            .load::<EntityRelationship>(&mut connection)
            .map_err(|e| {
                sql_loading_error("relationships", "children", vec![("parent", parent)], e)
            })?
            .into_iter()
            .map(|r| r.child)
            .collect::<Vec<_>>();
        Ok(children)
    }

    pub fn get_relationship_role(
        &self,
        parent: &String,
        child: &String,
    ) -> Result<Option<String>, LoreTexError> {
        let mut connection = self.db_connection()?;
        let relationships = relationships::table
            .filter(relationships::parent.eq(parent))
            .filter(relationships::child.eq(child))
            .load::<EntityRelationship>(&mut connection)
            .map_err(|e| {
                sql_loading_error(
                    "relationship",
                    "role",
                    vec![("parent", &Some(parent)), ("child", &Some(child))],
                    e,
                )
            })?;
        if relationships.len() > 1 {
            Err(LoreTexError::SqlError(
                "More than one entry found for parent '".to_string()
                    + parent
                    + "' and child '"
                    + child
                    + "'.",
            ))
        } else {
            let role = match relationships.first() {
                Some(relationship) => relationship.role.to_owned(),
                None => {
                    return Err(LoreTexError::SqlError(
                        "No content found for parent '".to_string()
                            + parent
                            + "' and child '"
                            + child
                            + "'.",
                    ))
                }
            };
            Ok(role)
        }
    }
}
