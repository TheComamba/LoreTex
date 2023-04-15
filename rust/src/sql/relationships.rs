use crate::errors::LoreTexError;
use diesel::{Insertable, Queryable, RunQueryDsl};

use super::{lore_database::LoreDatabase, schema::relationships};

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
}
