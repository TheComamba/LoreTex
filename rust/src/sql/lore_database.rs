use std::path::PathBuf;

use crate::errors::LoreTexError;
use diesel::{Connection, SqliteConnection};
use diesel_migrations::{embed_migrations, EmbeddedMigrations, MigrationHarness};

pub struct LoreDatabase {
    path: PathBuf,
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

    pub(super) fn db_connection(&self) -> Result<SqliteConnection, LoreTexError> {
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
}
