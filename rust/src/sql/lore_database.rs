use std::path::PathBuf;

use crate::{errors::LoreTexError, sql::schema::entities};
use ::diesel::prelude::*;
use diesel::{Connection, Insertable, RunQueryDsl, SqliteConnection};
use diesel_migrations::{embed_migrations, EmbeddedMigrations, MigrationHarness};

pub struct LoreDatabase {
    path: PathBuf,
}

#[derive(Insertable, Queryable)]
#[diesel(table_name = entities)]
#[repr(C)]
pub struct EntityColumn {
    pub label: String,
    pub descriptor: String,
    pub description: String,
}

const MIGRATIONS: EmbeddedMigrations = embed_migrations!();

impl LoreDatabase {
    pub fn open(path: PathBuf) -> Result<Self, LoreTexError> {
        let db = LoreDatabase { path };
        db.db_connection()?
            .run_pending_migrations(MIGRATIONS)
            .map_err(|e| {
                LoreTexError::SqlError(
                    "Failed to run SQL database migrations: ".to_string() + &e.to_string(),
                )
            })?;
        Ok(db)
    }

    pub fn path_as_string(&self) -> String {
        self.path.to_string_lossy().to_string()
    }

    fn db_connection(&self) -> Result<SqliteConnection, LoreTexError> {
        let path = match self.path.to_str() {
            Some(str) => str,
            None => return Err(LoreTexError::FileError(
                "Could not open database path.".to_string()
                    + "This is likely because it contains characters that can not be UTF-8 encoded."
                    + "The lossy path conversion reads:\n"
                    + &self.path.to_string_lossy(),
            )),
        };
        SqliteConnection::establish(path).map_err(|e| {
            LoreTexError::SqlError(
                "Failed to establish a connection to the database: ".to_string() + &e.to_string(),
            )
        })
    }

    pub fn write_column(&self, col: EntityColumn) -> Result<(), LoreTexError> {
        let mut connection = self.db_connection()?;
        let _ = diesel::insert_into(entities::table)
            .values(&col)
            .execute(&mut connection)
            .map_err(|e| {
                LoreTexError::SqlError(
                    "Writing column to database failed: ".to_string() + &e.to_string(),
                )
            })?;
        Ok(())
    }

    pub fn get_all_labels(&self) -> Result<Vec<String>, LoreTexError> {
        let mut connection = self.db_connection()?;
        let mut labels = entities::table
            .load::<EntityColumn>(&mut connection)
            .map_err(|e| {
                LoreTexError::SqlError(
                    "Loading entities to get all labels failed: ".to_string() + &e.to_string(),
                )
            })?
            .into_iter()
            .map(|c| c.label)
            .collect::<Vec<_>>();
        labels.dedup();
        Ok(labels)
    }

    pub fn get_all_descriptors(&self, label: &String) -> Result<Vec<String>, LoreTexError> {
        let mut connection = self.db_connection()?;
        let descriptors = entities::table
            .filter(entities::label.eq(label))
            .load::<EntityColumn>(&mut connection)
            .map_err(|e| {
                LoreTexError::SqlError(
                    "Loading entities to get descriptors for label ".to_string()
                        + label
                        + " failed: "
                        + &e.to_string(),
                )
            })?
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
                LoreTexError::SqlError(
                    "Loading entities for label '".to_string()
                        + label
                        + "' and descriptor '"
                        + descriptor
                        + "' failed: "
                        + &e.to_string(),
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
