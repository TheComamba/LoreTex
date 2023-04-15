use loretex::errors::LoreTexError;

use crate::gui::db_col_view::DbColViewState;

use super::SqlGui;

impl SqlGui {
    pub(super) fn reset_history_view(&mut self) -> Result<(), LoreTexError> {
        self.reset_history_view_selections();
        self.update_years()?;
        Ok(())
    }

    fn reset_history_view_selections(&mut self) {
        self.history_view_state.year_view_state.selected_entry = None;
        self.history_view_state.day_view_state.selected_entry = None;
        self.history_view_state.label_view_state.selected_entry = None;
        self.history_view_state.current_content = String::new();
    }

    fn update_years(&mut self) -> Result<(), LoreTexError> {
        match self.lore_database.as_ref() {
            Some(db) => {
                self.history_view_state.year_view_state.entries =
                    db.get_all_years()?.iter().map(|y| y.to_string()).collect()
            }
            None => self.history_view_state.year_view_state = DbColViewState::new(),
        }
        // self.update_days();
        Ok(())
    }
}
