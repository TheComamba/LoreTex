use super::db_col_view::state::DbColViewState;
use loretex::sql::lore_database::LoreDatabase;

mod widget;

pub(super) struct EntityView<'a> {
    state: &'a EntityViewState,
    lore_database: &'a Option<LoreDatabase>,
}

pub(super) struct EntityViewState {
    pub(super) label_view_state: DbColViewState,
    pub(super) descriptor_view_state: DbColViewState,
    pub(super) current_description: String,
}

impl<'a> EntityView<'a> {
    pub(super) fn new(state: &'a EntityViewState, lore_database: &'a Option<LoreDatabase>) -> Self {
        Self {
            state,
            lore_database,
        }
    }
}

impl EntityViewState {
    pub(super) fn new() -> Self {
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
