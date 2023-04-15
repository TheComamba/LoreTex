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
        diesel::insert_into(history_items::table)
            .values(&col)
            .execute(&mut connection)
            .map_err(|e| {
                LoreTexError::SqlError(
                    "Writing history item to database failed: ".to_string() + &e.to_string(),
                )
            })?;
        Ok(())
    }

    pub fn get_all_years(&self) -> Result<Vec<i32>, LoreTexError> {
        let mut connection = self.db_connection()?;
        let mut years = history_items::table
            .load::<HistoryItem>(&mut connection)
            .map_err(|e| {
                LoreTexError::SqlError(
                    "Loading history item to get all years failed: ".to_string() + &e.to_string(),
                )
            })?
            .into_iter()
            .map(|c| c.year)
            .collect::<Vec<_>>();
        years.dedup();
        Ok(years)
    }

    pub fn get_history_labels(&self) -> Result<Vec<String>, LoreTexError> {
        let mut connection = self.db_connection()?;
        let labels = history_items::table
            .load::<HistoryItem>(&mut connection)
            .map_err(|e| {
                LoreTexError::SqlError(
                    "Loading history items to get all labels failed: ".to_string() + &e.to_string(),
                )
            })?
            .into_iter()
            .map(|c| c.label)
            .collect::<Vec<_>>();
        Ok(labels)
    }
}
