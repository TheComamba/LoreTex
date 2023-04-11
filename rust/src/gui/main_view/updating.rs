use std::path::PathBuf;

use loretex::sql::lore_database::LoreDatabase;

use crate::{gui::db_col_view::DbColViewState, gui::file_dialogs};

use super::SqlGui;

impl SqlGui {
    fn reset_selections(&mut self) {
        self.label_view_state.selected_entry = None;
        self.descriptor_view_state.selected_entry = None;
        self.current_description = String::new();
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
        self.reset_selections();
        self.update_labels();
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
        self.reset_selections();
        self.update_labels();
    }

    pub(super) fn update_labels(&mut self) {
        match self.lore_database.as_ref() {
            Some(db) => match db.get_all_labels() {
                Ok(labels) => self.label_view_state.entries = labels,
                Err(e) => {
                    self.error_message = Some(e.to_string());
                    self.label_view_state.entries = vec![];
                }
            },
            None => self.label_view_state = DbColViewState::new(),
        }
        self.update_descriptors();
    }

    pub(super) fn update_descriptors(&mut self) {
        let label = match &self.label_view_state.selected_entry {
            Some(label) => label,
            None => {
                self.descriptor_view_state.entries = vec![];
                return;
            }
        };
        match self.lore_database.as_ref() {
            Some(db) => match db.get_all_descriptors(label) {
                Ok(descriptors) => self.descriptor_view_state.entries = descriptors,
                Err(e) => {
                    self.error_message = Some(e.to_string());
                    self.descriptor_view_state.entries = vec![];
                    return;
                }
            },
            None => self.descriptor_view_state = DbColViewState::new(),
        }
        self.update_description();
    }

    pub(super) fn update_description(&mut self) {
        let label = match &self.label_view_state.selected_entry {
            Some(label) => label,
            None => {
                self.current_description = "".to_string();
                return;
            }
        };
        let descriptor = match &self.descriptor_view_state.selected_entry {
            Some(descriptor) => descriptor,
            None => {
                self.current_description = "".to_string();
                return;
            }
        };
        match self.lore_database.as_ref() {
            Some(db) => match db.get_description(label, descriptor) {
                Ok(desc) => self.current_description = desc,
                Err(e) => self.error_message = Some(e.to_string()),
            },
            None => self.current_description = String::new(),
        }
    }
}
