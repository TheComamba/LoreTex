use loretex::{errors::LoreTexError, sql::lore_database::EntityColumn};

use super::SqlGui;
use crate::gui::db_col_view::DbColViewMessage;

#[derive(Debug, Clone)]
pub enum GuiMessage {
    NewDatabase,
    OpenDatabase,
    ErrorDialogClosed,
}
