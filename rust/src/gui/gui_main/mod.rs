use crate::{db_col_view::DbColViewState, lore_database::LoreDatabase};

pub(crate) mod gui_message;
mod updating;
mod widget;

pub(crate) struct SqlGui {
    label_view_state: DbColViewState,
    descriptor_view_state: DbColViewState,
    current_description: String,
    lore_database: Option<LoreDatabase>,
    error_message: Option<String>,
}
