use super::{lore_database::LoreDatabase, schema::history_items};
use crate::errors::{sql_loading_error, sql_loading_error_no_params, LoreTexError};
use ::diesel::prelude::*;
use diesel::Insertable;

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
        let years = history_items::table
            .load::<HistoryItem>(&mut connection)
            .map_err(|e| sql_loading_error_no_params("history items", "all years", e))?
            .into_iter()
            .map(|c| c.year)
            .collect::<Vec<_>>();
        Ok(years)
    }

    pub fn get_all_days(&self, year: Option<i32>) -> Result<Vec<Option<i32>>, LoreTexError> {
        let mut connection = self.db_connection()?;
        let mut query = history_items::table.into_boxed();
        if let Some(year) = year {
            query = query.filter(history_items::year.eq(year));
        }
        let days = query
            .load::<HistoryItem>(&mut connection)
            .map_err(|e| sql_loading_error("history items", "days", vec![("year", &year)], e))?
            .into_iter()
            .map(|item| item.day)
            .collect::<Vec<_>>();
        Ok(days)
    }

    pub fn get_all_history_labels(
        &self,
        year: Option<i32>,
        day: Option<i32>,
    ) -> Result<Vec<String>, LoreTexError> {
        let mut connection = self.db_connection()?;
        let mut query = history_items::table.into_boxed();
        if let Some(year) = year {
            query = query.filter(history_items::year.eq(year));
        }
        if let Some(day) = day {
            query = query.filter(history_items::day.eq(day));
        }
        let labels = query
            .load::<HistoryItem>(&mut connection)
            .map_err(|e| {
                sql_loading_error(
                    "history items",
                    "labels",
                    vec![("year", &year), ("day", &day)],
                    e,
                )
            })?
            .into_iter()
            .map(|c| c.label)
            .collect::<Vec<_>>();
        Ok(labels)
    }

    pub fn get_history_item_content(&self, label: &String) -> Result<String, LoreTexError> {
        let mut connection = self.db_connection()?;
        let items = history_items::table
            .filter(history_items::label.eq(label))
            .load::<HistoryItem>(&mut connection)
            .map_err(|e| {
                sql_loading_error("history item", "content", vec![("label", &Some(label))], e)
            })?;
        if items.len() > 1 {
            Err(LoreTexError::SqlError(
                "More than one entry found for label '".to_string() + label + "'.",
            ))
        } else {
            let content = match items.first() {
                Some(item) => item.content.to_owned(),
                None => {
                    return Err(LoreTexError::SqlError(
                        "No content found for label '".to_string() + label + "'.",
                    ))
                }
            };
            Ok(content)
        }
    }
}
