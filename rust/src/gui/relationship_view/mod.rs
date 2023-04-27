use crate::gui::db_col_view::state::DbColViewState;

mod widget;

pub(super) struct RelationshipView<'a> {
    state: &'a RelationshipViewState,
}

impl<'a> RelationshipView<'a> {
    pub(super) fn new(state: &'a RelationshipViewState) -> Self {
        Self { state }
    }
}

pub(super) struct RelationshipViewState {
    pub(super) parent_view_state: DbColViewState,
    pub(super) child_view_state: DbColViewState,
    pub(super) current_role: Option<String>,
}

impl RelationshipViewState {
    pub(super) fn new() -> Self {
        Self {
            parent_view_state: DbColViewState::new(),
            child_view_state: DbColViewState::new(),
            current_role: None,
        }
    }
}
