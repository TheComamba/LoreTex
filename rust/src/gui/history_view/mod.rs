use super::db_col_view::DbColViewState;

mod widget;

pub(super) struct HistoryView<'a> {
    state: &'a HistoryViewState,
}

pub(super) struct HistoryViewState {
    pub(super) label_view_state: DbColViewState,
}

impl HistoryViewState {
    pub(super) fn new() -> Self {
        Self {
            label_view_state: DbColViewState::new(),
        }
    }
}

impl<'a> HistoryView<'a> {
    pub(super) fn new(state: &'a HistoryViewState) -> Self {
        Self { state }
    }
}
