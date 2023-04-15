use std::path::PathBuf;

use loretex::{errors::LoreTexError, sql::lore_database::LoreDatabase};

use crate::gui::file_dialogs;

use super::SqlGui;

impl SqlGui {
    fn update_database_derived_data(&mut self) -> Result<(), LoreTexError> {
        self.entity_view_state
            .reset_entity_view(&self.lore_database)?;
        self.reset_history_view()?;
        Ok(())
    }

    pub(super) fn new_database_from_dialog(&mut self) -> Result<(), LoreTexError> {
        let path = match file_dialogs::new() {
            Some(path) => path,
            None => return Ok(()),
        };
        self.new_database(path.clone())?;
        crate::gui::user_preferences::store_database_path(path)?;
        Ok(())
    }

    pub(super) fn new_database(&mut self, path: PathBuf) -> Result<(), LoreTexError> {
        self.lore_database = Some(LoreDatabase::open(path)?);
        self.update_database_derived_data()?;
        Ok(())
    }

    pub(super) fn open_database_from_dialog(&mut self) -> Result<(), LoreTexError> {
        let path = match file_dialogs::open() {
            Some(path) => path,
            None => return Ok(()),
        };
        self.open_database(path.clone())?;
        crate::gui::user_preferences::store_database_path(path)?;
        Ok(())
    }

    pub(super) fn open_database(&mut self, path: PathBuf) -> Result<(), LoreTexError> {
        self.lore_database = Some(LoreDatabase::open(path)?);
        self.update_database_derived_data()?;
        Ok(())
    }
}
