use loretex::{errors::LoreTexError, sql::entity::EntityColumn};

use crate::gui::db_col_view::{DbColViewMessage, DbColViewState};

use super::SqlGui;

impl SqlGui {
    pub(super) fn reset_entity_view(&mut self) {
        self.reset_selections();
        self.update_entity_labels();
    }

    fn reset_selections(&mut self) {
        self.entity_view_state.label_view_state.selected_entry = None;
        self.entity_view_state.descriptor_view_state.selected_entry = None;
        self.entity_view_state.current_description = String::new();
    }

    fn update_entity_labels(&mut self) {
        match self.lore_database.as_ref() {
            Some(db) => match db.get_all_labels() {
                Ok(labels) => self.entity_view_state.label_view_state.entries = labels,
                Err(e) => {
                    self.error_message = Some(e.to_string());
                    self.entity_view_state.label_view_state.entries = vec![];
                }
            },
            None => self.entity_view_state.label_view_state = DbColViewState::new(),
        }
        self.update_descriptors();
    }

    fn update_descriptors(&mut self) {
        let label = match &self.entity_view_state.label_view_state.selected_entry {
            Some(label) => label,
            None => {
                self.entity_view_state.descriptor_view_state.entries = vec![];
                return;
            }
        };
        match self.lore_database.as_ref() {
            Some(db) => match db.get_all_descriptors(label) {
                Ok(descriptors) => {
                    self.entity_view_state.descriptor_view_state.entries = descriptors
                }
                Err(e) => {
                    self.error_message = Some(e.to_string());
                    self.entity_view_state.descriptor_view_state.entries = vec![];
                    return;
                }
            },
            None => self.entity_view_state.descriptor_view_state = DbColViewState::new(),
        }
        self.update_description();
    }

    fn update_description(&mut self) {
        let label = match &self.entity_view_state.label_view_state.selected_entry {
            Some(label) => label,
            None => {
                self.entity_view_state.current_description = "".to_string();
                return;
            }
        };
        let descriptor = match &self.entity_view_state.descriptor_view_state.selected_entry {
            Some(descriptor) => descriptor,
            None => {
                self.entity_view_state.current_description = "".to_string();
                return;
            }
        };
        match self.lore_database.as_ref() {
            Some(db) => match db.get_description(label, descriptor) {
                Ok(desc) => self.entity_view_state.current_description = desc,
                Err(e) => self.error_message = Some(e.to_string()),
            },
            None => self.entity_view_state.current_description = String::new(),
        }
    }

    pub(super) fn update_entity_label_view(
        &mut self,
        message: DbColViewMessage,
    ) -> Result<(), LoreTexError> {
        match message {
            DbColViewMessage::New => self.new_entity()?,
            DbColViewMessage::SearchFieldUpdated(text) => {
                self.entity_view_state.label_view_state.search_text = text
            }
            DbColViewMessage::Selected(label) => {
                self.entity_view_state.label_view_state.selected_entry = Some(label);
                self.entity_view_state.descriptor_view_state.selected_entry = None;
                self.update_descriptors();
            }
        };
        Ok(())
    }

    pub(super) fn update_descriptor_view(
        &mut self,
        message: DbColViewMessage,
    ) -> Result<(), LoreTexError> {
        match message {
            DbColViewMessage::New => self.new_descriptor()?,
            DbColViewMessage::SearchFieldUpdated(text) => {
                self.entity_view_state.descriptor_view_state.search_text = text
            }
            DbColViewMessage::Selected(descriptor) => {
                self.entity_view_state.descriptor_view_state.selected_entry = Some(descriptor);
                self.update_description();
            }
        };
        Ok(())
    }

    fn new_entity(&mut self) -> Result<(), LoreTexError> {
        let label = self.entity_view_state.label_view_state.search_text.clone();
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
        db.write_entity_column(new_col)?;
        self.update_entity_labels();
        Ok(())
    }

    fn new_descriptor(&mut self) -> Result<(), LoreTexError> {
        let label = match self
            .entity_view_state
            .label_view_state
            .selected_entry
            .as_ref()
        {
            Some(label) => label.clone(),
            None => {
                return Err(LoreTexError::InputError(
                    "No label selected for which to create new descriptor.".to_string(),
                ));
            }
        };
        let descriptor = self
            .entity_view_state
            .descriptor_view_state
            .search_text
            .clone();
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
        db.write_entity_column(new_col)?;
        self.update_descriptors();
        Ok(())
    }
}
