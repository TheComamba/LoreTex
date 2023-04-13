use loretex::sql::lore_database::LoreDatabase;

use super::db_col_view::DbColViewState;

pub(crate) mod message_handling;
mod widget;

pub struct EntityView<'a> {
    label_view_state: DbColViewState,
    descriptor_view_state: DbColViewState,
    current_description: String,
    lore_database: &'a Option<LoreDatabase>,
}

impl<'a> EntityView<'a> {
    pub fn new(lore_database: &'a Option<LoreDatabase>) -> Self {
        Self {
            label_view_state: DbColViewState::new(),
            descriptor_view_state: DbColViewState::new(),
            current_description: String::new(),
            lore_database,
        }
    }
}
