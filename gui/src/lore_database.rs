use std::{env, path::PathBuf};

use crate::{errors::GuiError, schema::entities};
use ::diesel::prelude::*;
use diesel::{Connection, Insertable, RunQueryDsl, SqliteConnection};
use diesel_migrations::{embed_migrations, EmbeddedMigrations, MigrationHarness};
use dotenvy::dotenv;

pub(crate) struct LoreDatabase {
    path: PathBuf,
}

#[derive(Insertable, Queryable)]
#[diesel(table_name = entities)]
pub(crate) struct EntityColumn {
    pub label: String,
    pub descriptor: String,
    pub description: String,
}

const MIGRATIONS: EmbeddedMigrations = embed_migrations!();

impl LoreDatabase {
    pub(crate) fn new(path: PathBuf) -> Result<Self, GuiError> {
        let db = LoreDatabase { path };
        db.db_connection()?
            .run_pending_migrations(MIGRATIONS)
            .map_err(|_| GuiError::Other("Failed to run SQL database migrations.".to_string()))?;
        return Ok(db);
    }

    pub(crate) fn open(path: PathBuf) -> Result<Self, GuiError> {
        return Ok(LoreDatabase { path });
    }

    fn db_connection(&self) -> Result<SqliteConnection, GuiError> {
        dotenv().ok();
        let database_path = match env::var("DATABASE_URL") {
            Ok(path) => path,
            Err(_) => {
                return Err(GuiError::Other(
                    "The database path must be set in the .env file.".to_string(),
                ))
            }
        };
        return SqliteConnection::establish(&database_path).map_err(|_| {
            GuiError::Other("Failed to establish a connection to the database.".to_string())
        });
    }

    pub(crate) fn get_all_labels(&self) -> Result<Vec<String>, GuiError> {
        let mut connection = self.db_connection()?;
        let mut labels = entities::table
            .load::<EntityColumn>(&mut connection)
            .map_err(|_| GuiError::Other("Loading entities to get all labels failed.".to_string()))?
            .into_iter()
            .map(|c| c.label)
            .collect::<Vec<_>>();
        labels.dedup();
        return Ok(labels);
    }

    pub(crate) fn get_all_descriptors(&self, label: &String) -> Result<Vec<String>, GuiError> {
        let mut connection = self.db_connection()?;
        let descriptors = entities::table
            .filter(entities::label.eq(label))
            .load::<EntityColumn>(&mut connection)
            .map_err(|_| {
                GuiError::Other(
                    "Loading entities to get descriptors for label ".to_string()
                        + label
                        + " failed.",
                )
            })?
            .into_iter()
            .map(|c| c.descriptor)
            .collect();
        return Ok(descriptors);
    }

    pub(crate) fn get_description(
        &self,
        label: &String,
        descriptor: &String,
    ) -> Result<String, GuiError> {
        let mut connection = self.db_connection()?;
        let descriptions = entities::table
            .filter(entities::label.eq(label))
            .filter(entities::descriptor.eq(descriptor))
            .load::<EntityColumn>(&mut connection)
            .map_err(|_| {
                GuiError::Other(
                    "Loading entities to for label ".to_string()
                        + label
                        + " and descriptor "
                        + descriptor
                        + " failed.",
                )
            })?;
        if descriptions.len() > 1 {
            return Err(GuiError::Other(
                "More than one description found for label ".to_string()
                    + label
                    + " and descriptor "
                    + descriptor
                    + ".",
            ));
        } else {
            let description = match descriptions.first() {
                Some(col) => col.description.to_owned(),
                None => {
                    return Err(GuiError::Other(
                        "No description found for label ".to_string()
                            + label
                            + " and descriptor "
                            + descriptor
                            + ".",
                    ))
                }
            };
            return Ok(description);
        }
    }
}
