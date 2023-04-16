use super::SqlGui;
use crate::gui::file_dialogs;
use loretex::{errors::LoreTexError, sql::lore_database::LoreDatabase};
use std::path::PathBuf;

impl SqlGui {
    fn update_database_derived_data(&mut self) -> Result<(), LoreTexError> {
        self.entity_view_state.reset(&self.lore_database)?;
        self.history_view_state.reset(&self.lore_database)?;
        self.relationship_view_state.reset(&self.lore_database)?;
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
