use std::path::PathBuf;

use loretex::sql::lore_database::LoreDatabase;

use crate::gui::file_dialogs;

use super::SqlGui;

impl SqlGui {
    fn update_database_derived_data(&mut self) {
        self.reset_entity_view();
        self.reset_history_view();
    }

    pub(super) fn new_database_from_dialog(&mut self) {
        let path = match file_dialogs::new() {
            Some(path) => path,
            None => return,
        };
        self.new_database(path.clone());
        if let Err(e) = crate::gui::user_preferences::store_database_path(path) {
            self.error_message = Some(e.to_string());
        };
    }

    pub(super) fn new_database(&mut self, path: PathBuf) {
        self.lore_database = match LoreDatabase::open(path) {
            Ok(db) => Some(db),
            Err(e) => {
                self.error_message = Some(e.to_string());
                None
            }
        };
        self.update_database_derived_data();
    }

    pub(super) fn open_database_from_dialog(&mut self) {
        let path = match file_dialogs::open() {
            Some(path) => path,
            None => return,
        };
        self.open_database(path.clone());
        if let Err(e) = crate::gui::user_preferences::store_database_path(path) {
            self.error_message = Some(e.to_string());
        };
    }

    pub(super) fn open_database(&mut self, path: PathBuf) {
        self.lore_database = match LoreDatabase::open(path) {
            Ok(db) => Some(db),
            Err(e) => {
                self.error_message = Some(e.to_string());
                None
            }
        };
        self.update_database_derived_data();
    }
}
