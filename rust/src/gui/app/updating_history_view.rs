use crate::gui::{
    db_col_view::{state::DbColViewState, ColViewMes},
    history_view::HistoryViewState,
};
use loretex::{errors::LoreTexError, sql::lore_database::LoreDatabase};

use super::SqlGui;

impl SqlGui {
    pub(super) fn update_year_view(&mut self, event: ColViewMes) -> Result<(), LoreTexError> {
        let state = &mut self.history_view_state;
        match event {
            ColViewMes::New => (),
            ColViewMes::SearchFieldUpd(text) => state.year_view_state.search_text = text,
            ColViewMes::Selected(year) => {
                state.year_view_state.set_selected(year);
                state.day_view_state.set_selected_none();
                state.update_days(&self.lore_database)?;
            }
        };
        Ok(())
    }

    pub(super) fn update_day_view(&mut self, event: ColViewMes) -> Result<(), LoreTexError> {
        let state = &mut self.history_view_state;
        match event {
            ColViewMes::New => (),
            ColViewMes::SearchFieldUpd(text) => state.day_view_state.search_text = text,
            ColViewMes::Selected(day) => {
                state.day_view_state.set_selected(day);
                state.label_view_state.set_selected_none();
                state.update_labels(&self.lore_database)?;
            }
        };
        Ok(())
    }

    pub(super) fn update_history_label_view(
        &mut self,
        event: ColViewMes,
    ) -> Result<(), LoreTexError> {
        let state = &mut self.history_view_state;
        match event {
            ColViewMes::New => (),
            ColViewMes::SearchFieldUpd(text) => state.label_view_state.search_text = text,
            ColViewMes::Selected(label) => {
                state.label_view_state.set_selected(label);
                state.update_content(&self.lore_database)?;
            }
        };
        Ok(())
    }
}

impl HistoryViewState {
    pub(super) fn reset(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        self.reset_selections();
        self.update_years(db)?;
        Ok(())
    }

    fn reset_selections(&mut self) {
        self.year_view_state.set_selected_none();
        self.day_view_state.set_selected_none();
        self.label_view_state.set_selected_none();
        self.current_content = String::new();
    }

    fn update_years(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        match db {
            Some(db) => {
                let years = db.get_all_years()?.iter().map(|y| y.to_string()).collect();
                self.year_view_state.set_entries(years);
            }
            None => self.year_view_state = DbColViewState::new(),
        }
        self.update_days(db)?;
        Ok(())
    }

    fn optional_int_to_string(opt: &Option<i32>) -> String {
        match opt {
            None => String::new(),
            Some(i) => i.to_string(),
        }
    }

    fn update_days(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        let year = self.year_view_state.get_selected_int()?;
        match db {
            Some(db) => {
                let days = db
                    .get_all_days(year)?
                    .iter()
                    .map(|d| Self::optional_int_to_string(d))
                    .collect();
                self.day_view_state.set_entries(days);
            }
            None => self.day_view_state = DbColViewState::new(),
        }
        self.update_labels(db)?;
        Ok(())
    }

    fn update_labels(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        let year = self.year_view_state.get_selected_int()?;
        let day = self.day_view_state.get_selected_int()?;
        match db {
            Some(db) => self
                .label_view_state
                .set_entries(db.get_all_history_labels(year, day)?),
            None => self.label_view_state = DbColViewState::new(),
        }
        self.update_content(db)?;
        Ok(())
    }

    fn update_content(&mut self, db: &Option<LoreDatabase>) -> Result<(), LoreTexError> {
        let label = match self.label_view_state.get_selected() {
            Some(label) => label,
            None => {
                self.current_content = "".to_string();
                return Ok(());
            }
        };
        match db {
            Some(db) => self.current_content = db.get_history_item_content(label)?,
            None => self.current_content = String::new(),
        }
        Ok(())
    }
}
