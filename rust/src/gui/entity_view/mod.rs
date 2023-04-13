use super::db_col_view::DbColViewState;
use loretex::sql::lore_database::LoreDatabase;

mod widget;

pub struct EntityView<'a> {
    state: &'a EntityViewState,
    lore_database: &'a Option<LoreDatabase>,
}

pub struct EntityViewState {
    pub(crate) label_view_state: DbColViewState,
    pub(crate) descriptor_view_state: DbColViewState,
    pub current_description: String,
}

impl<'a> EntityView<'a> {
    pub fn new(state: &'a EntityViewState, lore_database: &'a Option<LoreDatabase>) -> Self {
        Self {
            state,
            lore_database,
        }
    }
}

impl EntityViewState {
    pub fn new() -> Self {
        Self {
            label_view_state: DbColViewState::new(),
            descriptor_view_state: DbColViewState::new(),
            current_description: String::new(),
        }
    }
}

impl Default for EntityViewState {
    fn default() -> Self {
        Self::new()
    }
}
