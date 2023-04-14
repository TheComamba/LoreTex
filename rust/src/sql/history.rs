use ::diesel::prelude::*;
use diesel::Insertable;

use super::schema::history_items;

#[derive(Insertable, Queryable)]
#[diesel(table_name = history_items)]
#[repr(C)]
pub struct HistoryColumn {
    pub label: String,
    content: String,
    is_concerns_others: bool,
    is_secret: bool,
    year: i32,
    day: Option<i32>,
    originator: Option<String>,
    year_format: Option<String>,
}
