use super::lore_database::LoreDatabase;
use crate::{
    errors::{sql_loading_error, sql_loading_error_no_params, LoreTexError},
    sql::schema::entities,
};
use ::diesel::prelude::*;
use diesel::{Insertable, RunQueryDsl};

#[derive(Insertable, Queryable)]
#[diesel(table_name = entities)]
#[repr(C)]
pub struct EntityColumn {
    pub label: String,
    pub descriptor: String,
    pub description: String,
}

impl LoreDatabase {
    pub fn write_entity_column(&self, col: EntityColumn) -> Result<(), LoreTexError> {
        let mut connection = self.db_connection()?;
        diesel::insert_into(entities::table)
            .values(&col)
            .execute(&mut connection)
            .map_err(|e| {
                LoreTexError::SqlError(
                    "Writing column to database failed: ".to_string() + &e.to_string(),
                )
            })?;
        Ok(())
    }

    pub fn get_all_entity_labels(&self) -> Result<Vec<String>, LoreTexError> {
        let mut connection = self.db_connection()?;
        let labels = entities::table
            .load::<EntityColumn>(&mut connection)
            .map_err(|e| sql_loading_error_no_params("entities", "all labels", e))?
            .into_iter()
            .map(|c| c.label)
            .collect::<Vec<_>>();
        Ok(labels)
    }

    pub fn get_descriptors(&self, label: &Option<&String>) -> Result<Vec<String>, LoreTexError> {
        let mut connection = self.db_connection()?;
        let mut query = entities::table.into_boxed();
        if let Some(label) = label {
            query = query.filter(entities::label.eq(label));
        }
        let descriptors = query
            .load::<EntityColumn>(&mut connection)
            .map_err(|e| sql_loading_error("entities", "descriptors", vec![("label", label)], e))?
            .into_iter()
            .map(|c| c.descriptor)
            .collect();
        Ok(descriptors)
    }

    pub fn get_description(
        &self,
        label: &String,
        descriptor: &String,
    ) -> Result<String, LoreTexError> {
        let mut connection = self.db_connection()?;
        let descriptions = entities::table
            .filter(entities::label.eq(label))
            .filter(entities::descriptor.eq(descriptor))
            .load::<EntityColumn>(&mut connection)
            .map_err(|e| {
                sql_loading_error(
                    "entities",
                    "description",
                    vec![("label", &Some(label)), ("descriptor", &Some(descriptor))],
                    e,
                )
            })?;
        if descriptions.len() > 1 {
            Err(LoreTexError::SqlError(
                "More than one description found for label '".to_string()
                    + label
                    + "' and descriptor '"
                    + descriptor
                    + "'.",
            ))
        } else {
            let description = match descriptions.first() {
                Some(col) => col.description.to_owned(),
                None => {
                    return Err(LoreTexError::SqlError(
                        "No description found for label '".to_string()
                            + label
                            + "' and descriptor '"
                            + descriptor
                            + "'.",
                    ))
                }
            };
            Ok(description)
        }
    }
}
