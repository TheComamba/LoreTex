use ::diesel::prelude::*;
use diesel::Insertable;

use crate::errors::LoreTexError;

use super::{lore_database::LoreDatabase, schema::history_items};

#[derive(Insertable, Queryable)]
#[diesel(table_name = history_items)]
#[repr(C)]
pub struct HistoryItem {
    pub label: String,
    pub content: String,
    pub is_concerns_others: bool,
    pub is_secret: bool,
    pub year: i32,
    pub day: Option<i32>,
    pub originator: Option<String>,
    pub year_format: Option<String>,
}

impl LoreDatabase {
    pub fn write_history_item(&self, col: HistoryItem) -> Result<(), LoreTexError> {
        let mut connection = self.db_connection()?;
        let _ = diesel::insert_into(history_items::table)
            .values(&col)
            .execute(&mut connection)
            .map_err(|e| {
                LoreTexError::SqlError(
                    "Writing history item to database failed: ".to_string() + &e.to_string(),
                )
            })?;
        Ok(())
    }
}
