use std::env;

use crate::{errors::GuiError, schema::entities};
use ::diesel::prelude::*;
use diesel::{Connection, Insertable, RunQueryDsl, SqliteConnection};
use diesel_migrations::{embed_migrations, EmbeddedMigrations, MigrationHarness};
use dotenvy::dotenv;

pub const MIGRATIONS: EmbeddedMigrations = embed_migrations!();

pub(crate) fn run_migrations() -> Result<(), GuiError> {
    db_connection()?
        .run_pending_migrations(MIGRATIONS)
        .map_err(|_| GuiError::Other("Failed to run SQL database migrations.".to_string()))?;

    Ok(())
}

#[derive(Insertable, Queryable)]
#[diesel(table_name = entities)]
pub(crate) struct EntityColumn {
    pub label: String,
    pub descriptor: String,
    pub description: String,
}

fn db_connection() -> Result<SqliteConnection, GuiError> {
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
        GuiError::Other("Failed to establish a connection to the database".to_string())
    });
}

pub(crate) fn get_all_labels() -> Result<Vec<String>, GuiError> {
    let mut connection = db_connection()?;
    let labels = entities::table
        .load::<EntityColumn>(&mut connection)
        .map_err(|_| GuiError::Other("Loading entities to get all labels failed".to_string()))?
        .into_iter()
        .map(|c| c.label)
        .collect();
    return Ok(labels);
}

pub(crate) fn get_all_descriptors(label: &String) -> Result<Vec<String>, GuiError> {
    let mut connection = db_connection()?;
    let descriptors = entities::table
        .filter(entities::label.eq(label))
        .load::<EntityColumn>(&mut connection)
        .map_err(|_| GuiError::Other("Loading entities to get descriptors failed".to_string()))?
        .into_iter()
        .map(|c| c.descriptor)
        .collect();
    return Ok(descriptors);
}
