use loretex::{errors::LoreTexError, sql::lore_database::EntityColumn};

use crate::gui::db_col_view::DbColViewMessage;

use super::EntitiesViewState;

impl EntitiesViewState {
    pub fn update_label_view(&mut self, message: DbColViewMessage) {
        match message {
            DbColViewMessage::New => {
                if let Err(e) = self.new_entity() {
                    self.error_message = Some(e.to_string())
                }
            }
            DbColViewMessage::SearchFieldUpdated(text) => self.label_view_state.search_text = text,
            DbColViewMessage::Selected(_) => (), //handled elsewhere
        };
    }

    pub fn update_descriptor_view(&mut self, message: DbColViewMessage) {
        match message {
            DbColViewMessage::New => {
                if let Err(e) = self.new_descriptor() {
                    self.error_message = Some(e.to_string())
                }
            }
            DbColViewMessage::SearchFieldUpdated(text) => {
                self.descriptor_view_state.search_text = text
            }
            DbColViewMessage::Selected(_) => (), //handled elsewhere
        };
    }

    fn new_entity(&mut self) -> Result<(), LoreTexError> {
        let label = self.label_view_state.search_text.clone();
        if label.is_empty() {
            return Err(LoreTexError::InputError(
                "Cannot create entity with empty label.".to_string(),
            ));
        }
        let descriptor = "PLACEHOLDER".to_string();
        let description = String::new();
        let new_col = EntityColumn {
            label,
            descriptor,
            description,
        };
        let db = match self.lore_database.as_ref() {
            Some(db) => db,
            None => {
                return Err(LoreTexError::InputError(
                    "No database loaded to which to add new entity.".to_string(),
                ));
            }
        };
        db.write_column(new_col)?;
        self.update_labels();
        Ok(())
    }

    fn new_descriptor(&mut self) -> Result<(), LoreTexError> {
        let label = match self.label_view_state.selected_entry.as_ref() {
            Some(label) => label.clone(),
            None => {
                return Err(LoreTexError::InputError(
                    "No label selected for which to create new descriptor.".to_string(),
                ));
            }
        };
        let descriptor = self.descriptor_view_state.search_text.clone();
        if descriptor.is_empty() {
            return Err(LoreTexError::InputError(
                "Cannot create empty descriptor.".to_string(),
            ));
        }
        let description = String::new();
        let new_col = EntityColumn {
            label,
            descriptor,
            description,
        };
        let db = match self.lore_database.as_ref() {
            Some(db) => db,
            None => {
                return Err(LoreTexError::InputError(
                    "No database loaded to which to add descriptor.".to_string(),
                ));
            }
        };
        db.write_column(new_col)?;
        self.update_descriptors();
        Ok(())
    }
}
