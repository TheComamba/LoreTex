use loretex::errors::LoreTexError;

use crate::gui::db_col_view::{DbColViewMessage, DbColViewState};

use super::SqlGui;

impl SqlGui {
    pub(super) fn update_year_view(
        &mut self,
        message: DbColViewMessage,
    ) -> Result<(), LoreTexError> {
        match message {
            DbColViewMessage::New => (),
            DbColViewMessage::SearchFieldUpdated(text) => {
                self.history_view_state.year_view_state.search_text = text
            }
            DbColViewMessage::Selected(label) => {
                self.history_view_state.year_view_state.selected_entry = Some(label);
                self.history_view_state.day_view_state.selected_entry = None;
                self.update_days()?;
            }
        };
        Ok(())
    }

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
        self.update_days()?;
        Ok(())
    }

    fn optional_int_to_string(opt: &Option<i32>) -> String {
        match opt {
            None => String::new(),
            Some(i) => i.to_string(),
        }
    }

    fn update_days(&mut self) -> Result<(), LoreTexError> {
        let year = match &self.history_view_state.year_view_state.selected_entry {
            Some(year) => year,
            None => {
                self.history_view_state.day_view_state.entries = vec![];
                return Ok(());
            }
        };
        let year = year
            .parse::<i32>()
            .map_err(|e| LoreTexError::InputError(e.to_string()))?;
        match self.lore_database.as_ref() {
            Some(db) => {
                self.history_view_state.day_view_state.entries = db
                    .get_all_days(year)?
                    .iter()
                    .map(|d| Self::optional_int_to_string(d))
                    .collect()
            }
            None => self.history_view_state.day_view_state = DbColViewState::new(),
        }
        Ok(())
    }
}
