use lore_tex::sql::lore_database::LoreDatabase;

use crate::gui::db_col_view::DbColViewState;

pub mod message_handling;
mod updating;
pub mod widget;

pub struct SqlGui {
    label_view_state: DbColViewState,
    descriptor_view_state: DbColViewState,
    current_description: String,
    lore_database: Option<LoreDatabase>,
    error_message: Option<String>,
}
