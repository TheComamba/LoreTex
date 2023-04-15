use crate::gui::db_col_view::DbColViewState;

use super::SqlGui;

impl SqlGui {
    pub(super) fn reset_selections(&mut self) {
        self.entity_view_state.label_view_state.selected_entry = None;
        self.entity_view_state.descriptor_view_state.selected_entry = None;
        self.entity_view_state.current_description = String::new();
    }

    pub(super) fn update_entity_labels(&mut self) {
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

    pub(super) fn update_descriptors(&mut self) {
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

    pub(super) fn update_description(&mut self) {
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
}
