use crate::gui::{
    db_col_view::{DbColViewMessage, DbColViewState},
    history_view::HistoryViewState,
};
use loretex::{errors::LoreTexError, sql::lore_database::LoreDatabase};

impl HistoryViewState {
    pub(super) fn update_year_view(
        &mut self,
        message: DbColViewMessage,
        db: &Option<LoreDatabase>,
    ) -> Result<(), LoreTexError> {
        match message {
            DbColViewMessage::New => (),
            DbColViewMessage::SearchFieldUpdated(text) => self.year_view_state.search_text = text,
            DbColViewMessage::Selected(year) => {
                self.year_view_state.set_selected(year);
                self.day_view_state.set_selected_none();
                self.update_days(db)?;
            }
        };
        Ok(())
    }

    pub(super) fn update_day_view(
        &mut self,
        message: DbColViewMessage,
        db: &Option<LoreDatabase>,
    ) -> Result<(), LoreTexError> {
        match message {
            DbColViewMessage::New => (),
            DbColViewMessage::SearchFieldUpdated(text) => self.day_view_state.search_text = text,
            DbColViewMessage::Selected(day) => {
                self.day_view_state.set_selected(day);
                self.label_view_state.set_selected_none();
                self.update_labels(db)?;
            }
        };
        Ok(())
    }

    pub(super) fn update_label_view(
        &mut self,
        message: DbColViewMessage,
        db: &Option<LoreDatabase>,
    ) -> Result<(), LoreTexError> {
        match message {
            DbColViewMessage::New => (),
            DbColViewMessage::SearchFieldUpdated(text) => self.label_view_state.search_text = text,
            DbColViewMessage::Selected(label) => {
                self.label_view_state.set_selected(label);
                self.update_content(db)?;
            }
        };
        Ok(())
    }

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
