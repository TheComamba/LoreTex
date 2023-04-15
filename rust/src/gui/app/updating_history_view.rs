use crate::gui::db_col_view::DbColViewState;

use super::SqlGui;

impl SqlGui {
    pub(super) fn reset_history_view(&mut self) {
        self.reset_history_view_selections();
        self.update_years();
    }

    fn reset_history_view_selections(&mut self) {
        self.history_view_state.year_view_state.selected_entry = None;
        self.history_view_state.day_view_state.selected_entry = None;
        self.history_view_state.label_view_state.selected_entry = None;
        self.history_view_state.current_content = String::new();
    }

    fn update_years(&mut self) {
        match self.lore_database.as_ref() {
            Some(db) => match db.get_all_years() {
                Ok(years) => {
                    self.history_view_state.year_view_state.entries =
                        years.iter().map(|y| y.to_string()).collect()
                }
                Err(e) => {
                    self.error_message = Some(e.to_string());
                    self.history_view_state.year_view_state.entries = vec![];
                }
            },
            None => self.history_view_state.year_view_state = DbColViewState::new(),
        }
        // self.update_days();
    }
}
